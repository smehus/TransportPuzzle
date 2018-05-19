//
//  HiddenCollisionEntity.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

final class HiddenCollisionEntity: GKEntity {
    
    private var character: CharacterEntity? = EntityManager.shared.entity()
    
    init(node: SCNNode) {
        super.init()
        
        let hiddenLeft = node.childNode(withName: "left", recursively: true)
        hiddenLeft!.physicsBody!.categoryBitMask = ColliderType.hiddenLeft.categoryMask
        hiddenLeft!.physicsBody!.contactTestBitMask = ColliderType.hiddenLeft.contactMask
        
        let hiddenRight = node.childNode(withName: "right", recursively: true)
        hiddenRight!.physicsBody!.categoryBitMask = ColliderType.hiddenRight.categoryMask
        hiddenRight!.physicsBody!.contactTestBitMask = ColliderType.hiddenRight.contactMask
        
        let hiddenFront = node.childNode(withName: "front", recursively: true)
        hiddenFront!.physicsBody!.categoryBitMask = ColliderType.hiddenFront.categoryMask
        hiddenFront!.physicsBody!.contactTestBitMask = ColliderType.hiddenFront.contactMask
        
        let hiddenBack = node.childNode(withName: "back", recursively: true)
        hiddenBack!.physicsBody!.categoryBitMask = ColliderType.hiddenBack.categoryMask
        hiddenBack!.physicsBody!.contactTestBitMask = ColliderType.hiddenBack.contactMask
        

        addComponent(GKSCNNodeComponent(node: node))
        addComponent(HiddenCollisionComponent())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        super.update(deltaTime: seconds)
        guard let charNode = character?.component(ofType: GKSCNNodeComponent.self)?.node else { return }
        guard let node = component(ofType: GKSCNNodeComponent.self)?.node else { return }
        
        node.position = charNode.position
    }
    
    func collision(for direction: ControlDirection) -> ColliderType? {
        return component(ofType: HiddenCollisionComponent.self)?.collision(for: direction)
    }
}
