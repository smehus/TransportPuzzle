//
//  CharacterTouchControlComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 6/2/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class CharacterTouchControlComponent: GKComponent {

}

extension CharacterTouchControlComponent: ControlOverlayResponder {
    func didSelect(direction: ControlDirection) {
        guard
            let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node,
            let queue = entity?.component(ofType: MoveActionQueueComponent.self)
        else {
            assertionFailure()
            return
        }
        
        
        
        switch direction {
        default: break
        }
    }
    
    func selectionChanged(direction: ControlDirection) {
        
    }
    
    func selectionDidEnd(direction: ControlDirection) {
        
    }
}
