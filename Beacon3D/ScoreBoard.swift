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
        
        fillColor = UIColor(netHex: Config.GameBoardColor)
        strokeColor = UIColor(netHex: Config.BorderColor)
        lineWidth = Config.BorderWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAvatar(isOpponent: Bool) {
        if isOpponent {
            labelScore.fontColor = UIColor(netHex: Config.AvatarOpponentColor)
        } else {
            labelScore.fontColor = UIColor(netHex: Config.AvatarColor)
        }
    }
    
    func addScore() {
        
    }
}