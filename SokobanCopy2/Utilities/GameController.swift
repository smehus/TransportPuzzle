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

final class GameController: NSObject {
    
    var entityManager = EntityManager.shared
    
    private var scene: SCNScene!
    private var sceneRenderer: SCNSceneRenderer?
    private var graph: GKGridGraph<GKGridGraphNode>!

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
 
//        if
//            gesture.state == .changed,
//            let last = gesture.lastLocation,
//            Int(abs(last.x)).distance(to: Int(abs(result.localCoordinates.x))) < 2 &&
//                Int(abs(last.z)).distance(to: Int(abs(result.localCoordinates.z))) < 2
//        {
////            print("Pan Failed last \(Int(abs(last.x)).distance(to: Int(abs(result.localCoordinates.x)))) result \(Int(abs(last.z)).distance(to: Int(abs(result.localCoordinates.z))))")
//            return
//        }
        
        guard Int(round(result.localCoordinates.x)) % 2 == 0 else { return }
        guard Int(round(result.localCoordinates.z)) % 2 == 0 else { return }
    
//        gesture.lastLocation = createHighligher(with: result, component: comp)
        
        let thing = SCNVector3(Int(round(result.localCoordinates.x)), Int(round(result.localCoordinates.y)), Int(round(result.localCoordinates.z)))
        
        print("wtf")
    }
    
    private func createHighligher(with result: SCNHitTestResult, component: GKSCNNodeComponent) -> SCNVector3 {
        // Create entities and add to entitiy manager for this
        // Also need to add collision to remove these
        // Also need to manually create the highlighters for when the use presses far away from characgter
        // Use Gameplaykit pathfinding for that?
        let highlighter = HighlighterNode()
        highlighter.position = SCNVector3(Int(round(result.localCoordinates.x)), Int(round(result.localCoordinates.y)), Int(round(result.localCoordinates.z)))
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
        createGraph(with: plane)
    }
    
    func createGraph(with node: SCNNode) {
        graph = GKGridGraph(fromGridStartingAt: vector_int2(Int32(round(node.boundingBox.min.x)), Int32(round(node.boundingBox.min.z))), width: Int32(node.size.x), height: Int32(node.size.z), diagonalsAllowed: true)
        var graphNodes: [GKGridGraphNode] = []
        
        stride(from: Int(node.boundingBox.min.x), to: Int(node.boundingBox.max.x), by: 2).forEach { (x) in
            stride(from: Int(node.boundingBox.min.z), to: Int(node.boundingBox.max.z), by: 2).forEach({ (z) in
                let graphNode = GKGridGraphNode(gridPosition: vector_int2(Int32(x), Int32(z)))
                graphNodes.append(graphNode)
                
                let highlighter = HighlighterNode()
                highlighter.position = SCNVector3(Int(x), 0, Int(z))
                node.addChildNode(highlighter)
            })
        }
        
        graph.add(graphNodes)
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
