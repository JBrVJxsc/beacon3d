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
    
    override init() {
        super.init()
        
        userInteractionEnabled = true
        
//        fillColor = UIColor(netHex: Config.GameBoardColor)
        strokeColor = UIColor(netHex: Config.BorderColor)
        lineWidth = Config.BorderWidth

//        let border = SKShapeNode(rectOfSize: Config.ScoreBoardSize)
//        border.strokeColor = UIColor(netHex: Config.ButtonBorderColor)
//        border.lineWidth = Config.ScoreBoardBorderWidth
//        addChild(border)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvatar(isOpponent: Bool) {
        
    }
    
    func addScore() {
        
    }
}