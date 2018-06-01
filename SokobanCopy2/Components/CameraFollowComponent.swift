//
//  CameraFollowComponent.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 6/1/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class CameraFollowComponent: GKComponent {
    
    var grid: SCNNode {
        let entity: PlaneEntity = EntityManager.shared.entity() as! PlaneEntity
        return entity.component(ofType: GKSCNNodeComponent.self)!.node
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        
        guard let cameraEntity = entity as? CameraEntity else { return }
        guard let node = cameraEntity.component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        guard let player: CharacterEntity = EntityManager.shared.entity() else { return }
        guard let playerNode = player.component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        node.position = playerNode.position
        
        if CAMERA_FOLLOWS_ROTATION {
            var angle = playerNode.presentation.eulerAngles.y
            if angle == 0 {
                angle = Float(CGFloat(180).degreesToRadians())
            } else if angle == Float(CGFloat(180).degreesToRadians()) {
                angle = 0
            } else {
                angle = -angle
            }
    
            node.runAction(SCNAction.rotateTo(x: 0, y: angle.cg, z: 0, duration: 0.3))
        }
    }
}
