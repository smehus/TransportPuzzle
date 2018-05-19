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
        guard let node = component(ofType: GKSCNNodeComponent.self)?.node else { assertionFailure(); return }
        
        var vector = node.position
        switch controlDirection {
        case .left:
            vector.x -= 1
        case .right:
            vector.x += 1
        case .top:
            vector.z -= 1
        case .bottom:
            vector.z += 1
        }
        
        let lengthZ = vector.z - node.position.z
        let lengthX = vector.x - node.position.x
        let direction = float2(x: lengthX, y: lengthZ)
        let normalized = normalize(direction)
        let degrees: CGFloat = atan2(CGFloat(normalized.x), CGFloat(normalized.y)).radiansToDegrees()
        
        let nearest = [0, 90, -90, 180, -180].nearestElement(to: degrees)
        let rotate = SCNAction.rotateTo(x: 0, y: CGFloat(shortestAngleBetween(CGFloat(node.position.y), angle2: nearest.degreesToRadians())), z: 0.0, duration: 0.1)
        
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
    }
}
