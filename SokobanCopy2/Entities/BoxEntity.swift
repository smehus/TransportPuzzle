//
//  BoxEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class BoxEntity: GKEntity {
    
    init(node: SCNNode) {
        super.init()
        
        let boxGeom = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxShape = SCNPhysicsShape(geometry: boxGeom, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: boxShape)
        node.physicsBody!.categoryBitMask = ColliderType.box.categoryMask
        node.physicsBody!.collisionBitMask = ColliderType.box.collisionMask
        node.physicsBody!.contactTestBitMask = ColliderType.box.contactMask
        
        addComponent(GKSCNNodeComponent(node: node))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
