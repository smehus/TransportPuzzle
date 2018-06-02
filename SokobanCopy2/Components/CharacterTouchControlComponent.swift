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

    private var currentDirection: ControlDirection?
    
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
        currentDirection = nil
    }

    private func queueMove() {
        guard !node.hasActions else { return }
        guard let queue = entity?.component(ofType: MoveActionQueueComponent.self) else { return }

        guard let direction = currentDirection else {
            node.removeAllAnimations()
            node.addAnimationPlayer(Animation.idle.player, forKey: Animation.key)
            return
        }
        
        queue.run([MoveAction(vector: node.position + direction.moveVector)]) {
            self.queueMove()
        }
    }
}
