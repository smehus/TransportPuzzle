//
//  ObstacleEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 7/28/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class ObstacleEntity: GKEntity {
    
    private let node: SCNNode
    
    init(node: SCNNode) {
        
        self.node = node
        let body = node.physicsBody!
        body.categoryBitMask = ColliderType.obstacle.categoryMask
        body.collisionBitMask = ColliderType.obstacle.collisionMask
        body.contactTestBitMask = ColliderType.obstacle.contactMask
        
        super.init()
        
        addComponent(GKSCNNodeComponent(node: node))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
