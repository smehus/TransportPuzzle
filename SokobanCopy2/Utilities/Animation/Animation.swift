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
    case push
    case idle
    
    private static let pushAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/pushing.dae")!
    private static let walkAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/walking.dae")!
    private static let walkStopAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/walk_stop.dae")!
    private static let toughWalkAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/tough_walk.dae")!
    private static let idleAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/idle.dae")!
    
    var player: SCNAnimationPlayer {
        switch self {
        case .walk: return Animation.walkStopAnimation
        case .push: return Animation.pushAnimation
        case .idle: return Animation.idleAnimation
        }
    }
    
    var animationDuration: TimeInterval {
        switch self {
        case .walk:
            return Animation.walk.player.animation.duration
        case .push:
            return Animation.push.player.animation.duration
        case .idle:
            return Animation.idle.player.animation.duration
        }
    }
}
