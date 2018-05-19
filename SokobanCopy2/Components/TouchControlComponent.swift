//
//  TouchControlComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class TouchControlComponent: GKComponent {
    
    let scene: SKScene
    
    init(size: CGSize, controller: GameController) {
        scene = ControlOverlay(size: size, controller: controller)
        super.init()
        
        scene.entity = entity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
    }
}
