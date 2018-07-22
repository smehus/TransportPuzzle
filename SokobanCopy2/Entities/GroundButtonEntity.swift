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

    var currentCollision: SCNNode? {
        didSet {
            guard let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node else { return }
            
            switch currentCollision {
            case .none:
                node.runAction(SCNAction.move(to: SCNVector3(node.simdPosition.x, 0.0, node.simdPosition.z), duration: 0.1))
            case .some:
                node.runAction(SCNAction.move(to: SCNVector3(node.simdPosition.x, -0.1, node.simdPosition.z), duration: 0.1))
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        if let collision = currentCollision {
            let offset = node.parent!.presentation.worldPosition - collision.presentation.worldPosition
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
        
        let groundNode = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? contact.nodeA : contact.nodeB
        let collisionNode = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? contact.nodeB : contact.nodeA
        
        let offset = groundNode.parent!.presentation.worldPosition - collisionNode.presentation.worldPosition
//        print("COLLISION POSITION \(groundNode.parent!.presentation.worldPosition) && \(collisionNode.presentation.worldPosition)")
        if groundCollider.notifyOnContactWith(collision), (abs(offset.x) < 1.0 && abs(offset.z) < 1.0)  {
            print("ADDING COLLISION ***")
            currentCollision = contact.nodeA.physicsBody!.categoryBitMask == ColliderType.groundButton.categoryMask ? contact.nodeB : contact.nodeA
        }
    }
    
    func didEnd(_ contact: SCNPhysicsContact) { }
}
