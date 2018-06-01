//
//  HiddenCollisionComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

struct HiddenCollision {
    let contact: SCNPhysicsContact
    let node: SCNNode
    let hiddenCollider: ColliderType
}

final class HiddenCollisionComponent: GKComponent {
    var currentCollisions: [ColliderType: HiddenCollision] = [:]
}

extension HiddenCollisionComponent: CollisionDetector {
    
    func didBegin(_ contact: SCNPhysicsContact) {
        let hiddenColliders: ColliderType = [.hiddenLeft, .hiddenRight, .hiddenFront, .hiddenBack]
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
  
        if hiddenColliders.contains(colliderA) {
            insert(collision: HiddenCollision(contact: contact, node: contact.nodeB, hiddenCollider: colliderA), for: colliderA.union(colliderB))
        } else if hiddenColliders.contains(colliderB) {
            insert(collision: HiddenCollision(contact: contact, node: contact.nodeA, hiddenCollider: colliderB), for: colliderA.union(colliderB))
        }
    }
    
    private func insert(collision: HiddenCollision, for key: ColliderType) {
        currentCollisions.updateValue(collision, forKey: key)
    }
    
    func didEnd(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        currentCollisions[colliderA.union(colliderB)] = nil
    }
}
