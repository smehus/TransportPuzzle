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
        addComponent(MovableComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func move(controlDirection: ControlDirection) {
        /*
        guard let node = component(ofType: GKSCNNodeComponent.self)?.node else { assertionFailure(); return }
        
        var vector = node.position
        switch controlDirection {
        case .left:
            vector.x -= CHARACTER_MOVE_AMT
        case .right:
            vector.x += CHARACTER_MOVE_AMT
        case .top:
            vector.z -= CHARACTER_MOVE_AMT
        case .bottom:
            vector.z += CHARACTER_MOVE_AMT
        }
        
        let rotateVector = rotateAction(to: vector)
        let rotate = SCNAction.rotateTo(x: CGFloat(rotateVector.x), y: CGFloat(rotateVector.y), z: CGFloat(rotateVector.z), duration: 0.1)
        
        let wait = SCNAction.run { _ in
            DispatchQueue.main.async {
                node.removeAllAnimations()
                node.addAnimationPlayer(Animation.idle.player, forKey: "idle")
                
                // Reset user interaction
                if let overlay: OverlayEntity = EntityManager.shared.entity(), let comp = overlay.component(ofType: TouchControlComponent.self) {
                    comp.scene.isUserInteractionEnabled = true
                } else {
                    assertionFailure()
                }
            }
        }
        var animation: Animation = .walk
        if let hidden: HiddenCollisionEntity = EntityManager.shared.entity(),
            let _ = hidden.collision(for: controlDirection) {
            animation = .push
        }
        
        let moveAction = SCNAction.move(to: vector, duration: animation.animationDuration)
        node.runAction(SCNAction.sequence([SCNAction.group([moveAction, rotate]), wait]))
        node.addAnimationPlayer(animation.player, forKey: "animation")
 */
    }
    
    func move(along paths: [GKGridGraphNode], on grid: SCNNode) {
        let node = component(ofType: GKSCNNodeComponent.self)!.node
        
        var moveActions: [MoveAction] = []
        
        for (_, path) in paths.enumerated() {
            let pos = SCNVector3(Int(path.gridPosition.x), 0, Int(path.gridPosition.y))
            let convertedPOS = grid.convertPosition(pos, to: node.parent!)
            moveActions.append(MoveAction(vector: convertedPOS))
        }
        
        node.removeAnimation(forKey: Animation.key)
        node.addAnimationPlayer(Animation.walk.player, forKey: Animation.key)
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
        let rotateVec = rotateVector(to: nextAction.vector)
        let rotateAction = SCNAction.rotateTo(x: 0, y: rotateVec.y.cg, z: 0, duration: 0.1)
    
        
        node.runAction(SCNAction.group([moveAction, rotateAction])) {
            guard !newActions.isEmpty else { completed(); return }
            self.run(newActions, completed: completed)
        }
    }
    
    private func nextPathPosition(_ index: Int, paths: [GKGridGraphNode], grid: SCNNode) -> SCNVector3? {
        let node = component(ofType: GKSCNNodeComponent.self)!.node
        if index + 1 <= (paths.count - 1) {
            let nextPath = paths[index + 1]
            let nextPos = SCNVector3(Int(nextPath.gridPosition.x), 0, Int(nextPath.gridPosition.y))
            return grid.convertPosition(nextPos, to: node.parent!)
        }
        
        return nil
    }
    
    private func rotateVector(to vector: SCNVector3) -> SCNVector3 {
        let node = component(ofType: GKSCNNodeComponent.self)!.node
        let lengthZ = vector.z - node.presentation.position.z
        let lengthX = vector.x - node.presentation.position.x
        let direction = float2(x: lengthX, y: lengthZ)
        let normalized = normalize(direction)
        let degrees: CGFloat = atan2(CGFloat(normalized.x), CGFloat(normalized.y)).radiansToDegrees()
        
        let nearest = [0, 90, -90, 180, -180].nearestElement(to: degrees)
        return SCNVector3(0, CGFloat(shortestAngleBetween(CGFloat(node.position.y), angle2: nearest.degreesToRadians())), 0)
    }
}

struct MoveAction {
    let vector: SCNVector3
}
