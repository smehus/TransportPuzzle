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
    
    private var entityManager = EntityManager.shared
    
    private var scene: SCNScene!
    private var sceneRenderer: SCNSceneRenderer?

    private var lastUpdate: TimeInterval = 0
    private var currentContacts: [ColliderType: SCNVector3] = [:]
    
    init(scnView: SCNView) {
        super.init()
    
        sceneRenderer = scnView
        sceneRenderer!.delegate = self
        
        entityManager.controller = self
        entityManager.renderer = sceneRenderer!
        
        // Add ControlOverlay
        entityManager.add(OverlayEntity(size: scnView.bounds.size, controller: self))
        
        scene = SCNScene(named: "art.scnassets/Scenes/game.scn")!
        scene.physicsWorld.contactDelegate = self
        sceneRenderer!.scene = scene
        
        sceneRenderer!.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        sceneRenderer!.debugOptions = [.showPhysicsShapes]
        sceneRenderer!.pointOfView = scene!.rootNode.childNode(withName: "camera", recursively: true)
        
        setupCollisions()
        setupNodes()
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
        
        guard let plane = scene.rootNode.childNode(withName: "plane", recursively: true) else { assertionFailure(); return }
        entityManager.add(PlaneEntity(node: plane))
    }
}

extension GameController: SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let colliderTypeA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        
        // Determine which `ColliderType` should be notified of the contact.
        let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
        let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
        
        guard aWantsCallback || bWantsCallback else { return }
        
        switch colliderTypeA.union(colliderTypeB) {
        case ColliderType.hiddenLeft.union(.box):
            currentContacts[.hiddenLeft] = contact.contactNormal
        case ColliderType.hiddenRight.union(.box):
            currentContacts[.hiddenRight] = contact.contactNormal
        case ColliderType.hiddenBack.union(.box):
            currentContacts[.hiddenBack] = contact.contactNormal
        case ColliderType.hiddenFront.union(.box):
            currentContacts[.hiddenFront] = contact.contactNormal
        default: break
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let colliderTypeA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        
        switch colliderTypeA.union(colliderTypeB) {
        case ColliderType.hiddenLeft.union(.box):
            currentContacts.removeValue(forKey: .hiddenLeft)
        case ColliderType.hiddenRight.union(.box):
            currentContacts.removeValue(forKey: .hiddenRight)
        case ColliderType.hiddenBack.union(.box):
            currentContacts.removeValue(forKey: .hiddenBack)
        case ColliderType.hiddenFront.union(.box):
            currentContacts.removeValue(forKey: .hiddenFront)
        default: break
        }
        
    }
    /*
    private func moveBox(normal: SCNVector3) {
        
        ColliderType.shouldNotify[.box] = false
        ColliderType.shouldNotify[.player] = false
        
        
        var moveVector = box.position
        if abs(normal.x) > abs(normal.z) {
            switch normal {
            case _ where normal.x < 0:
                moveVector.x += 1
            case _ where normal.x > 0:
                moveVector.x -= 1
            default: break
            }
        } else {
            switch normal {
            case _ where normal.z < 0:
                moveVector.z += 1
            case _ where normal.z > 0:
                moveVector.z -= 1
            default: break
            }
        }
        
        let action = SCNAction.move(to: moveVector, duration: Animation.push.animationDuration)
        let wait = SCNAction.run { _ in
            ColliderType.shouldNotify[.box] = true
            ColliderType.shouldNotify[.player] = true
        }
        
        box.runAction(SCNAction.sequence([action, wait]))
    }
     */
}

extension GameController {
    
    // This will be a delegate fucntion of the control overlay
    /*(
    override func tap(at location: SCNVector3) {
        
        guard let hit = scnView.hitTest(location, options: nil).first else { return }
        
        let coord = hit.worldCoordinates
        let charPosition = scene.rootNode.convertPosition(character.position, from: character.parent!)
        
        let zOFfset = abs(coord.z.distance(to: charPosition.z))
        let xOffset = abs(coord.x.distance(to: charPosition.x))
        
        var moveVector = charPosition
        
        var collider: ColliderType?
        if zOFfset.isLess(than: xOffset) {
            // use x value
            switch coord {
            case _ where coord.x < charPosition.x:
                collider = .hiddenLeft
                moveVector.x -= 1
            case _ where coord.x > charPosition.x:
                collider = .hiddenRight
                moveVector.x += 1
            default: break
            }
        } else {
            // use z value
            switch coord {
            case _ where coord.z < charPosition.z:
                collider = .hiddenBack
                moveVector.z -= 1
            case _ where coord.z > charPosition.z:
                collider = .hiddenFront
                moveVector.z += 1
            default: break
            }
        }
        
        
        let lengthY = coord.z - charPosition.z
        let lengthX = coord.x - charPosition.x
        let direction = float2(x: lengthX, y: lengthY)
        let normalized = normalize(direction)
        let degrees: CGFloat = atan2(CGFloat(normalized.x), CGFloat(normalized.y)).radiansToDegrees()
        
        let nearest = [0, 90, -90, 180, -180].nearestElement(to: degrees)
        let rotate = SCNAction.rotateTo(x: 0, y: CGFloat(shortestAngleBetween(CGFloat(charPosition.y), angle2: nearest.degreesToRadians())), z: 0.0, duration: 0.1)
        
        let wait = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.character.removeAllAnimations()
                self.character.addAnimationPlayer(Animation.idle.player, forKey: "idle")
            }
        }
        
        var animation: Animation = .walk
        if let col = collider, let normal = currentContacts[col] {
            animation = Animation.push
            moveBox(normal: normal)
        }
        
        let move = SCNAction.move(to: moveVector, duration: animation.animationDuration)
        character.addAnimationPlayer(animation.player, forKey: "walking")
        character.runAction(SCNAction.sequence([SCNAction.group([move, rotate]), wait]))
    }
 
 */
}