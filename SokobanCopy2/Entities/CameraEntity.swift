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
        
        camera.constraints = [orientationConstraint]
    }
    
}
