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
    
    func rotateToAction(to vector: SCNVector3) -> SCNAction {
        let lengthZ = presentation.position.z - vector.z
        let lengthX = presentation.position.x - vector.x
        let direction = float2(x: lengthX, y: lengthZ)
        let normalized = normalize(direction)
        let degrees: CGFloat = atan2(CGFloat(normalized.x), CGFloat(normalized.y)).radiansToDegrees()
        
        let nearest = DEFINED_ROTATIONS.nearestElement(to: degrees)
        let vec = SCNVector3(0, nearest.degreesToRadians(), 0)
        return SCNAction.rotateTo(x: vec.x.cg, y: vec.y.cg, z: vec.z.cg, duration: 0.1, usesShortestUnitArc: true)
    }
}
