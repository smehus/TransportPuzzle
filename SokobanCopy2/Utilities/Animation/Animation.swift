//
//  Animation.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/15/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit
import SceneKit

enum Animation {
    case walk
    case step
    case push
    case idle
    
    private static let pushAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/pushing.dae")!
    private static let closePushAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/close_push.dae")!
    private static let closePushLoopAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/close_push_loop.dae")!
    
    private static let walkAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/walking.dae")!
    private static let walkStopAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/walk_stop.dae")!
    private static let toughWalkAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/tough_walk.dae")!
    
    private static let idleAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/idle.dae")!
    private static let idleStraightAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/idle_straight.dae")!
    
    var player: SCNAnimationPlayer {
        switch self {
        case .step: return Animation.walkStopAnimation
        case .walk: return Animation.toughWalkAnimation
        case .push: return Animation.closePushLoopAnimation
        case .idle: return Animation.idleStraightAnimation
        }
    }
    
    var animationDuration: TimeInterval {
        switch self {
        case .step:
            return Animation.step.player.animation.duration / 2
        case .walk:
            return Animation.walk.player.animation.duration
        case .push:
            return Animation.push.player.animation.duration
        case .idle:
            return Animation.idle.player.animation.duration
        }
    }
}
