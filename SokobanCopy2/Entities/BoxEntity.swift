//
//  BoxEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class BoxEntity: GKEntity {
    
    init(node: SCNNode) {
        super.init()
        
        node.physicsBody!.categoryBitMask = ColliderType.box.categoryMask
        node.physicsBody!.collisionBitMask = ColliderType.box.collisionMask
        node.physicsBody!.contactTestBitMask = ColliderType.box.contactMask
        node.physicsBody!.isAffectedByGravity = true
        node.entity = self
        
        addComponent(GKSCNNodeComponent(node: node))
        addComponent(NearestCoordinateComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class NearestCoordinateComponent: GKComponent {
    
    private var lastUpdate: TimeInterval = 0
    private var movePointsPerSecond: Float = 480.0
    
    var node: SCNNode {
        return entity!.component(ofType: GKSCNNodeComponent.self)!.node
    }
    
    var player: SCNNode {
        let playerEntity: CharacterEntity! = EntityManager.shared.entity()
        return playerEntity.component(ofType: GKSCNNodeComponent.self)!.node
    }
    
 
    override func update(deltaTime seconds: TimeInterval) {
        let delta = Double(seconds - lastUpdate)
        lastUpdate = seconds
        
        if node.physicsBody!.xzInert {
            if Double(node.presentation.simdPosition.x).truncatingRemainder(dividingBy: 2) > 0.2 || Double(node.presentation.simdPosition.z).truncatingRemainder(dividingBy: 2) > 0.2 {
                
                let newX = roundTwos(node.presentation.simdPosition.x)
                let newZ = roundTwos(node.presentation.simdPosition.z)
                let targetVector = float3(newX, 0, newZ)
                let offset = targetVector - node.presentation.simdPosition
                
                let length = sqrtf(offset.x * offset.x + offset.z * offset.z)
                let direction = float3(offset.x / length, 0, offset.z / length)
                let velocity = SCNVector3(direction.x, 0, direction.z)
                node.physicsBody!.velocity = velocity
            } else {
//                node.physicsBody!.velocity = .zero
            }
        }
    }
    
    func roundTwos( _ value: Float) -> Float {
        return 2 * (value / 2).rounded()
    }
}

extension SCNPhysicsBody {
    var xzInert: Bool {
        return velocity.x < 1 && velocity.z < 1
    }
}

extension SCNVector3 {
    static let min = SCNVector3(1, 0, 1)
    static let zero = SCNVector3(0, 0 , 0)
}

extension NearestCoordinateComponent: ControlOverlayResponder {
    func didSelect(direction: ControlDirection) { }
    func selectionChanged(direction: ControlDirection) { }
    
    func selectionDidEnd(direction: ControlDirection) {
//        let position = node.presentation.simdPosition
//        let newPos = SCNVector3(Int(round(position.x)), Int(round(position.y)), Int(round(position.z)))
//        node.runAction(SCNAction.move(to: newPos, duration: 0.3))
    }
}
