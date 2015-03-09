//
//  GameViewController.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/11/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import UIKit
import SpriteKit

protocol MotionEndedDelegate {
    func didMotionEnded(motion: UIEventSubtype, withEvent event: UIEvent)
}

class GameViewController: UIViewController {

	@IBOutlet weak var gamingView: SKView!
	@IBOutlet weak var settingView: UIView!
	
    var motionEndedDelegate: MotionEndedDelegate!
    var mainScene: MainScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Configure the view.
        let skView = gamingView as SKView
        skView.multipleTouchEnabled = false
        
        // 禁止屏幕自动熄灭。
        UIApplication.sharedApplication().idleTimerDisabled = true
        
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
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motionEndedDelegate != nil {
            motionEndedDelegate.didMotionEnded(motion, withEvent: event)
        }
    }
}
