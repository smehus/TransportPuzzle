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
        
/*
        node.position = playerNode.position
        
        if CAMERA_FOLLOWS_ROTATION {
            // Needs to be the opposite?
            var playerRot = playerNode.rotation
            switch Int(round(playerRot.y.cg.radiansToDegrees())) {
            case 0:
                playerRot.w = 180
            case 90:
                playerRot.w = -90
            case 180:
                playerRot.w = 0
            case -90:
                playerRot.w = 90
            default: break
            }
            
            node.rotation = playerRot
        }
         */
    }
}

