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
        
        let debugButton = UIButton(type: .roundedRect)
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugButton)
        debugButton.addTarget(self, action: #selector(debugOpen(sender:)), for: .touchUpInside)
        debugButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        debugButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        debugButton.setTitle("Debug", for: .normal)
        debugButton.setTitleColor(.green, for: .normal)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc private func debugOpen(sender: UIButton) {
        let actionSheet = UIAlertController(title: "Debug", message: "", preferredStyle: .actionSheet)
        
        let guided = UIAlertAction(title: "Guided Movement", style: .default) { (action) in
            MOVEMENT_TYPE = .guided
        }

        let manual = UIAlertAction(title: "Manual Movement", style: .default) { (action) in
            MOVEMENT_TYPE = .manual
        }
        
        actionSheet.addAction(guided)
        actionSheet.addAction(manual)
     
        present(actionSheet, animated: true, completion: nil)
    }
}
