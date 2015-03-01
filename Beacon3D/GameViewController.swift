//
//  GameViewController.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/11/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

	@IBOutlet weak var gamingView: SKView!
	@IBOutlet weak var settingView: UIView!
	
    var mainScene: MainScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = gamingView as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        mainScene = MainScene(size: skView.bounds.size)
        mainScene.viewController = self
        mainScene.scaleMode = .AspectFill
        
        // Present the scene.        
        mainScene.skView = skView
        skView.presentScene(mainScene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
