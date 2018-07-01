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
    
    var node: SCNNode {
        return entity!.component(ofType: GKSCNNodeComponent.self)!.node
    }
    
 
    override func update(deltaTime seconds: TimeInterval) {
        let delta = Double(seconds - lastUpdate)
        lastUpdate = seconds
        
        if node.physicsBody!.velocity.x < 1 || node.physicsBody!.velocity.z < 1 {
            if node.presentation.simdPosition.x.truncatingRemainder(dividingBy: CHARACTER_MOVE_AMT) != 0 || node.presentation.simdPosition.z.truncatingRemainder(dividingBy: CHARACTER_MOVE_AMT) != 0 {
                print("updating position")
                let xDelta = Int(round(node.presentation.simdPosition.x))
                let zDelta = Int(round(node.presentation.simdPosition.z))
                
                node.position = SCNVector3(xDelta, 0, zDelta)
            }
        }
    }
    
}

extension SCNVector3 {
    static let min = SCNVector3(1, 0, 1)
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
