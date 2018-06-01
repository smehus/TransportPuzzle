//
//  Character.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/18/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class CharacterEntity: GKEntity {

    init(node: SCNNode) {
        super.init()
        
        let geom = SCNBox(width: 0.5, height: 2, length: 0.5, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: geom, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        node.physicsBody!.categoryBitMask = ColliderType.player.categoryMask
        node.physicsBody!.contactTestBitMask = ColliderType.player.contactMask
        node.physicsBody!.collisionBitMask = ColliderType.player.collisionMask
        
        addComponent(GKSCNNodeComponent(node: node))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(along paths: [GKGridGraphNode], on grid: SCNNode) {
        let node = component(ofType: GKSCNNodeComponent.self)!.node
        
        node.removeAllActions()
        node.removeAnimation(forKey: Animation.key)
        
        var moveActions: [MoveAction] = []
        
        for (_, path) in paths.enumerated() {
            let pos = SCNVector3(Int(path.gridPosition.x), 0, Int(path.gridPosition.y))
            let convertedPOS = grid.convertPosition(pos, to: node.parent!)
            moveActions.append(MoveAction(vector: convertedPOS))
        }
        
        run(moveActions) {
            node.removeAnimation(forKey: Animation.key)
            node.addAnimationPlayer(Animation.idle.player, forKey: Animation.key)
        }
    }
    
    private func run(_ actions: [MoveAction], completed: @escaping () -> ()) {
        let node = component(ofType: GKSCNNodeComponent.self)!.node
        var newActions = actions
        let nextAction  = newActions.removeFirst()
        
        let moveAction = SCNAction.move(to: nextAction.vector, duration: Animation.walk.animationDuration)
        let rotateVec = node.rotateVector(to: nextAction.vector)
        let rotateAction = SCNAction.rotateTo(x: 0, y: rotateVec.y.cg, z: 0, duration: 0.1)
    
        var animation: Animation = .walk
        
        if let hiddenCollisions: HiddenCollisionEntity = EntityManager.shared.entity(),
            let hiddenComp = hiddenCollisions.component(ofType: HiddenCollisionComponent.self) {
            
            let vector = nextAction.vector - node.position
            for (_, collision) in hiddenComp.currentCollisions {
                
                switch collision.hiddenCollider {
                case .hiddenRight where vector.x > 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.walk.animationDuration))
                case .hiddenLeft where vector.x < 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.walk.animationDuration))
                case .hiddenFront where vector.z > 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.walk.animationDuration))
                case .hiddenBack where vector.z < 0:
                    animation = .push
                    collision.node.runAction(SCNAction.move(to: collision.node.position + vector, duration: Animation.walk.animationDuration))
                default: break
                }
            }
        }
        
        node.addAnimationPlayer(animation.player, forKey: Animation.key)
        node.runAction(SCNAction.group([moveAction, rotateAction]), forKey: Animation.key) {
            guard !newActions.isEmpty else { completed(); return }
            self.run(newActions, completed: completed)
        }
    }
}

struct MoveAction {
    let vector: SCNVector3
}
