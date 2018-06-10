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
    private var currentPaths = [HighlighterEntity]()
    
    var grid: SCNNode! {
        guard let entity: PlaneEntity = entityManager.entity() else { return nil }
        return entity.component(ofType: GKSCNNodeComponent.self)!.node
    }
    
    init(scnView: SCNView) {
        super.init()
    
        scnView.isPlaying = true
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
        entityManager.controller = self
        entityManager.renderer = sceneRenderer!
    
        scene = SCNScene(named: "art.scnassets/Scenes/game.scn")!
        scene.physicsWorld.contactDelegate = self
        sceneRenderer!.scene = scene
        
        sceneRenderer!.showsStatistics = true
        scnView.backgroundColor = UIColor.black
//        sceneRenderer!.debugOptions = [.showPhysicsShapes]
        
        setupCollisions()
        setupNodes()
        if MOVEMENT_TYPE == .guided {
            setupGestures()
        }
    }
    
    private func addDebugHUD() {
        
    }
    
    private func setupGestures() {
        guard let view = sceneRenderer as? SCNView else { assertionFailure(); return }
        let touchDownGesture = PathGesture(target: self, action: #selector(path(gesture:)))
        view.addGestureRecognizer(touchDownGesture)
    }
    
    @objc private func path(gesture: PathGesture) {
        
        switch MOVEMENT_TYPE {
        case .guided:
            executeGuidedPath(gesture)
        case .manual:
            executeManualPath(gesture)
        }
    }
    
    private func executeManualPath(_ gesture: PathGesture) {
        // This is no longer a thing
    }
    
    private func executeGuidedPath(_ gesture: PathGesture) {
        if gesture.state == .began {
            currentPaths.forEach { (entity) in
                entity.removeFromManager()
            }
            
            currentPaths.removeAll()
        }
        
        guard let view = sceneRenderer as? SCNView else { assertionFailure(); return }
        let location = gesture.location(in: view)
        let hitResults = view.hitTest(location, options: [:])
        
        guard let result = hitResults.first else { return }
        guard let plane = result.node.entity as? PlaneEntity else { return }
        guard let comp = plane.component(ofType: GKSCNNodeComponent.self) else { return }
        
        if gesture.state == .ended, !currentPaths.isEmpty {
            movePlayer(along: currentPaths)
            return
        }
        
        guard Int(round(result.localCoordinates.x)) % 2 == 0 else { return }
        guard Int(round(result.localCoordinates.z)) % 2 == 0 else { return }
        
        let position = SCNVector3(Int(round(result.localCoordinates.x)), Int(round(result.localCoordinates.y)), Int(round(result.localCoordinates.z)))
        assert(graph.node(atGridPosition: vector_int2(Int32(position.x), Int32(position.z))) != nil)
        
        
        switch gesture.state {
        case .began, .changed:
            createPath(on: comp.node, targetPosition: position)
        default: break
        }
    }

    private func createPath(on grid: SCNNode, targetPosition: SCNVector3) {
        guard
            let character: CharacterEntity = entityManager.entity(),
            let charNode = character.component(ofType: GKSCNNodeComponent.self)?.node,
            let charGridNode = graph.node(atGridPosition: vector_int2(Int32(round(charNode.convertPosition(charNode.position, to: grid).x)), Int32(round(charNode.convertPosition(charNode.position, to: grid).z)))),
            let targetGridNode = graph.node(atGridPosition: vector_int2(Int32(targetPosition.x), Int32(targetPosition.z)))
        else {
            assertionFailure("Entity Manager Has No Character Entity")
            return
        }

        let paths = graph.findPath(from: charGridNode, to: targetGridNode)
        guard !paths.isEmpty, let gridPaths = paths as? [GKGridGraphNode] else {
            print("❌ Graph couldn't find viable path 😭")
            return
        }
        
        let filteredPaths = gridPaths.filter { (p) -> Bool in
            let isGridPosition = (p.gridPosition.x % 2 == 0) && (p.gridPosition.y % 2 == 0)
            let charPos = grid.convertPosition(charNode.position, from: charNode.parent)
            let gridPos = SCNVector3(Int(p.gridPosition.x), 0, Int(p.gridPosition.y))
            return isGridPosition && (charPos != gridPos)
        }
        
        var constructedPaths: [HighlighterEntity] = []
        for path in filteredPaths {
            let highlightEntity = HighlighterEntity(position: SCNVector3(Int(path.gridPosition.x), 0, Int(path.gridPosition.y)),
                                                    gridPath: path)
            entityManager.add(highlightEntity, parent: grid)
            constructedPaths.append(highlightEntity)
        }
        
        currentPaths.forEach { (entity) in
            entity.removeFromManager()
        }
        
        currentPaths = constructedPaths
    }
    
    private func movePlayer(along paths: [HighlighterEntity]) {
        print("MOVING PLAYER")
        guard let charEntity: CharacterEntity = entityManager.entity() else {
            assertionFailure()
            return
        }
        
        charEntity.move(along: paths.map { $0.gridPath }, on: grid)
    }
}

