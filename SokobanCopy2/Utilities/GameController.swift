//
//  GameController.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/18/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit
import UIKit.UIGestureRecognizerSubclass

final class PathGesture: UIGestureRecognizer {
    
    var lastLocation: SCNVector3?
    
    var scnView: SCNView {
        return view as! SCNView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard lastLocation == nil else {
            state = .failed
            return
        }
        
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let _ = lastLocation else { return }
        
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let _ = lastLocation else { return }
        
        state = .ended
    }
    
    override func reset() {
        super.reset()
        lastLocation = nil
        print("resetting gesture")
    }
}

final class GameController: NSObject {
    
    var entityManager = EntityManager.shared
    
    private var scene: SCNScene!
    private var sceneRenderer: SCNSceneRenderer?

    private var lastUpdate: TimeInterval = 0
    
    init(scnView: SCNView) {
        super.init()
    
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
        entityManager.controller = self
        entityManager.renderer = sceneRenderer!
        
        // Add ControlOverlay
//        entityManager.add(OverlayEntity(size: scnView.bounds.size, controller: self))
        
        scene = SCNScene(named: "art.scnassets/Scenes/game.scn")!
        scene.physicsWorld.contactDelegate = self
        sceneRenderer!.scene = scene
        
        sceneRenderer!.showsStatistics = true
        scnView.backgroundColor = UIColor.black
//        sceneRenderer!.debugOptions = [.showPhysicsShapes]
        sceneRenderer!.pointOfView = scene!.rootNode.childNode(withName: "camera", recursively: true)
        
        setupCollisions()
        setupNodes()
        setupGestures()
    }
    
    private func setupGestures() {
        guard let view = sceneRenderer as? SCNView else { assertionFailure(); return }
        let touchDownGesture = PathGesture(target: self, action: #selector(path(gesture:)))
        view.addGestureRecognizer(touchDownGesture)
    }
    
    @objc private func path(gesture: PathGesture) {
    
        guard let view = sceneRenderer as? SCNView else { assertionFailure(); return }
        let location = gesture.location(in: view)
        let hitResults = view.hitTest(location, options: [:])
        
        guard let result = hitResults.first else { return }
        guard let plane = result.node.entity as? PlaneEntity else { return }
        guard let comp = plane.component(ofType: GKSCNNodeComponent.self) else { return }
 
        if
            gesture.state == .changed,
            let last = gesture.lastLocation,
            Int(abs(last.x)).distance(to: Int(abs(result.localCoordinates.x))) < 2 &&
                Int(abs(last.z)).distance(to: Int(abs(result.localCoordinates.z))) < 2
        {
//            print("Pan Failed last \(Int(abs(last.x)).distance(to: Int(abs(result.localCoordinates.x)))) result \(Int(abs(last.z)).distance(to: Int(abs(result.localCoordinates.z))))")
            return
        }
        
        guard Int(result.localCoordinates.x) % 2 == 0 else { return }
        guard Int(result.localCoordinates.z) % 2 == 0 else { return }
    
        gesture.lastLocation = createHighligher(with: result, component: comp)
    }
    
    private func createHighligher(with result: SCNHitTestResult, component: GKSCNNodeComponent) -> SCNVector3 {
        // Create entities and add to entitiy manager for this
        // Also need to add collision to remove these
        // Also need to manually create the highlighters for when the use presses far away from characgter
        // Use Gameplaykit pathfinding for that?
        let highlighter = HighlighterNode()
        highlighter.position = SCNVector3(Int(result.localCoordinates.x), Int(result.localCoordinates.y), Int(result.localCoordinates.z))
        component.node.addChildNode(highlighter)
        return highlighter.position
    }
}

extension GameController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let _ = Double(time - lastUpdate)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updatePositions()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    }
    
    private func updatePositions() {
        guard let character: CharacterEntity = entityManager.entity() else { return }
        guard let characterComponent = character.component(ofType: GKSCNNodeComponent.self) else { return }
        guard let hiddenCollision: HiddenCollisionEntity = entityManager.entity() else { return }
        guard let hiddenComponent = hiddenCollision.component(ofType: GKSCNNodeComponent.self) else { return }
        hiddenComponent.node.position = characterComponent.node.position
//        hiddenCollision.rotation = character.rotation
    }
}

extension GameController {
    
    private func setupCollisions() {
        
        ColliderType.shouldNotify[.player] = true
        ColliderType.shouldNotify[.box] = true
        ColliderType.shouldNotify[.hiddenBack] = true
        ColliderType.shouldNotify[.hiddenFront] = true
        ColliderType.shouldNotify[.hiddenLeft] = true
        ColliderType.shouldNotify[.hiddenRight] = true
        
        ColliderType.requestedContactNotifications[.box] = [.player]
        ColliderType.requestedContactNotifications[.player] = [.box]
        
        ColliderType.requestedContactNotifications[.hiddenFront] =  [.box]
        ColliderType.requestedContactNotifications[.hiddenBack] =   [.box]
        ColliderType.requestedContactNotifications[.hiddenLeft] =   [.box]
        ColliderType.requestedContactNotifications[.hiddenRight] =  [.box]
        
        ColliderType.definedCollisions[.player] = [.box]
        ColliderType.definedCollisions[.box] = [.player, .plane]
        ColliderType.definedCollisions[.plane] = [.box]
    }
    
    private func setupNodes() {

        guard let hiddenCollision = scene.rootNode.childNode(withName: "CharacterCollision", recursively: true) else { assertionFailure(); return }
        entityManager.add(HiddenCollisionEntity(node: hiddenCollision))
        
        guard let character = scene.rootNode.childNode(withName: "Armature", recursively: true) else { assertionFailure(); return }
        entityManager.add(CharacterEntity(node: character))
        
        guard let box = scene.rootNode.childNode(withName: "Cube", recursively: true) else { assertionFailure(); return }
        entityManager.add(BoxEntity(node: box))
        
        guard let plane = scene.rootNode.childNode(withName: "Plane", recursively: true) else { assertionFailure(); return }
        entityManager.add(PlaneEntity(node: plane))
    }
}

extension GameController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        entityManager.didBegin(contact)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) { }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        entityManager.didEnd(contact)
    }
}
