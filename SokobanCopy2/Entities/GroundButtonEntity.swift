//
//  GroundButtonEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 7/22/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

final class GroundButtonEntity: GKEntity {
    
    
    init(node: SCNNode) {
        
        super.init()
        
        guard let body = node.physicsBody else { assertionFailure(); return }
        
        body.categoryBitMask = ColliderType.groundButton.categoryMask
        body.contactTestBitMask = ColliderType.groundButton.contactMask
        
        addComponent(GKSCNNodeComponent(node: node))
        addComponent(GroundButtonCollisionComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class GroundButtonCollisionComponent: GKComponent {
    var currentCollision: SCNNode?
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        if let collision = currentCollision {
            let offset = node.parent!.presentation.simdPosition - collision.presentation.simdPosition
            if abs(offset.x) >= 2 || abs(offset.z) >= 2 {
                currentCollision = nil
                print("NO LONGER INTERSECTING ****")
            }
        }
    }
}

extension GroundButtonCollisionComponent: CollisionDetector {
    
    func didBegin(_ contact: SCNPhysicsContact) {
        let groundCollider = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask) : ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        let collision = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask) : ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        
        guard groundCollider == .groundButton else { return }
        guard currentCollision == nil else { return }
        
        if groundCollider.notifyOnContactWith(collision) {
            print("ADDING COLLISION ***")
            currentCollision = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? contact.nodeB : contact.nodeA
        }
    }
    
    func didEnd(_ contact: SCNPhysicsContact) {
        // Getting called cause certain parts of armature get not touching anymore??
        
        /*
        let groundCollider = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask) : ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        let collision = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask) : ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        
        guard groundCollider == .groundButton else { return }
        
        if groundCollider.notifyOnContactWith(collision) {
            currentCollision = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? contact.nodeB : contact.nodeA
        }
     */
    }
}
