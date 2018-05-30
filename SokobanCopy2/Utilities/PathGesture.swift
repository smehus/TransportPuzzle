//
//  PathGesture.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/30/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import Foundation
import SceneKit
import UIKit.UIGestureRecognizerSubclass

final class PathGesture: UIGestureRecognizer {
    
    var lastLocation: SCNVector3?
    
    var scnView: SCNView {
        return view as! SCNView
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard lastLocation == nil else {
            state = .failed
            return
        }
        
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let _ = lastLocation else { return }
        
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let _ = lastLocation else { return }
        
        state = .ended
    }
    
    override func reset() {
        super.reset()
        lastLocation = nil
        print("resetting gesture")
    }
}
