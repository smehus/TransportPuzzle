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
    private var plane: SCNNode!
    private var box: SCNNode!
    private var character: SCNNode!
    private var lastUpdate: TimeInterval = 0
    private var lastAnimation: Animation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView = self.view as! SCNView
        scnView.delegate = self

        scene = SCNScene(named: "art.scnassets/game.scn")!
        scene.physicsWorld.contactDelegate = self
        scnView.scene = scene

        scnView.showsStatistics = true
        scnView.backgroundColor = UIColor.black
        scnView.debugOptions = [.showPhysicsShapes]
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
        let charPosition = scene.rootNode.convertPosition(character.position, from: character.parent!)
        
        let zOFfset = abs(coord.z.distance(to: charPosition.z))
        let xOffset = abs(coord.x.distance(to: charPosition.x))
        
        var moveVector = charPosition
        
        if zOFfset.isLess(than: xOffset) {
            // use x value
            switch coord {
            case _ where coord.x < charPosition.x:
                moveVector.x -= 1
            case _ where coord.x > charPosition.x:
                moveVector.x += 1
            default: break
            }
        } else {
            // use z value
            switch coord {
            case _ where coord.z < charPosition.z:
                moveVector.z -= 1
            case _ where coord.z > charPosition.z:
                moveVector.z += 1
            default: break
            }
        }
        
        
        let lengthY = coord.z - charPosition.z
        let lengthX = coord.x - charPosition.x
        let direction = float2(x: lengthX, y: lengthY)
        let normalized = normalize(direction)
        let degrees: CGFloat = atan2(CGFloat(normalized.x), CGFloat(normalized.y)).radiansToDegrees()
        
        let nearest = [0, 90, -90, 180, -180].nearestElement(to: degrees)
        // shortest angle only works with rotating by???
        let rotate = SCNAction.rotateTo(x: 0, y: CGFloat(shortestAngleBetween(CGFloat(charPosition.y), angle2: nearest.degreesToRadians())), z: 0.0, duration: 0.1)
        let wait = SCNAction.run { _ in
            DispatchQueue.main.async {
                self.scnView.isUserInteractionEnabled = true
                self.character.removeAllAnimations()
//                self.character.addAnimationPlayer(self.idleAnimation, forKey: "idle")
            }
        }
        
        scnView.isUserInteractionEnabled = false
        
        var animation: Animation = .step
        if let last = lastAnimation {
            animation = last.nextAnimation
        }
        
        let move = SCNAction.move(to: moveVector, duration: animation.animationDuration)
        character.addAnimationPlayer(animation.player, forKey: "walking")
        character.runAction(SCNAction.sequence([SCNAction.group([move, rotate]), wait]))
        
        lastAnimation = animation
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

        if abs(contact.contactNormal.x) > abs(contact.contactNormal.z) {
            switch contact.contactNormal {
            case _ where contact.contactNormal.x < 0:
                moveVector.x += 1
            case _ where contact.contactNormal.x > 0:
                moveVector.x -= 1
            default: break
            }
        } else {
            switch contact.contactNormal {
            case _ where contact.contactNormal.z < 0:
                moveVector.z += 1
            case _ where contact.contactNormal.z > 0:
                moveVector.z -= 1
            default: break
            }
        }


        
        let action = SCNAction.move(to: moveVector, duration: Animation.step.animationDuration)
        let wait = SCNAction.run { _ in
            ColliderType.shouldNotify[colliderTypeA] = true
            ColliderType.shouldNotify[colliderTypeB] = true
        }
        
        box.runAction(SCNAction.sequence([action, wait]))
        character.removeAllAnimations()
        character.addAnimationPlayer(Animation.push.player, forKey: "push")
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
//        character.addAnimationPlayer(idleAnimation, forKey: "idle")
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
        character = scene.rootNode.childNode(withName: "Character", recursively: true)
        
        let geom = SCNBox(width: 0.5, height: 2, length: 0.5, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: geom, options: nil)
        character.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        character.physicsBody!.categoryBitMask = ColliderType.player.categoryMask
        character.physicsBody!.contactTestBitMask = ColliderType.player.contactMask
        character.physicsBody!.collisionBitMask = ColliderType.player.collisionMask

        box = scene.rootNode.childNode(withName: "Cube", recursively: true)
        let boxGeom = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxShape = SCNPhysicsShape(geometry: boxGeom, options: nil)
        box.physicsBody = SCNPhysicsBody(type: .kinematic, shape: boxShape)
        box.physicsBody!.categoryBitMask = ColliderType.box.categoryMask
        box.physicsBody!.collisionBitMask = ColliderType.box.collisionMask
        box.physicsBody!.contactTestBitMask = ColliderType.box.contactMask
        
        plane = scene.rootNode.childNode(withName: "plane", recursively: true)
        plane.physicsBody!.categoryBitMask = ColliderType.plane.categoryMask
        plane.physicsBody!.collisionBitMask = ColliderType.plane.collisionMask
        plane.physicsBody!.contactTestBitMask = ColliderType.plane.contactMask
    }
}
