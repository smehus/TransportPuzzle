//
//  HighlighterNode.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/30/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import SceneKit

final class HighlighterNode: SCNNode {
    
    override init() {
        super.init()
        let g = SCNSphere(radius: 0.5)
        g.materials.first?.diffuse.contents = UIColor.yellow
        self.geometry = g
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
