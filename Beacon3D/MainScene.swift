//
//  GameScene.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 2/21/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

class MainScene: SKScene, ButtonPressDelegate {
    
    var location = ESTLocation()
    let locationManager = ESTIndoorLocationManager()
    let buttonPlay = Button(circleOfRadius: Config.ButtonRadius)
    let buttonConfigure = Button(circleOfRadius: Config.ButtonRadius)
    let buttonRanking = Button(circleOfRadius: Config.ButtonRadius)
    
    var skView: SKView!
    var gameScene: GameScene!
    var viewController: UIViewController!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        initBackground()
        initButtons()
        initLocationManager()
    }
    
    func initLocationManager() {
        ESTConfig.setupAppID("app_28n6m2cfaq", andAppToken: "e6a2c5fcc28276a9ab28de9ea5961dd7")
    }
    
    func initButtons() {
        buttonPlay.buttonPressDelegate = self
        buttonPlay.allowLongPress = false
        buttonPlay.position = CGPoint(x: Config.ScreenWidth / 1.9, y: -Config.ScreenHeight / 2.31)
        let labelPlay = SKLabelNode(text: "Play")
        labelPlay.fontName = "HelveticaNeue-Bold"
        labelPlay.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelPlay.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonPlay.addChild(labelPlay)
        buttonPlay.startShining(1)
        
        buttonConfigure.buttonPressDelegate = self
        buttonConfigure.allowLongPress = false
        buttonConfigure.position = CGPoint(x: Config.ScreenWidth / 3.1, y: -Config.ScreenHeight / 1.25)
        buttonConfigure.setScale(0.75)
        let labelConfigure = SKLabelNode(text: "Configure")
        labelConfigure.fontName = "HelveticaNeue-Bold"
        labelConfigure.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelConfigure.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonConfigure.addChild(labelConfigure)
        buttonConfigure.startShining(2)
        
        buttonRanking.buttonPressDelegate = self
        buttonRanking.allowLongPress = false
        buttonRanking.position = CGPoint(x: Config.ScreenWidth / 1.3, y: -Config.ScreenHeight / 1.39)
        buttonRanking.setScale(0.5)
        let labelRanking = SKLabelNode(text: "Ranking")
        labelRanking.fontName = "HelveticaNeue-Bold"
        labelRanking.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelRanking.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonRanking.addChild(labelRanking)
        buttonRanking.startShining(2.5)
    }
    
    func initBackground() {
        let background = SKSpriteNode(color: UIColor(netHex: Config.BackgroungColor), size: Config.ScreenSize)
        background.position = Config.BackgroundPosition
        
        let title = SKLabelNode(text: "Beacon 3D")
        title.fontName = "HelveticaNeue-Bold"
        title.position = CGPoint(x: Config.ScreenWidth / 2, y: -Config.ScreenHeight / 6.5)
        title.fontSize = title.fontSize * 1.5
        
        setAnorPoint([background])
        addChildren([background, title, buttonPlay, buttonConfigure, buttonRanking])
    }
    
    func showLocationSetup() {
        let locationSetupVC = ESTIndoorLocationManager.locationSetupControllerWithCompletion { (location, error) in
            
            self.viewController.dismissViewControllerAnimated(true, completion: nil)
            if location == nil {
                
            } else {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(location.toDictionary(), forKey: "location")
            }
        }
        
        viewController.presentViewController(UINavigationController(rootViewController: locationSetupVC),
            animated: true,
            completion: nil)
    }
    
    func didPress(sender: Button) {
        if sender == buttonPlay {
            skView.presentScene(gameScene, transition: SKTransition.fadeWithDuration(1.5))
        } else if sender == buttonConfigure {
            let defaults = NSUserDefaults.standardUserDefaults()
            let location = defaults.dictionaryForKey("location")
            
//            if location != nil {
//                println(location)
//            } else {
//                showLocationSetup()
//            }
            showLocationSetup()
        }
    }
    
    func didLongPress(sender: Button) {
        
    }
}