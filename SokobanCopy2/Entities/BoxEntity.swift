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
        
        node.physicsBody!.categoryBitMask = ColliderType.box.categoryMask
        node.physicsBody!.collisionBitMask = ColliderType.box.collisionMask
        node.physicsBody!.contactTestBitMask = ColliderType.box.contactMask
        node.physicsBody!.isAffectedByGravity = true
        node.entity = self
        
        addComponent(GKSCNNodeComponent(node: node))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
