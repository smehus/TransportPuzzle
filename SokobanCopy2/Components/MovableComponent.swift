//
//  NodeComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class MovableComponent: GKComponent {
    private var currentCollisions: [ColliderType: SCNVector3] = [:]
}

extension MovableComponent: ControlOverlayResponder {
    
    func didSelect(direction: ControlDirection) {
        if let character = entity as? CharacterEntity {
            character.move(controlDirection: direction)
        }
        
        if let boxEntity = entity as? BoxEntity,
            let collision = currentCollisions[direction.collider],
            let component = boxEntity.component(ofType: GKSCNNodeComponent.self) {
            let newPosition = component.node.position + collision.flipped()
            
            let moveAction = SCNAction.move(to: newPosition, duration: Animation.push.animationDuration)
            component.node.runAction(moveAction)
        }
    }
}

extension MovableComponent: CollisionDetector {
    
    func didBegin(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        guard let colliderType = colliderForCollision(collider: colliderA.union(colliderB)) else { return }
        currentCollisions[colliderType] = contact.contactNormal
    }
    
    func didEnd(_ contact: SCNPhysicsContact) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        guard let colliderType = colliderForCollision(collider: colliderA.union(colliderB)) else { return }
        currentCollisions[colliderType] = nil
    }
}
