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
    
    private var lastLocation: SCNVector3?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard lastLocation == nil else {
//            assertionFailure("Why is the last location no nil")
            return
        }
        guard let result = hitResult(touches, with: event) else {
            lastLocation = nil
            return
        }
        
        
        print("BEGAN")
        state = .began
        lastLocation = result.localCoordinates
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let last = lastLocation else {
            ignore(touches.first!, for: event)
            return
        }
        guard let result = hitResult(touches, with: event) else {
            ignore(touches.first!, for: event)
            return
        }
        guard Int(last.x).distance(to: Int(result.localCoordinates.x)) >= 2 || Int(last.z).distance(to: Int(result.localCoordinates.z)) >= 2 else {
//            ignore(touches.first!, for: event)
            return
        }
        
        print("MOVED")
        state = .changed
        lastLocation = result.localCoordinates
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let last = lastLocation else { return }
        
        
        
        print("ENDED")
        state = .ended
    }
    
    override func reset() {
        super.reset()
        print("ressettttinngg")
        lastLocation = nil
    }
    
    private func hitResult(_ touches: Set<UITouch>, with event: UIEvent) -> SCNHitTestResult? {
        guard let touch = touches.first else { return nil }
        guard let scnView = view as? SCNView else { assertionFailure(); return nil }
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: [:])
        return hitResults.first
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
        let touchDownGesture = PathGesture(target: self, action: #selector(touchDown(gesture:)))
        view.addGestureRecognizer(touchDownGesture)
    }
    
    @objc private func touchDown(gesture: UIGestureRecognizer) {
        guard let view = sceneRenderer as? SCNView else { assertionFailure(); return }
        let location = gesture.location(in: view)
        let hitResults = view.hitTest(location, options: [:])
        guard let result = hitResults.first else { return }
        
        if let plane = result.node.entity as? PlaneEntity {
            guard let comp = plane.component(ofType: GKSCNNodeComponent.self) else { return }
            
            guard Int(result.localCoordinates.x) % 2 == 0 else { return }
            guard Int(result.localCoordinates.z) % 2 == 0 else { return }
            let g = SCNSphere(radius: 0.5)
            g.materials.first?.diffuse.contents = UIColor.yellow
            let highlighter = SCNNode(geometry: g)
            highlighter.eulerAngles = SCNVector3(-90, 0, 0)
            highlighter.position = SCNVector3(Int(result.localCoordinates.x), Int(result.localCoordinates.y), Int(result.localCoordinates.z))
            comp.node.addChildNode(highlighter)
            print("creating highlighter state \(gesture.state == .changed)")
        }
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
