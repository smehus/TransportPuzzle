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
        
        let moveAction = SCNAction.move(to: nextAction.vector, duration: animation.animationDuration)
        let rotateVec = node.rotateVector(to: nextAction.vector)
        let rotateAction = SCNAction.rotateTo(x: 0, y: rotateVec.y.cg, z: 0, duration: animation.animationDuration / 2, usesShortestUnitArc: true)
        
        node.addAnimationPlayer(animation.player, forKey: Animation.key)
        node.runAction(SCNAction.group([moveAction, rotateAction]), forKey: SCNAction.moveActionKey) {
            guard !newActions.isEmpty else { completed(); return }
            self.run(newActions, completed: completed)
        }
    }
}
