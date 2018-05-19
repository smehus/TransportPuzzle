//
//  SCNVector3+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import SceneKit


extension SCNVector3 {
    func flipped() -> SCNVector3 {
        return SCNVector3(-x, -y, -z)
    }
}

func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}
