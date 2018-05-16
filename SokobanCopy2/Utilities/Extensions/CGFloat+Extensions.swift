//
//  CGFloat+Extensions.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/15/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit

let π = CGFloat(Double.pi)

public extension CGFloat {
    
    public func degreesToRadians() -> CGFloat {
        return π * self / 180.0
    }
    
    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / π
    }
}
