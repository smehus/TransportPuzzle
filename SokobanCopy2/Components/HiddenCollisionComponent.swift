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
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let character: CharacterEntity = EntityManager.shared.entity() else { return }
        guard let characterComponent = character.component(ofType: GKSCNNodeComponent.self) else { return }
        guard let hiddenCollision = entity as? HiddenCollisionEntity else { return }
        guard let hiddenComponent = hiddenCollision.component(ofType: GKSCNNodeComponent.self) else { return }
        let newPos = SCNVector3(characterComponent.node.position.x, 0.0, characterComponent.node.position.z)
        hiddenComponent.node.position = newPos
        hiddenComponent.node.rotation = characterComponent.node.rotation
    }
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
