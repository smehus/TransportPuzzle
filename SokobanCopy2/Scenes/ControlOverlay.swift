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
    
    var moveVector: SCNVector3 {
        var vector = SCNVector3(0, 0, 0)
        switch self {
        case .bottom:
            vector.z += CHARACTER_MOVE_AMT
        case .top:
            vector.z -= CHARACTER_MOVE_AMT
        case .left:
            vector.x -= CHARACTER_MOVE_AMT
        case .right:
            vector.x += CHARACTER_MOVE_AMT
        }
        
        return vector
    }
}

final class ControlOverlay: SKScene {
    
    private let topNode: SKShapeNode
    private let bottomNode: SKShapeNode
    private let leftNode: SKShapeNode
    private let rightNode: SKShapeNode
    
    init(size: CGSize, controller: GameController) {
        
        leftNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width/4, height: size.height)))
        rightNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: size.width * 0.75, y: 0), size: CGSize(width: size.width/4, height: size.height)))
        
        topNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: size.height - size.height/4), size: CGSize(width: size.width, height: size.height/4)))
        bottomNode = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width, height: size.height/4)))
        
        super.init(size: size)
        scaleMode = .resizeFill

        
        leftNode.name = ControlDirection.left.rawValue
        leftNode.fillColor = .clear
        leftNode.strokeColor = .clear
        addChild(leftNode)
        
        rightNode.name = ControlDirection.right.rawValue
        rightNode.fillColor = .clear
        rightNode.strokeColor = .clear
        addChild(rightNode)
        
        topNode.name = ControlDirection.top.rawValue
        topNode.fillColor = .clear
        topNode.strokeColor = .clear
        addChild(topNode)
        
        bottomNode.name = ControlDirection.bottom.rawValue
        bottomNode.fillColor = .clear
        bottomNode.strokeColor = .clear
        addChild(bottomNode)
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
        
        guard let (tappedNode, control) = direction(for: touches) else { return }
        let highlight = highlightAction(color: UIColor.white.withAlphaComponent(0.2))
        let unhighlight = highlightAction(color: .clear)
        tappedNode.run(SKAction.sequence([highlight, unhighlight]))
        
        EntityManager.shared.controlOverlayDidSelect(direction: control)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        
    }
    
    private func direction(for touches: Set<UITouch>) -> (SKNode, ControlDirection)? {
        guard let touch = touches.first else { return nil }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if let name = tappedNodes.first?.name,
            let control = ControlDirection(rawValue: name) {
        
            switch control {
            case .top:
                return (topNode, control)
            case .bottom:
                return (bottomNode, control)
            case .left:
                return (leftNode, control)
            case .right:
                return (rightNode, control)
            }
        }
        
        return nil
    }
}
