//
//  GameViewController.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/5/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

struct ColliderType: OptionSet, Hashable, CustomDebugStringConvertible {
    // MARK: Static properties
    
    static var shouldNotify = [ColliderType: Bool]()
    
    /// A dictionary to specify which `ColliderType`s should be notified of contacts with other `ColliderType`s.
    static var requestedContactNotifications = [ColliderType: [ColliderType]]()
    
    /// A dictionary of which `ColliderType`s should collide with other `ColliderType`s.
    static var definedCollisions = [ColliderType: [ColliderType]]()
    
    // MARK: Properties
    
    let rawValue: Int
    
    // MARK: Options
    
    static var player: ColliderType  { return self.init(rawValue: 1 << 0) }
    static var box: ColliderType { return self.init(rawValue: 1 << 1) }
    static var plane: ColliderType   { return self.init(rawValue: 1 << 2) }
    
    // MARK: Hashable
    
    var hashValue: Int {
        return Int(rawValue)
    }
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        return "UnknownColliderType(\(self.rawValue))"
    }
    
    // MARK: SpriteKit Physics Convenience
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `categoryMask` property.
    var categoryMask: Int {
        return rawValue
    }
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `collisionMask` property.
    var collisionMask: Int {
        // Combine all of the collision requests for this type using a bitwise or.
        let mask = ColliderType.definedCollisions[self]?.reduce(ColliderType()) { initial, colliderType in
            return initial.union(colliderType)
        }
        
        // Provide the rawValue of the resulting mask or 0 (so the object doesn't collide with anything).
        return mask?.rawValue ?? 0
    }
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `contactMask` property.
    var contactMask: Int {
        // Combine all of the contact requests for this type using a bitwise or.
        let mask = ColliderType.requestedContactNotifications[self]?.reduce(ColliderType()) { initial, colliderType in
            return initial.union(colliderType)
        }
        
        // Provide the rawValue of the resulting mask or 0 (so the object doesn't need contact callbacks).
        return mask?.rawValue ?? 0
    }
    
    // MARK: ContactNotifiableType Convenience
    
    /**
     Returns `true` if the `ContactNotifiableType` associated with this `ColliderType` should be
     notified of contact with the passed `ColliderType`.
     */
    func notifyOnContactWith(_ colliderType: ColliderType) -> Bool {
        guard let notify = ColliderType.shouldNotify[self], notify else { return false }
        if let requestedContacts = ColliderType.requestedContactNotifications[self] {
            return requestedContacts.contains(colliderType)
        }
        
        return false
    }
}


final class GameViewController: UIViewController {

    private var scene: SCNScene!
    private var scnView: SCNView!
    private var player: SCNNode!
    private var plane: SCNNode!
    private var box: SCNNode!
    private var lastUpdate: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = self.view as! SCNView
        scnView.delegate = self

        scene = SCNScene(named: "art.scnassets/game.scn")!
        scene.physicsWorld.contactDelegate = self
        scnView.scene = scene

        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        setupCollisions()
        setupNodes()
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: scnView)
        guard let hit = scnView.hitTest(location, options: nil).first else { return }
        
        let coord = hit.worldCoordinates
        
        let zOFfset = abs(coord.z.distance(to: player.position.z))
        let xOffset = abs(coord.x.distance(to: player.position.x))
        
        var moveVector = SCNVector3(player.position.x, player.position.y, player.position.z)
        
        if zOFfset.isLess(than: xOffset) {
            // use x value
            switch coord {
            case _ where coord.x < player.position.x:
                moveVector.x -= 1
            case _ where coord.x > player.position.x:
                moveVector.x += 1
            default: break
            }
        } else {
            // use z value
            switch coord {
            case _ where coord.z < player.position.z:
                moveVector.z -= 1
            case _ where coord.z > player.position.z:
                moveVector.z += 1
            default: break
            }
        }
        
        let wait = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.scnView.isUserInteractionEnabled = true
            }
        }
        let move = SCNAction.move(to: moveVector, duration: 0.3)
        scnView.isUserInteractionEnabled = false
        player.runAction(SCNAction.sequence([move, wait]))
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let colliderTypeA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        
        // Determine which `ColliderType` should be notified of the contact.
        let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
        let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
        
        guard aWantsCallback || bWantsCallback else { return }
        
        let box = colliderTypeA == .box ? contact.nodeA : contact.nodeB
        
        ColliderType.shouldNotify[colliderTypeA] = false
        ColliderType.shouldNotify[colliderTypeB] = false
        
        var moveVector = box.position
        switch contact.contactNormal {
        case _ where contact.contactNormal.x == -1:
            moveVector.x += 1
        case _ where contact.contactNormal.x == 1:
            moveVector.x -= 1
        case _ where contact.contactNormal.z == -1:
            moveVector.z += 1
        case _ where contact.contactNormal.z == 1:
            moveVector.z -= 1
        default: break
        }
        
        let action = SCNAction.move(to: moveVector, duration: 0.3)
        let wait = SCNAction.run { _ in
            ColliderType.shouldNotify[colliderTypeA] = true
            ColliderType.shouldNotify[colliderTypeB] = true
        }
        box.runAction(SCNAction.sequence([action, wait]))
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {


    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let _ = Double(time - lastUpdate)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    }
}

extension GameViewController {
    
    private func setupCollisions() {
        
        ColliderType.shouldNotify[.player] = true
        ColliderType.shouldNotify[.box] = true
        
        ColliderType.requestedContactNotifications[.player] = [.box]
        
        ColliderType.requestedContactNotifications[.box] = [.player]
        ColliderType.requestedContactNotifications[.player] = [.box]
        
        ColliderType.definedCollisions[.player] = [.box]
        ColliderType.definedCollisions[.box] = [.player, .plane]
        ColliderType.definedCollisions[.plane] = [.box]
    }
    
    private func setupNodes() {
        player = scene.rootNode.childNode(withName: "player", recursively: true)
        player.physicsBody!.categoryBitMask = ColliderType.player.categoryMask
        player.physicsBody!.contactTestBitMask = ColliderType.player.contactMask
        player.physicsBody!.collisionBitMask = ColliderType.player.collisionMask
        
        box = scene.rootNode.childNode(withName: "box", recursively: true)
        box.physicsBody!.categoryBitMask = ColliderType.box.categoryMask
        box.physicsBody!.collisionBitMask = ColliderType.box.collisionMask
        box.physicsBody!.contactTestBitMask = ColliderType.box.contactMask
        
        plane = scene.rootNode.childNode(withName: "plane", recursively: true)
        plane.physicsBody!.categoryBitMask = ColliderType.plane.categoryMask
        plane.physicsBody!.collisionBitMask = ColliderType.plane.collisionMask
        plane.physicsBody!.contactTestBitMask = ColliderType.plane.contactMask
    }
}
