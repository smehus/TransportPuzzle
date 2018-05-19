//
//  OverlayEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class OverlayEntity: GKEntity {
    
    init(size: CGSize, controller: GameController) {
        
        super.init()
        
        addComponent(TouchControlComponent(size: size, controller: controller))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
