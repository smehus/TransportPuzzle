//
//  MoveActionQueueComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 6/2/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class MoveActionQueueComponent: GKComponent {
    
    func run(_ actions: [MoveAction], completed: @escaping () -> ()) {
        
        let node = entity!.component(ofType: GKSCNNodeComponent.self)!.node
        var newActions = actions
        let nextAction  = newActions.removeFirst()
    
        var animation: Animation = .walk
        
        if let hiddenCollisions: HiddenCollisionEntity = EntityManager.shared.entity(),
            let hiddenComp = hiddenCollisions.component(ofType: HiddenCollisionComponent.self) {
            
            let vector = nextAction.vector - node.position
            for (_, collision) in hiddenComp.currentCollisions {
                
                switch collision.hiddenCollider {
                case .hiddenRight where vector.x > 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                case .hiddenLeft where vector.x < 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                case .hiddenFront where vector.z > 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                case .hiddenBack where vector.z < 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                default: break
                }
            }
        }
        
//        node.addAnimationPlayer(animation.player, forKey: Animation.key)
        
        var actions = [SCNAction]()
        var newPos: float3
        let direction = simd_float3(nextAction.direction!.moveVector)
        
        if nextAction.direction! == .top {
            newPos = node.presentation.simdPosition + node.presentation.simdWorldFront * 2
        } else {
            let (rotateVector, rotateAction) = node.rotateToAction(to: nextAction.vector)
            actions.append(rotateAction)
            newPos = node.presentation.simdPosition + direction
        }
    
        let vector = SCNVector3(x: newPos.x, y: newPos.y, z: newPos.z)
        let moveAction = SCNAction.move(to: vector, duration: animation.animationDuration)
        actions.append(moveAction)
        
        node.runAction(SCNAction.group(actions)) {
            guard !newActions.isEmpty else { completed(); return }
            self.run(newActions, completed: completed)
        }
        
        
        /*
        // Need to figure out how to group these
        node.runAction(rotate) {
        
            let newPOS = node.presentation.simdPosition + node.presentation.simdWorldFront * 2
            let vector = SCNVector3(x: newPOS.x, y: newPOS.y, z: newPOS.z)
            let moveAction = SCNAction.move(to: vector, duration: animation.animationDuration)
            node.runAction(moveAction, completionHandler: {
                guard !newActions.isEmpty else { completed(); return }
                self.run(newActions, completed: completed)
            })
        }
 */
    }
}
