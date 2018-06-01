//
//  CameraEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 6/1/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class CameraEntity: GKEntity {
    
    init(container: SCNNode) {
        super.init()
        addComponent(GKSCNNodeComponent(node: container))
        addComponent(CameraFollowComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
