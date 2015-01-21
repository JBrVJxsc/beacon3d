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

    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let filteredSubviews = self.view.subviews.filter({
//            $0.isKindOfClass(UIImageView) })
//        // 2
//        for view in filteredSubviews  {
//            // 3
//            let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
//            // 4
//            recognizer.delegate = self
//            view.addGestureRecognizer(recognizer)
//            
//            //TODO: Add a custom gesture recognizer too
//        }
        
        
//        println(self.view.subviews[0])
//        println(self.view.subviews[1])
        
//        let recognizer = UILongPressGestureRecognizer(target: view, action: "handleLongPress")
//        
//        recognizer.delegate = scene as SKScene
        
        // Configure the view.

        let skView = view as SKView
        skView.multipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        // Present the scene.
        skView.presentScene(scene)
        
        
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
