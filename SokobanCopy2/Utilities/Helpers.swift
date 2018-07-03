//
//  Helpers.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/15/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit

public func shortestAngleBetween(_ angle1: CGFloat, angle2: CGFloat) -> CGFloat {
    let twoπ = π * 2.0
    var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
    if (angle >= π) {
        angle = angle - twoπ
    }
    if (angle <= -π) {
        angle = angle + twoπ
    }
    return angle
}

func po(_ string: String) {
    let threadCountString = "* 🤔: \(string) *"
    let surround = "".padding(toLength: threadCountString.count, withPad: "*", startingAt: 0)
    print(surround)
    print(threadCountString)
    print(surround)
}
