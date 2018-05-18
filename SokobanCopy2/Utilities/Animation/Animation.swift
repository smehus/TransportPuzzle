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
    case step
    case push
    case idle
    
    private static let pushAnimation = CAAnimation.animationWithScene(named: "art.scnassets/character_push.dae")!
    private static let stepAnimation = CAAnimation.animationWithScene(named: "art.scnassets/walking.dae")!
    private static let idleAnimation = CAAnimation.animationWithScene(named: "art.scnassets/idle.dae")!
    
    var player: SCNAnimationPlayer {
        switch self {
        case .step: return Animation.stepAnimation
        case .push: return Animation.pushAnimation
        case .idle: return Animation.idleAnimation
        }
    }
    
    var animationDuration: TimeInterval {
        switch self {
        case .step:
            return Animation.step.player.animation.duration
        case .push:
            return Animation.push.player.animation.duration
        case .idle:
            return Animation.idle.player.animation.duration
        }
    }
}
