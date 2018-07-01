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
    
    private var hiddenColliders: ColliderType = [.hiddenLeft, .hiddenRight, .hiddenFront, .hiddenBack]
    
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
    
    func shouldRespond(to contact: SCNPhysicsContact) -> Bool {
        return true
    }
    
    func didBegin(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        update(contact: contact, colliderA: colliderA, colliderB: colliderB)
    }
    
    func didUpdate(_ contact: SCNPhysicsContact) {
//        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
//        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
//        update(contact: contact, colliderA: colliderA, colliderB: colliderB)
    }

    func didEnd(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        
        if currentCollisions[colliderA.union(colliderB)] != nil {
            currentCollisions[colliderA.union(colliderB)] = nil
            print("removed collisions A \(colliderA) B \(colliderB)")
        }
    }
    
    private func update(contact: SCNPhysicsContact, colliderA: ColliderType, colliderB: ColliderType) {
        if hiddenColliders.contains(colliderA) {
            insert(collision: HiddenCollision(contact: contact, node: contact.nodeB, hiddenCollider: colliderA), for: colliderA.union(colliderB))
            print("ADDED COLLISIONS")
        } else if hiddenColliders.contains(colliderB) {
            insert(collision: HiddenCollision(contact: contact, node: contact.nodeA, hiddenCollider: colliderB), for: colliderA.union(colliderB))
            print("ADDED COLLISIONS")
        }
    }
    
    private func insert(collision: HiddenCollision, for key: ColliderType) {
        currentCollisions.updateValue(collision, forKey: key)
    }
}
