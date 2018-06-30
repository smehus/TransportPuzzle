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
    
    enum AnimationKey: String {
        case walk = "walking_animation"
        case idle = "idle_animation"
        case push = "pushing_animation"
        case step = "step_animation"
    }
    
    // Outfit Character
    private static let walkingAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/cube_character_walking.dae")!
    private static let idleAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/cube_character_idle.dae")!
    private static let pushingAnimation = CAAnimation.animationWithScene(named: "art.scnassets/Character/cube_character_pushing.dae")!
    
    var player: SCNAnimationPlayer {
        switch self {
        case .idle: return Animation.idleAnimation
        case .walk: return Animation.walkingAnimation
            
            
        case .push: return Animation.pushingAnimation
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
            return Animation.push.player.animation.duration
        case .idle:
            return Animation.idle.player.animation.duration
        }
    }
    
    var animationKey: String {
        switch self {
        case .walk: return AnimationKey.walk.rawValue
        case .idle: return AnimationKey.idle.rawValue
        case .push: return AnimationKey.push.rawValue
        case .step: return AnimationKey.step.rawValue
        }
    }
    
    static func animation(for key: String) -> Animation? {
        guard let animKey = AnimationKey(rawValue: key) else { return nil }
        switch animKey {
        case .push: return .push
        case .walk: return .walk
        case .step: return .walk
        case .idle: return .idle
        }
    }
}
