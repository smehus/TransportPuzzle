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
    case altStep
    case push
    
    private static let pushAnimation = CAAnimation.animationWithScene(named: "art.scnassets/character_push.dae")!
    private static let stepAnimation = CAAnimation.animationWithScene(named: "art.scnassets/character_step.dae")!
    private static let altStepAnimation = CAAnimation.animationWithScene(named: "art.scnassets/character_step.dae")!
    
    var player: SCNAnimationPlayer {
        switch self {
        case .step: return Animation.stepAnimation
        case .altStep: return Animation.altStepAnimation
        case .push: return Animation.pushAnimation
        }
    }
    
    var nextAnimation: Animation {
        switch self {
        case .step:
            return .altStep
        case .altStep:
            return .step
        default: return .step
        }
    }
    
    var animationDuration: TimeInterval {
        switch self {
        case .step, .altStep:
            return Animation.step.player.animation.duration
        case .push:
            return Animation.push.player.animation.duration
        }
    }
}
