//
//  HighlighterEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/31/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class HighlighterEntity: GKEntity {
    
    init(position: SCNVector3) {
        super.init()
        
        let node = HighlighterNode()
        node.position = position
        
        addComponent(GKSCNNodeComponent(node: node))
        addComponent(RemoveOnContactComponent(collider: ColliderType.highlighter.union(.player)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HighlighterEntity: RemovableEntity {
    func removeFromManager() {
        EntityManager.shared.remove(self)
    }
}
