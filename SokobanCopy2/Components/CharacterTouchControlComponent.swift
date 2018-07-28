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

    private var debugManager = DebugManager.shared
}

extension CharacterTouchControlComponent: ControlOverlayResponder {
    
    func didSelect(direction: ControlDirection) {
        move(direction: direction)
    }
    
    func selectionChanged(direction: ControlDirection) { }
    func selectionDidEnd(direction: ControlDirection) { }
    
    private func move(direction: ControlDirection) {
        guard !node.hasActions else { return }
        guard let queue = entity?.component(ofType: MoveActionQueueComponent.self) else { return }

        let vectorOffset = direction.moveVector
        queue.run([MoveAction(vector: node.position + vectorOffset, direction: direction)]) { [weak self] in
            guard let `self` = self else { assertionFailure(); return }
            self.node.removeKnownAnimations()
            let animation = Animation.idle
            self.node.addAnimationPlayer(animation.player, forKey: animation.animationKey)
        }
    }
}







