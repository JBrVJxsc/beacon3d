//
//  ScoreBoard.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 3/2/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

class ScoreBoard: SKShapeNode {
    
    let labelScore = SKLabelNode(text: "")
    var score: Int = 0
    
    override init() {
        super.init()
        fillColor = UIColor(netHex: Config.GameBoardColor)
        strokeColor = UIColor(netHex: Config.BorderColor)
        lineWidth = Config.ScoreBoardBorderWidth
        
        labelScore.fontName = "HelveticaNeue-Bold"
        labelScore.fontSize = labelScore.fontSize * 1.5
        labelScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelScore.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        addChild(labelScore)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(delay: NSTimeInterval) {
        hidden = false
        let delay = SKAction.waitForDuration(delay)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.6)
        let bigger = SKAction.scaleTo(1.1, duration: 0.2)
        bigger.timingMode = .EaseIn
        let biggerSmaller = SKAction.scaleTo(0.9, duration: 0.1)
        let biggerSmallerBigger = SKAction.scaleTo(1.0, duration: 0.1)
        let group = SKAction.group([fadeIn, SKAction.sequence([bigger, biggerSmaller, biggerSmallerBigger])])
        let seq = SKAction.sequence([delay, group])
        runAction(seq, completion: { () -> Void in
            self.setScore(0)
        })
    }
    
    func setAvatar(isOpponent: Bool) {
        if isOpponent {
            labelScore.fontColor = UIColor(netHex: Config.AvatarOpponentColor)
        } else {
            labelScore.fontColor = UIColor(netHex: Config.AvatarColor)
        }
    }
    
    func addScore() {
        score++
        setScore(score)
    }
    
    func setScore(score: Int) {
        let bigger = SKAction.scaleTo(1.1, duration: 0.15)
        bigger.timingMode = .EaseOut
        let smaller = SKAction.scaleTo(0, duration: 0.15)
        smaller.timingMode = .EaseIn
        labelScore.runAction(SKAction.sequence([bigger, smaller]), completion: { () -> Void in
            self.labelScore.text = String(score)
            let bigger = SKAction.scaleTo(1.1, duration: 0.2)
            bigger.timingMode = .EaseIn
            let biggerSmaller = SKAction.scaleTo(0.9, duration: 0.1)
            let biggerSmallerBigger = SKAction.scaleTo(1.0, duration: 0.1)
            let seq = SKAction.sequence([bigger, biggerSmaller, biggerSmallerBigger])
            self.labelScore.runAction(seq)
        })
    }
}