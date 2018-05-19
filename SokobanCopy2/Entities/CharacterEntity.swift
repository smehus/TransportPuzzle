//
//  Character.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/18/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class CharacterEntity: GKEntity {
    
    init(node: SCNNode) {
        super.init()
        
        let geom = SCNBox(width: 0.5, height: 2, length: 0.5, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: geom, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        node.physicsBody!.categoryBitMask = ColliderType.player.categoryMask
        node.physicsBody!.contactTestBitMask = ColliderType.player.contactMask
        node.physicsBody!.collisionBitMask = ColliderType.player.collisionMask
        
        addComponent(GKSCNNodeComponent(node: node))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(direction: ControlDirection) {
        guard let node = component(ofType: GKSCNNodeComponent.self)?.node else { assertionFailure(); return }
        
        var vector = node.position
        switch direction {
        case .left:
            vector.x -= 1
        case .right:
            vector.x += 1
        case .top:
            vector.z -= 1
        case .bottom:
            vector.z += 1
        }
        
        let moveAction = SCNAction.move(to: vector, duration: 0.3)
        node.runAction(moveAction)
    }
}
