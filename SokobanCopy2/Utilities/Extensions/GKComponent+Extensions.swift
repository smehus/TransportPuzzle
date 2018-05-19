//
//  GKComponent+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/19/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import GameplayKit

extension GKComponent {
    func colliderForCollision(collider: ColliderType) -> ColliderType? {
        switch collider {
        case ColliderType.hiddenLeft.union(.box):
            return .hiddenLeft
        case ColliderType.hiddenRight.union(.box):
            return .hiddenRight
        case ColliderType.hiddenFront.union(.box):
            return .hiddenFront
        case ColliderType.hiddenBack.union(.box):
            return .hiddenBack
        default:
            return nil
        }
    }
}
