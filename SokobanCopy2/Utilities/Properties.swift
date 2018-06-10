//
//  Properties.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/29/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit

enum MovementType {
    case guided
    case manual
}

let MOVEMENT_TYPE_NOTIFICATION_NAME = NSNotification.Name(rawValue: String(describing: MOVEMENT_TYPE))

let CHARACTER_MOVE_AMT: Float = 2
let GRID_WIDTH_HEIGHT: Float = CHARACTER_MOVE_AMT
let DEFINED_ROTATIONS: [CGFloat] = [0, 90, -90, 180, -180]


var GRID_ALLOWS_DIAGONAL = false
var CAMERA_FOLLOWS_ROTATION = true
var SHOW_DEBUG_HUD = true
var MOVEMENT_TYPE: MovementType = .manual {
    didSet {
        NotificationCenter.default.post(name: MOVEMENT_TYPE_NOTIFICATION_NAME, object: MOVEMENT_TYPE)
    }
}
