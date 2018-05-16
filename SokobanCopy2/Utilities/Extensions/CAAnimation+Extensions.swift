//
//  CAAnimation+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/15/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit
import SceneKit

extension CAAnimation {
    static func animationWithScene(named name: String) -> SCNAnimationPlayer? {
        var animation: SCNAnimationPlayer?
        if let scene = SCNScene(named: name) {
            scene.rootNode.enumerateChildNodes { (node, stop) in
                if node.animationKeys.count > 0 {
                    animation = node.animationPlayer(forKey: node.animationKeys.first!)
                    stop.initialize(to: true)
                }
            }
        }
        
        return animation
    }
}
