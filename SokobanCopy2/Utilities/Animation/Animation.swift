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
    
    static let key = "animation"

    
    // Outfit Character
    private static let walkingAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/outfit_character_walking.dae")!
    private static let idleAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/outfit_character_idle.dae")!
    
    var player: SCNAnimationPlayer {
        switch self {
        case .idle: return Animation.idleAnimation
        case .walk: return Animation.walkingAnimation
            
            
        case .push: return Animation.idleAnimation
        case .step: return Animation.idleAnimation
        }
    }
    
    var animationDuration: TimeInterval {
        switch self {
        case .step:
            return Animation.step.player.animation.duration / 2
        case .walk:
            return Animation.walk.player.animation.duration
        case .push:
            return Animation.walk.player.animation.duration
        case .idle:
            return Animation.idle.player.animation.duration
        }
    }
}