extension GameController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let _ = Double(time - lastUpdate)
        entityManager.update(time)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
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
        ColliderType.shouldNotify[.highlighter] = true
        
        ColliderType.requestedContactNotifications[.box] = [.player]
        
        ColliderType.requestedContactNotifications[.player] = [.box, .highlighter]
    
        ColliderType.requestedContactNotifications[.hiddenFront] =  [.box]
        ColliderType.requestedContactNotifications[.hiddenBack] =   [.box]
        ColliderType.requestedContactNotifications[.hiddenLeft] =   [.box]
        ColliderType.requestedContactNotifications[.hiddenRight] =  [.box]
        
        ColliderType.requestedContactNotifications[.highlighter] =  [.player]
        
        ColliderType.definedCollisions[.player] = [.box]
        ColliderType.definedCollisions[.box] = [.player, .plane]
        ColliderType.definedCollisions[.plane] = [.box]
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: MOVEMENT_TYPE_NOTIFICATION_NAME, object: nil, queue: nil) { (notification) in
            guard let type = notification.object as? MovementType else { return }
            switch type {
            case .manual:
                if let overlay: OverlayEntity = self.entityManager.entity() {
                    self.entityManager.remove(overlay)
                }
            case .guided:
                break
            }
        }
    }
    
    private func setupNodes() {
        
        if MOVEMENT_TYPE == .manual, let view = sceneRenderer as? SCNView {
            entityManager.add(OverlayEntity(size: view.bounds.size, controller: self))
        }

        guard let hiddenCollision = scene.rootNode.childNode(withName: "CharacterCollision", recursively: true) else { assertionFailure(); return }
        entityManager.add(HiddenCollisionEntity(node: hiddenCollision))
        
        guard let character = scene.rootNode.childNode(withName: "Character", recursively: true) else { assertionFailure(); return }
        entityManager.add(CharacterEntity(node: character))
        
        guard let box = scene.rootNode.childNode(withName: "Cube", recursively: true) else { assertionFailure(); return }
        entityManager.add(BoxEntity(node: box))
        
        guard let floor = scene.rootNode.childNode(withName: "Floor", recursively: true) else { assertionFailure(); return }
        for floorNode in floor.childNodes {
            entityManager.add(PlaneEntity(node: floorNode))
            
        }
        
        createGraph(with: floor.childNodes)
        
        guard let camera = scene.rootNode.childNode(withName: "cameraContainer", recursively: true) else { assertionFailure(); return }
        sceneRenderer!.pointOfView = camera.childNode(withName: "camera", recursively: true)
        entityManager.add(CameraEntity(container: camera))
        
        if SHOW_DEBUG_HUD {
//            let manager = DebugManager.shared
//            camera.addChildNode(manager.hudNode)
        }
    }
    
    private func createGraph(with nodes: [SCNNode]) {
        let node = nodes.first!
        // Will need to find the node with the lowest position & set it as the startingPoint
        // Find the node with the larges position and calculate the width / height
        
        graph = GKGridGraph(fromGridStartingAt: vector_int2(Int32(round(node.boundingBox.min.x)), Int32(round(node.boundingBox.min.z))), width: Int32(node.size.x), height: Int32(node.size.z), diagonalsAllowed: GRID_ALLOWS_DIAGONAL)
        var graphNodes: [GKGridGraphNode] = []
        
        // Will need to loop through all the nodes here
        stride(from: Int(node.boundingBox.min.x + GRID_WIDTH_HEIGHT/2), to: Int(node.boundingBox.max.x + GRID_WIDTH_HEIGHT/2), by: 2).forEach { (x) in
            stride(from: Int(node.boundingBox.min.z + GRID_WIDTH_HEIGHT/2), to: Int(node.boundingBox.max.z + GRID_WIDTH_HEIGHT/2), by: 2).forEach({ (z) in
                let graphNode = GKGridGraphNode(gridPosition: vector_int2(Int32(x), Int32(z)))
                graphNodes.append(graphNode)
            })
        }
        
        graph.add(graphNodes)

        removeOffCenterNodes()
    }
    
    private func removeOffCenterNodes() {
        guard let nodes = graph.nodes as? [GKGridGraphNode] else { return }
        
        var nodesToRemove: [GKGridGraphNode] = []
        for node in nodes {
            if node.gridPosition.x % 2 != 0 && node.gridPosition.y % 2 != 0 {
                nodesToRemove.append(node)
            }
        }
        
        graph.remove(nodesToRemove)
//        connectAdjacents()
//        createDebugNodes()
    }
    
    private func connectAdjacents() {
        let nodes = graph.nodes as! [GKGridGraphNode]
        
        for node in nodes {
            graph.connectToLowestCostNode(node: node, bidirectional: true)
        }
    }
    
    private func createDebugNodes() {
        guard let nodes = graph.nodes else {
            print("😡 Can't create debug nodes because they don't exist!!!")
            return
        }
        
        
        guard let planeEntity: PlaneEntity = entityManager.entity() else { assertionFailure(); return }
        guard let plane = planeEntity.component(ofType: GKSCNNodeComponent.self)?.node else { assertionFailure(); return }
        nodes.forEach { (node) in
            guard let gridNode = node as? GKGridGraphNode else { return }
            let highlighter = HighlighterNode()
            highlighter.position = SCNVector3(Int(gridNode.gridPosition.x), 0, Int(gridNode.gridPosition.y))
            plane.addChildNode(highlighter)
        }
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
