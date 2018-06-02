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

    var direction: ControlDirection?
}

extension CharacterTouchControlComponent: ControlOverlayResponder {
    func didSelect(direction: ControlDirection) {
        self.direction = direction
        startQueue()
    }
    
    func selectionChanged(direction: ControlDirection) {
        self.direction = direction
    }
    
    func selectionDidEnd(direction: ControlDirection) {
        self.direction = direction
    }
    
    private func startQueue() {
        guard
            let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node,
            let queue = entity?.component(ofType: MoveActionQueueComponent.self)
            else {
                assertionFailure()
                return
        }
        
        let moveAction = MoveAction(vector: node.position + direction!.moveVector)
        queue.run([moveAction]) {
            //
        }
    }
}
