//
//  GameScene.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 2/21/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

class MainScene: SKScene, ButtonPressDelegate {
    
    let buttonPlay = Button(circleOfRadius: Config.ButtonRadius)
    let buttonConfigure = Button(circleOfRadius: Config.ButtonRadius)
    let buttonRanking = Button(circleOfRadius: Config.ButtonRadius)
    
    var skView: SKView!
    var gameScene: GameScene!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        initBackground()
        initButtons()
    }
    
    func initButtons() {
        buttonPlay.buttonPressDelegate = self
        buttonPlay.position = CGPoint(x: Config.ScreenWidth / 1.8, y: -Config.ScreenHeight / 3.0)
        let labelPlay = SKLabelNode(text: "Play")
        labelPlay.fontName = "HelveticaNeue-Bold"
        labelPlay.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelPlay.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonPlay.addChild(labelPlay)
        buttonPlay.startShining(2.5)
        
        buttonConfigure.buttonPressDelegate = self
        buttonConfigure.position = CGPoint(x: Config.ScreenWidth / 3.1, y: -Config.ScreenHeight / 1.5)
        buttonConfigure.setScale(0.75)
        let labelConfigure = SKLabelNode(text: "Configure")
        labelConfigure.fontName = "HelveticaNeue-Bold"
        labelConfigure.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelConfigure.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonConfigure.addChild(labelConfigure)
        buttonConfigure.startShining(2)

        
        buttonRanking.buttonPressDelegate = self
        buttonRanking.position = CGPoint(x: Config.ScreenWidth / 1.3, y: -Config.ScreenHeight / 1.63)
        buttonRanking.setScale(0.5)
        let labelRanking = SKLabelNode(text: "Ranking")
        labelRanking.fontName = "HelveticaNeue-Bold"
        labelRanking.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelRanking.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        buttonRanking.addChild(labelRanking)
        buttonRanking.startShining(1)
    }
    
    func initBackground() {
        let background = SKSpriteNode(color: UIColor(netHex: Config.BackgroungColor), size: Config.ScreenSize)
        background.position = Config.BackgroundPosition
        
        setAnorPoint([background])
        addChildren([background, buttonPlay, buttonConfigure, buttonRanking])
    }
    
    func didPress(sender: Button) {
        if sender == buttonPlay {
            skView.presentScene(gameScene, transition: SKTransition.fadeWithDuration(1.5))
        }
    }
    
    func didLongPress(sender: Button) {
        
    }
}