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

final class GameViewController: UIViewController {

    private var scene: SCNScene!
    private var scnView: SCNView!
    private var player: SCNNode!
    private var plane: SCNNode!
    private var box: SCNNode!
    private var character: SCNNode!
    private var lastUpdate: TimeInterval = 0
    private var walkingAnimation: CAAnimation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = self.view as! SCNView
        scnView.delegate = self

        scene = SCNScene(named: "art.scnassets/game.scn")!
        scene.physicsWorld.contactDelegate = self
        scnView.scene = scene

        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        setupCollisions()
        setupNodes()
        setupAnimations()
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

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let colliderTypeA = ColliderType(rawValue: contact.nodeA.physicsBody!.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.nodeB.physicsBody!.categoryBitMask)
        
        // Determine which `ColliderType` should be notified of the contact.
        let aWantsCallback = colliderTypeA.notifyOnContactWith(colliderTypeB)
        let bWantsCallback = colliderTypeB.notifyOnContactWith(colliderTypeA)
        
        guard aWantsCallback || bWantsCallback else { return }
        
        let box = colliderTypeA == .box ? contact.nodeA : contact.nodeB
        
        ColliderType.shouldNotify[colliderTypeA] = false
        ColliderType.shouldNotify[colliderTypeB] = false
        
        var moveVector = box.position
        switch contact.contactNormal {
        case _ where contact.contactNormal.x == -1:
            moveVector.x += 1
        case _ where contact.contactNormal.x == 1:
            moveVector.x -= 1
        case _ where contact.contactNormal.z == -1:
            moveVector.z += 1
        case _ where contact.contactNormal.z == 1:
            moveVector.z -= 1
        default: break
        }
        
        let action = SCNAction.move(to: moveVector, duration: 0.3)
        let wait = SCNAction.run { _ in
            ColliderType.shouldNotify[colliderTypeA] = true
            ColliderType.shouldNotify[colliderTypeB] = true
        }
        
        box.runAction(SCNAction.sequence([action, wait]))
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {


    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
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
    
    private func setupAnimations() {
        walkingAnimation = CAAnimation.animationWithScene(named: "art.scnassets/walkingAnimation.scn")
        character.addAnimation(walkingAnimation, forKey: "Walk")
    }
    
    private func setupCollisions() {
        
        ColliderType.shouldNotify[.player] = true
        ColliderType.shouldNotify[.box] = true
        
        ColliderType.requestedContactNotifications[.player] = [.box]
        
        ColliderType.requestedContactNotifications[.box] = [.player]
        ColliderType.requestedContactNotifications[.player] = [.box]
        
        ColliderType.definedCollisions[.player] = [.box]
        ColliderType.definedCollisions[.box] = [.player, .plane]
        ColliderType.definedCollisions[.plane] = [.box]
    }
    
    private func setupNodes() {
        
        character = scene.rootNode.childNode(withName: "character", recursively: true)

        player = scene.rootNode.childNode(withName: "player", recursively: true)
        player.physicsBody!.categoryBitMask = ColliderType.player.categoryMask
        player.physicsBody!.contactTestBitMask = ColliderType.player.contactMask
        player.physicsBody!.collisionBitMask = ColliderType.player.collisionMask
        
        box = scene.rootNode.childNode(withName: "box", recursively: true)
        box.physicsBody!.categoryBitMask = ColliderType.box.categoryMask
        box.physicsBody!.collisionBitMask = ColliderType.box.collisionMask
        box.physicsBody!.contactTestBitMask = ColliderType.box.contactMask
        
        plane = scene.rootNode.childNode(withName: "plane", recursively: true)
        plane.physicsBody!.categoryBitMask = ColliderType.plane.categoryMask
        plane.physicsBody!.collisionBitMask = ColliderType.plane.collisionMask
        plane.physicsBody!.contactTestBitMask = ColliderType.plane.contactMask
    }
}

extension CAAnimation {
    static func animationWithScene(named name: String) -> CAAnimation? {
        var animation: CAAnimation?
        if let scene = SCNScene(named: name) {
            scene.rootNode.enumerateChildNodes { (node, stop) in
                if node.animationKeys.count > 0 {
                    animation = node.animation(forKey: node.animationKeys.first!)
                    stop.initialize(to: true)
                }
            }
        }
        
        return animation
    }
}
