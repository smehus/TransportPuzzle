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
    
    private var node: SCNNode {
        return entity!.component(ofType: GKSCNNodeComponent.self)!.node
    }

    private var previousDirection: ControlDirection?
    private var currentDirection: ControlDirection? {
        didSet {
            previousDirection = oldValue
        }
    }
    
    private var debugManager = DebugManager.shared
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        queueMove()
    }
}

extension CharacterTouchControlComponent: ControlOverlayResponder {
    
    func didSelect(direction: ControlDirection) {
        currentDirection = direction
    }
    
    func selectionChanged(direction: ControlDirection) {
        currentDirection = direction
    }
    
    func selectionDidEnd(direction: ControlDirection) {
        print("*** SELECTION DID END")
        currentDirection = nil
    }

    private func queueMove() {
        guard !node.hasActions else { return }
        guard let queue = entity?.component(ofType: MoveActionQueueComponent.self) else { return }

        guard let direction = currentDirection else {
            return
        }
        
        if let previous = previousDirection, direction == previous, !direction.updateContinously {
            node.removeKnownAnimations()
            return
        }
        
        let vectorOffset = direction.moveVector
        queue.run([MoveAction(vector: node.position + vectorOffset, direction: direction)]) { [weak self] in
            guard let `self` = self else { assertionFailure(); return }
            if self.currentDirection == nil {
                self.node.removeKnownAnimations()
                let animation = Animation.idle
                self.node.addAnimationPlayer(animation.player, forKey: animation.animationKey)
            } else {
                print("*** fAILED REMOVING WALK ANIMATION \(self.currentDirection)")
            }
            
            self.queueMove()
        }
    }
}
