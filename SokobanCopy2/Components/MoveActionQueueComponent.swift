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
        let f = node.presentation.simdWorldFront
        let worldFront = abs(f.x) > abs(f.z) ? float3(round(f.x), 0, 0) : float3(0, 0, round(f.z))
        
        
        if let hiddenCollisions: HiddenCollisionEntity = EntityManager.shared.entity(),
            let hiddenComp = hiddenCollisions.component(ofType: HiddenCollisionComponent.self) {
            
            let vector = nextAction.vector - node.position
            for (collidedWith, collision) in hiddenComp.currentCollisions {
                switch collision.hiddenCollider {
                case .hiddenFront where nextAction.direction! == .top:
                    animation = .push
                    print("SHOULD USE PUSH ANIMATION")
                    if collidedWith == ColliderType.hiddenFront.union(.obstacle) {
                        print("Has current collision with obstacle")
                        return
                    }
                    
                    
                case .hiddenRight where vector.x > 0: break
                case .hiddenLeft where vector.x < 0: break
                case .hiddenBack where vector.z < 0: break
                default: break
                }
            }
        }
        
        var actions = [SCNAction]()
        var newPos: float3
        
        switch nextAction.direction! {
        case .top:
            
            newPos = node.presentation.simdPosition + worldFront * CHARACTER_MOVE_AMT
            let vector = SCNVector3(x: Int(round(newPos.x)).float, y: node.simdPosition.y, z: Int(round(newPos.z)).float)
            let moveAction = SCNAction.move(to: vector, duration: animation.animationDuration)
            actions.append(moveAction)
            
        case .right:
            
            let moveAmount = node.presentation.simdWorldRight * CHARACTER_MOVE_AMT
            newPos = node.presentation.simdPosition + moveAmount
            
            let radians = CGFloat(-90).degreesToRadians()
            let rotateAction = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.5)
            actions.append(rotateAction)
            
        case .left:
            let reveresedRight = node.presentation.simdWorldRight * -1
            let moveAmount = reveresedRight * CHARACTER_MOVE_AMT
            newPos = node.presentation.simdPosition + moveAmount
            
            let radians = CGFloat(90).degreesToRadians()
            let rotateAction = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.5)
            actions.append(rotateAction)
            
            
        case .bottom:
            
            let reverseBottom = node.presentation.simdWorldFront * -1
            let moveAmount = reverseBottom * CHARACTER_MOVE_AMT
            newPos = node.presentation.simdPosition + moveAmount
            
            let radians = CGFloat(180).degreesToRadians()
            let rotateAction = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.5)
            actions.append(rotateAction)
        }

        
        node.removeKnownAnimations()
        node.addAnimationPlayer(animation.player, forKey: animation.animationKey)
        
        node.runAction(SCNAction.group(actions), forKey: "move_action") {
            self.rotateCamera(node)
            guard !newActions.isEmpty else { completed(); return }
            self.run(newActions, completed: completed)
        }
    }
    
    private func rotateCamera(_ node: SCNNode) {
        return 
        guard let camera: CameraEntity = EntityManager.shared.entity() else { return }
//        guard let cameraNode = camera.component(ofType: GKSCNNodeComponent.self)?.node else { return }
//
//        SCNTransaction.begin()
//        SCNTransaction.animationDuration = 1.0
//        cameraNode.transform = node.transform
//        SCNTransaction.commit()

    }
}

extension float3 {
    var vector3: SCNVector3 {
        return SCNVector3(self)
    }
}
