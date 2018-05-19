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
    
    var collider: ColliderType {
        switch self {
        case .bottom: return .hiddenFront
        case .top: return .hiddenBack
        case .left: return .hiddenLeft
        case .right: return .hiddenRight
        }
    }
}

final class ControlOverlay: SKScene {
    
    private let topNode: SKShapeNode
    private let bottomNode: SKShapeNode
    private let leftNode: SKShapeNode
    private let rightNode: SKShapeNode
    
    init(size: CGSize, controller: GameController) {
        topNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width/4, y: size.height/2), size: CGSize(width: size.width/2, height: size.height/2)))
        bottomNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width/4, y: 0), size: CGSize(width: size.width/2, height: size.height/2)))
        leftNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width/4, height: size.height)))
        rightNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width * 0.75, y: 0), size: CGSize(width: size.width/4, height: size.height)))
        
        super.init(size: size)
        scaleMode = .resizeFill
        
        topNode.name = ControlDirection.top.rawValue
        topNode.fillColor = .clear
        topNode.strokeColor = .clear
        addChild(topNode)
        
        bottomNode.name = ControlDirection.bottom.rawValue
        bottomNode.fillColor = .clear
        bottomNode.strokeColor = .clear
        addChild(bottomNode)
        
        leftNode.name = ControlDirection.left.rawValue
        leftNode.fillColor = .clear
        leftNode.strokeColor = .clear
        addChild(leftNode)
        
        rightNode.name = ControlDirection.right.rawValue
        rightNode.fillColor = .clear
        rightNode.strokeColor = .clear
        addChild(rightNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func highlightAction(color: UIColor, duration: TimeInterval = 0.1) -> SKAction {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node, elapsed) in
            guard
                let shape = node as? SKShapeNode
            else { return }

            let _ = (elapsed / CGFloat(duration)).clamped(to: 0...CGFloat(duration))
            shape.fillColor = color
        })

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        isUserInteractionEnabled = false
        
        if let name = tappedNodes.first?.name,
            let control = ControlDirection(rawValue: name) {
            
            var tappedNode: SKShapeNode
            switch control {
            case .top:
                tappedNode = topNode
            case .bottom:
                tappedNode = bottomNode
            case .left:
                tappedNode = leftNode
            case .right:
                tappedNode = rightNode
            }
            
            let highlight = highlightAction(color: UIColor.white.withAlphaComponent(0.2))
            let unhighlight = highlightAction(color: .clear)
            tappedNode.run(SKAction.sequence([highlight, unhighlight]))
            
            EntityManager.shared.controlOverlayDidSelect(direction: control)
        }
    }
}
