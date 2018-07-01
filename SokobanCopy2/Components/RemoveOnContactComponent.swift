//
//  RemoveOnContactComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/31/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class RemoveOnContactComponent: GKComponent {
    
    private let collider: ColliderType
    init(collider: ColliderType) {
        self.collider = collider
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RemoveOnContactComponent: CollisionDetector {
    
    func shouldRespond(to contact: SCNPhysicsContact) -> Bool {
        return true
    }
    
    func didBegin(_ contact: SCNPhysicsContact) {
        guard let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node else {
            assertionFailure("Remove On Contact Entity has no node")
            return
        }
        
        let (a, b) = colliders(from: contact)
        
        guard contact.nodeA.position == node.position || contact.nodeB.position == node.position else { return }
        
        if collider == a.union(b), let removable = entity as? RemovableEntity {
            removable.removeFromManager()
        }
    }
    
    func didUpdate(_ contact: SCNPhysicsContact) { }
    
    func didEnd(_ contact: SCNPhysicsContact) { }
    
    private func colliders(from contact: SCNPhysicsContact) -> (ColliderType, ColliderType) {
        let colliderA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        return (colliderA, colliderB)
    }
}
