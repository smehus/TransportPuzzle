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
        
        
        let geom = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: geom, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        node.physicsBody!.categoryBitMask = ColliderType.player.categoryMask
        node.physicsBody!.contactTestBitMask = ColliderType.player.contactMask
        node.physicsBody!.collisionBitMask = ColliderType.player.collisionMask
        addComponent(GKSCNNodeComponent(node: node))
        addComponent(MoveActionQueueComponent())

        if MOVEMENT_TYPE == .manual {
            addComponent(CharacterTouchControlComponent())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(along paths: [GKGridGraphNode], on grid: SCNNode) {
        let node = component(ofType: GKSCNNodeComponent.self)!.node
        
        node.removeAllActions()
        node.removeAnimation(forKey: Animation.AnimationKey.walk.rawValue)
        
        var moveActions: [MoveAction] = []
        
        for (_, path) in paths.enumerated() {
            let pos = SCNVector3(Int(path.gridPosition.x), 0, Int(path.gridPosition.y))
            let convertedPOS = grid.convertPosition(pos, to: node.parent!)
            moveActions.append(MoveAction(vector: convertedPOS, direction: nil))
        }
        
        
        component(ofType: MoveActionQueueComponent.self)!.run(moveActions) {
            node.removeAnimation(forKey: Animation.AnimationKey.walk.rawValue)
            node.addAnimationPlayer(Animation.idle.player, forKey: Animation.AnimationKey.idle.rawValue)
        }
    }
}

struct MoveAction {
    let vector: SCNVector3
    let direction: ControlDirection?
}
