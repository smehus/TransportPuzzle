//
//  HiddenCollisionComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class HiddenCollisionComponent: GKComponent {
    private var currentCollisions: Set<ColliderType> = []
}

extension HiddenCollisionComponent: CollisionDetector {
    
    func didBegin(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        guard let type = colliderForCollision(collider: colliderA.union(colliderB)) else { return }
        currentCollisions.insert(type)
    }
    
    func didEnd(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        guard let type = colliderForCollision(collider: colliderA.union(colliderB)) else { return }
        currentCollisions.remove(type)
    }
}
