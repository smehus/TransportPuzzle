//
//  CameraEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 6/1/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class CameraEntity: GKEntity {
    
    init(container: SCNNode) {
        super.init()
        addComponent(GKSCNNodeComponent(node: container))
        addComponent(CameraFollowComponent())
        
        setupCosntraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCosntraints() {

        guard let camera = component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        guard let player: CharacterEntity = EntityManager.shared.entity() else { return }
        guard let playerNode = player.component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        let orientationConstraint = SCNTransformConstraint(inWorldSpace: true) { (node, matrix) -> SCNMatrix4 in
            return playerNode.transform
        }
        orientationConstraint.influenceFactor = 0.1
        
        let replicator = SCNReplicatorConstraint(target: playerNode)
        replicator.replicatesOrientation = true
        replicator.replicatesPosition = true
        replicator.influenceFactor = 0.05
        
        let lookAtConstraint = SCNLookAtConstraint(target: playerNode)
        lookAtConstraint.influenceFactor = 0.07
        lookAtConstraint.isGimbalLockEnabled = false
        
        // distance constraints
        let follow = SCNDistanceConstraint(target: playerNode)
        let _ = CGFloat(simd_length(camera.simdPosition))
        follow.minimumDistance = 0
        follow.maximumDistance = 0
        follow.influenceFactor = 0.05
        
        let accelerationConstraint = SCNAccelerationConstraint()
        accelerationConstraint.maximumLinearVelocity = 1500
        accelerationConstraint.maximumLinearAcceleration = 100
        accelerationConstraint.damping = 0.5
        accelerationConstraint.influenceFactor = 1.0
        
        camera.constraints = [/*orientationConstraint,*/ accelerationConstraint, /*lookAtConstraint, follow ,*/ replicator]
    }
    
}
