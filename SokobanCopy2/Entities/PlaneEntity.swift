//
//  PlaneEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class PlaneEntity: GKEntity {
    
    init(node: SCNNode) {
        super.init()
    
        let shape = SCNPhysicsShape(node: node, options: [:])
        node.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        node.physicsBody?.categoryBitMask = ColliderType.plane.categoryMask
        node.physicsBody?.collisionBitMask = ColliderType.plane.collisionMask
        node.physicsBody?.contactTestBitMask = ColliderType.plane.contactMask
        addComponent(GKSCNNodeComponent(node: node))
        addComponent(PathCreatorComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
