//
//  GameViewController.swift
//  SokobanCopy2
//
//  Created by Scott Mehus on 5/5/18.
//  Copyright © 2018 ScottMehus. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

final class GameViewController: UIViewController {

    private var scnView: SCNView!
    private var controller: GameController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scnView = self.view as! SCNView
        
        controller = GameController(scnView: scnView)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        controller.entityManager.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        controller.entityManager.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        controller.entityManager.touchesEnded(touches, with: event)
    }
 */
}
