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
        
        var animation: Animation = .idle
        
        if let hiddenCollisions: HiddenCollisionEntity = EntityManager.shared.entity(),
            let hiddenComp = hiddenCollisions.component(ofType: HiddenCollisionComponent.self) {
            
            let vector = nextAction.vector - node.position
            for (_, collision) in hiddenComp.currentCollisions {
                switch collision.hiddenCollider {
                case .hiddenRight where vector.x > 0: break
//                    animation = .push
//                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                case .hiddenLeft where vector.x < 0: break
//                    animation = .push
//                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                case .hiddenFront where nextAction.direction! == .top:
                    animation = .push
                    let newPos = simd_float3(collision.node.position) + node.presentation.simdWorldFront * CHARACTER_MOVE_AMT
                    let vector = SCNVector3(x: Int(round(newPos.x)).float, y: Int(round(newPos.y)).float, z: Int(round(newPos.z)).float)
                    collision.node.runAction(SCNAction.move(to: vector , duration: animation.animationDuration))
                case .hiddenBack where vector.z < 0: break
//                    animation = .push
//                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.push.animationDuration))
                default: break
                }
            }
        }
        
        var actions = [SCNAction]()
        var newPos: float3
//        let direction = simd_float3(nextAction.direction!.moveVector)
        
        switch nextAction.direction! {
        case .top:
            animation = .walk
            newPos = node.presentation.simdPosition + node.presentation.simdWorldFront * CHARACTER_MOVE_AMT
            let vector = SCNVector3(x: Int(round(newPos.x)).float, y: Int(round(newPos.y)).float, z: Int(round(newPos.z)).float)
//            print("MOVING TO \(vector)")
            let moveAction = SCNAction.move(to: vector, duration: animation.animationDuration)
            actions.append(moveAction)
            
        case .right:
            
            let moveAmount = node.presentation.simdWorldRight * CHARACTER_MOVE_AMT
            newPos = node.presentation.simdPosition + moveAmount
            
//            let (_, rotateAction) = node.rotateToAction(to: node.presentation.simdWorldRight.vector3)
            let radians = CGFloat(-90).degreesToRadians()
            let rotateAction = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.1)
            actions.append(rotateAction)
            
        case .left:
            let reveresedRight = node.presentation.simdWorldRight * -1
            let moveAmount = reveresedRight * CHARACTER_MOVE_AMT
            newPos = node.presentation.simdPosition + moveAmount
            
//            let (_, rotateAction) = node.rotateToAction(to: moveAmount.vector3)
            let radians = CGFloat(90).degreesToRadians()
            let rotateAction = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.1)
            actions.append(rotateAction)
            
            
        case .bottom:
            
            let reverseBottom = node.presentation.simdWorldFront * -1
            let moveAmount = reverseBottom * CHARACTER_MOVE_AMT
            newPos = node.presentation.simdPosition + moveAmount
            
//            let (_, rotateAction) = node.rotateToAction(to: moveAmount.vector3)
            let radians = CGFloat(180).degreesToRadians()
            let rotateAction = SCNAction.rotateBy(x: 0, y: radians, z: 0, duration: 0.1)
            actions.append(rotateAction)
        }

        // Only move if going forward? I guess so
//        let vector = SCNVector3(x: newPos.x, y: newPos.y, z: newPos.z)
//        let moveAction = SCNAction.move(to: vector, duration: animation.animationDuration)
//        actions.append(moveAction)
        
        
        node.addAnimationPlayer(animation.player, forKey: Animation.key)
        node.runAction(SCNAction.group(actions)) {
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
