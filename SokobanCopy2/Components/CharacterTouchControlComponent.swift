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
        
        
        
        var vectorOffset = direction.moveVector
        if CAMERA_FOLLOWS_ROTATION, let offset = vector(for: node, control: direction) {
            vectorOffset = offset
        }
        
        queue.run([MoveAction(vector: node.position + vectorOffset)]) {
            self.queueMove()
        }
    }
    
    func vector(for node: SCNNode, control: ControlDirection) -> SCNVector3? {
        let rot = Int(CGFloat(node.eulerAngles.y).radiansToDegrees())
        var vector = SCNVector3(0, 0, 0)
        switch control {
        case .top:
            switch rot {
            case 0:
                vector.z += CHARACTER_MOVE_AMT
            case 180:
                vector.z -= CHARACTER_MOVE_AMT
            case 90:
                vector.x += CHARACTER_MOVE_AMT
            case -90:
                vector.x -= CHARACTER_MOVE_AMT
            default: break
            }
            
        case .bottom:
            switch rot {
            case 0:
                vector.z -= CHARACTER_MOVE_AMT
            case 180:
                vector.z += CHARACTER_MOVE_AMT
            case 90:
                vector.x -= CHARACTER_MOVE_AMT
            case -90:
                vector.x += CHARACTER_MOVE_AMT
            default: break
            }
            
        case .left:
            switch rot {
            case 0:
                vector.x += CHARACTER_MOVE_AMT
            case 180:
                vector.x -= CHARACTER_MOVE_AMT
            case 90:
                vector.z -= CHARACTER_MOVE_AMT
            case -90:
                vector.z += CHARACTER_MOVE_AMT
            default: break
            }
            
        case .right:
            switch rot {
            case 0:
                vector.x -= CHARACTER_MOVE_AMT
            case 180:
                vector.x += CHARACTER_MOVE_AMT
            case 90:
                vector.z += CHARACTER_MOVE_AMT
            case -90:
                vector.z -= CHARACTER_MOVE_AMT
            default: break
            }
        }
        
        
        return vector
    }
}
