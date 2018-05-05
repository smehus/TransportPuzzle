//
//  GameViewController.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/5/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

struct CollisionMask: OptionSet {
    var rawValue: Int

    static let player = CollisionMask(rawValue: 0x1 << 0)
    static let box = CollisionMask(rawValue: 0x1 << 1)
    static let plane = CollisionMask(rawValue: 0x1 << 2)
}

final class GameViewController: UIViewController {

    private var scene: SCNScene!
    private var scnView: SCNView!
    private var player: SCNNode!
    private var plane: SCNNode!
    private var box: SCNNode!
    private var lastUpdate: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = self.view as! SCNView
        scnView.delegate = self
        scene = SCNScene(named: "art.scnassets/game.scn")!
        scnView.scene = scene

        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        setupNodes()
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: scnView)
        guard let hit = scnView.hitTest(location, options: nil).first else { return }
        
        let coord = hit.worldCoordinates
        
        let zOFfset = abs(coord.z.distance(to: player.position.z))
        let xOffset = abs(coord.x.distance(to: player.position.x))
        
        var moveVector = SCNVector3(player.position.x, player.position.y, player.position.z)
        
        if zOFfset.isLess(than: xOffset) {
            // use x value
            switch coord {
            case _ where coord.x < player.position.x:
                moveVector.x -= 1
            case _ where coord.x > player.position.x:
                moveVector.x += 1
            default: break
            }
        } else {
            // use z value
            switch coord {
            case _ where coord.z < player.position.z:
                moveVector.z -= 1
            case _ where coord.z > player.position.z:
                moveVector.z += 1
            default: break
            }
        }
        
        let wait = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.scnView.isUserInteractionEnabled = true
            }
        }
        let move = SCNAction.move(to: moveVector, duration: 0.3)
        scnView.isUserInteractionEnabled = false
        player.runAction(SCNAction.sequence([move, wait]))
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let _ = Double(time - lastUpdate)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    }
}

extension GameViewController {
    private func setupNodes() {
        player = scene.rootNode.childNode(withName: "player", recursively: true)
        player.physicsBody?.categoryBitMask = CollisionMask.player.rawValue
        let playerMask: CollisionMask = [.box, .plane]
        player.physicsBody?.collisionBitMask = playerMask.rawValue
        
        box = scene.rootNode.childNode(withName: "box", recursively: true)
        let boxMask: CollisionMask = [.player, .plane]
        box.physicsBody?.categoryBitMask = boxMask.rawValue
        
        plane = scene.rootNode.childNode(withName: "plane", recursively: true)
        let planeMask: CollisionMask = [.box, .player]
        plane.physicsBody?.categoryBitMask = planeMask.rawValue
    }
}
