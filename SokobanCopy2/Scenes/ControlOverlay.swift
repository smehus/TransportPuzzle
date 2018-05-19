//
//  ControlOverlay.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

final class ControlOverlay: SKScene {
    
    override init(size: CGSize, controller: GameController) {
        super.init(size: size)
        
        scaleMode = .resizeFill
    }
    
}
