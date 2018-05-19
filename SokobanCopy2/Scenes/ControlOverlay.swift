//
//  ControlOverlay.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

enum ControlDirection: String {
    case bottom, top, left, right
}

final class ControlOverlay: SKScene {
    
    private let topNode: SKShapeNode
    private let bottomNode: SKShapeNode
    private let leftNode: SKShapeNode
    private let rightNode: SKShapeNode
    
    init(size: CGSize, controller: GameController) {
        topNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width/4, y: size.height/2), size: CGSize(width: size.width/2, height: size.height/2)))
        bottomNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width/4, y: size.height/2), size: CGSize(width: size.width/2, height: size.height/2)))
        leftNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width/4, y: size.height/2), size: CGSize(width: size.width/2, height: size.height/2)))
        rightNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width/4, y: size.height/2), size: CGSize(width: size.width/2, height: size.height/2)))
        
        super.init(size: size)
        scaleMode = .resizeFill
        
        topNode.name = ControlDirection.top.rawValue
        topNode.fillColor = .blue
        addChild(topNode)
        
        bottomNode.name = ControlDirection.bottom.rawValue
        bottomNode.fillColor = .green
        addChild(bottomNode)
        
        leftNode.name = ControlDirection.left.rawValue
        leftNode.fillColor = .red
        addChild(leftNode)
        
        rightNode.name = ControlDirection.right.rawValue
        rightNode.fillColor = .yellow
        addChild(rightNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let characterEntity: CharacterEntity = EntityManager.shared.entity() else { assertionFailure(); return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if let name = tappedNodes.first?.name,
            let control = ControlDirection(rawValue: name) {
            
            switch control {
            case .top: return
            case .bottom: return
            case .left: return
            case .right: return
            }
        }
    }
}
