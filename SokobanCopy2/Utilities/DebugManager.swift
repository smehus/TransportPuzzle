//
//  DebugManager.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 6/10/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

final class DebugManager {
    
    static let shared = DebugManager()
    
    var hudNode: SCNNode!
    var labelNode: SKLabelNode!
    
    func updateHud(string: String) {
        labelNode.text = string
        print(string)
    }
    
    private init() {
        setupHUD()
    }
    
    private func setupHUD() {
        let skScene = SKScene(size: CGSize(width: 500, height: 100))
        skScene.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        
        labelNode = SKLabelNode(fontNamed: "AmericanTypewriter-CondensedLight")
        labelNode.fontSize = 20
        labelNode.fontColor = .black
        labelNode.position.y = 50
        labelNode.position.x = 200
        skScene.addChild(labelNode)
        
        let plane = SCNPlane(width: 20, height: 2)
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.constant
        material.isDoubleSided = true
        material.diffuse.contents = skScene
        plane.materials = [material]
        
        hudNode = SCNNode(geometry: plane)
        hudNode.name = "HUD"
        let degrees = CGFloat(integerLiteral: 180).degreesToRadians()
        hudNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(degrees))
        hudNode.position = SCNVector3(x: 5, y: 0 , z: -6)
    }
}
