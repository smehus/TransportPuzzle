//
//  NodeComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class MovableComponent: GKComponent {
    
}

extension MovableComponent: ControlOverlayResponder {
    
    func didSelect(direction: ControlDirection) {
        if let character = entity as? CharacterEntity {
            character.move(direction: direction)
        }
    }
}
