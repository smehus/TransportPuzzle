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
        
        let nextPosition = node.position + vectorOffset
        queue.run([MoveAction(vector: nextPosition)]) {
            self.queueMove()
        }
    }
    
    func vector(for node: SCNNode, control: ControlDirection) -> SCNVector3? {
        
        // Use rotation instead of euler angles - That way I can decipher between 0 & 180, which both return 0 for some reason
        let rot = Int(CGFloat(node.eulerAngles.y).radiansToDegrees())
        var vector = SCNVector3(0, 0, 0)

        switch node.rotation.y {
        case 0:
            print("MOVEMENT 0")
            switch control {
            case .bottom:   vector.z -= CHARACTER_MOVE_AMT
            case .top:      vector.z += CHARACTER_MOVE_AMT
            case .left:     vector.x += CHARACTER_MOVE_AMT
            case .right:    vector.x -= CHARACTER_MOVE_AMT
            }
        case 1.0:
            if Int(round(node.rotation.w.cg.radiansToDegrees())) == 90 {
                print("Control: \(control.rawValue) MOVEMENT 1.0 at rotation 90")
                switch control {
                case .left:     vector.z -= CHARACTER_MOVE_AMT
                case .right:    vector.z += CHARACTER_MOVE_AMT
                case .bottom:   vector.x -= CHARACTER_MOVE_AMT
                case .top:      vector.x += CHARACTER_MOVE_AMT
                }
            } else if Int(round(node.rotation.w.cg.radiansToDegrees())) == 180 {
                print("Control: \(control.rawValue) MOVEMENT 1.0 at rotation 180")
                switch control {
                case .left:     vector.x -= CHARACTER_MOVE_AMT
                case .right:    vector.x += CHARACTER_MOVE_AMT
                case .bottom:   vector.z += CHARACTER_MOVE_AMT
                case .top:      vector.z -= CHARACTER_MOVE_AMT
                }
            } else if Int(round(node.rotation.w.cg.radiansToDegrees())) == 270 {
                print("Control: \(control.rawValue) MOVEMENT 1.0 at rotation 270")
                switch control {
                case .left:     vector.z += CHARACTER_MOVE_AMT
                case .right:    vector.z -= CHARACTER_MOVE_AMT
                case .bottom:   vector.x += CHARACTER_MOVE_AMT
                case .top:      vector.x -= CHARACTER_MOVE_AMT
                }
            } else {
                assertionFailure("Movement not handled for 1.0 Y & rotation \(node.rotation.w.cg): degrees \(node.rotation.w.cg.radiansToDegrees()) Control: \(control.rawValue)")
                return nil
            }

        case -1.0:
            if Int(round(node.rotation.w.cg.radiansToDegrees())) == 180 {
                print("Control: \(control.rawValue) MOVEMENT -1.0 at rotation 180")
                switch control {
                case .left:     vector.x -= CHARACTER_MOVE_AMT
                case .right:    vector.x += CHARACTER_MOVE_AMT
                case .bottom:   vector.z += CHARACTER_MOVE_AMT
                case .top:      vector.z -= CHARACTER_MOVE_AMT
                }
            } else if Int(round(node.rotation.w.cg.radiansToDegrees())) == 90 {
                print("Control: \(control.rawValue) MOVEMENT -1.0 at rotation 90")
                switch control {
                case .left:     vector.z += CHARACTER_MOVE_AMT
                case .right:    vector.z -= CHARACTER_MOVE_AMT
                case .bottom:   vector.x += CHARACTER_MOVE_AMT
                case .top:      vector.x -= CHARACTER_MOVE_AMT
                }
            } else if Int(round(node.rotation.w.cg.radiansToDegrees())) == 270 {
                print(" Control: \(control.rawValue)MOVEMENT -1.0 at rotation 270")
                switch control {
                case .left:     vector.z += CHARACTER_MOVE_AMT
                case .right:    vector.z -= CHARACTER_MOVE_AMT
                case .bottom:   vector.x += CHARACTER_MOVE_AMT
                case .top:      vector.x -= CHARACTER_MOVE_AMT
                }
            } else {
                assertionFailure("Movement not handled for -1.0 Y & rotation \(node.rotation.w.cg): degrees \(node.rotation.w.cg.radiansToDegrees()) Control: \(control.rawValue)")
            }

        default:
            assertionFailure("Y value not handled \(node.rotation)")
            return nil
        }
        
        
        return vector
    }
}
