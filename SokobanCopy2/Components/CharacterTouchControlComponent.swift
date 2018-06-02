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

    enum State {
        case stop
        case move(direction: ControlDirection)
    }

    private var state: State = .stop {
        didSet {
            switch state {
            case .move:
                queueMove()
            case .stop: break
            }
        }
    }
}

extension CharacterTouchControlComponent: ControlOverlayResponder {
    func didSelect(direction: ControlDirection) {
        state = .move(direction: direction)
    }
    
    func selectionChanged(direction: ControlDirection) {
        guard case let .move(currentDirection) = state else { state = .stop; return }
        guard currentDirection != direction else { return }
        state = .move(direction: direction)
    }
    
    func selectionDidEnd(direction: ControlDirection) {
        state = .stop
    }
    
    private func queueMove() {
        guard
            let node = entity?.component(ofType: GKSCNNodeComponent.self)?.node,
            let queue = entity?.component(ofType: MoveActionQueueComponent.self)
            else {
                return
        }

        guard case let .move(direction) = state else {
            node.removeAllAnimations()
            node.addAnimationPlayer(Animation.idle.player, forKey: Animation.key)
            return
        }
        
        let moveAction = MoveAction(vector: node.position + direction.moveVector)
        queue.run([moveAction]) {
            self.queueMove()
        }
    }
}
