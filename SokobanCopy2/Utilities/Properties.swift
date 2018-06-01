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

let CHARACTER_MOVE_AMT: Float = 2
let GRID_WIDTH_HEIGHT: Float = CHARACTER_MOVE_AMT
let DEFINED_ROTATIONS: [CGFloat] = [0, 90, -90, 180, -180]


var GRID_ALLOWS_DIAGONAL = false
var CAMERA_FOLLOWS_ROTATION = false
var MOVEMENT_TYPE: MovementType = .guided
