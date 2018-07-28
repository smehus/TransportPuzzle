//
//  SCNVector3+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import SceneKit


extension SCNVector3 {
    
    var intValues: SCNVector3 {
        return SCNVector3(round(x), round(y), round(z))
    }
    
    func flipped() -> SCNVector3 {
        return SCNVector3(-x, -y, -z)
    }
    
    var simd: simd_float3 {
        return simd_float3(x, y, x)
    }
}

func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}

func -(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}

func !=(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return (lhs.x != rhs.x) || (lhs.y != rhs.y) || (lhs.z != rhs.z)
}

func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
    return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
}
