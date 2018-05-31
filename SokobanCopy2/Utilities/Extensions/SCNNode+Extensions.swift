//
//  SCNNode+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/30/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    var size: SCNVector3 {
        return boundingBox.max.intValues - boundingBox.min.intValues
    }
    
    func configure(collider: ColliderType) {
        guard let body = physicsBody else {
            assertionFailure("Attempting to configure collider on node without physics body")
            return
        }
        
        body.categoryBitMask = collider.categoryMask
        body.contactTestBitMask = collider.contactMask
        body.collisionBitMask = collider.collisionMask
        
    }
}
