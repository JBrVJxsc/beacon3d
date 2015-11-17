//
//  Ball.swift
//  Beacon3D
//
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

enum Avatar {
    
    static func getAvatar (circleOfRadius: CGFloat, position: CGPoint, isOpponent: Bool) -> SKShapeNode {
        let avatar = SKShapeNode(circleOfRadius: circleOfRadius)
        if isOpponent {
            avatar.fillColor = UIColor(netHex: Config.AvatarOpponentColor)
        } else {
            avatar.fillColor = UIColor(netHex: Config.AvatarColor)
        }
        avatar.position = position
        avatar.name = Config.AvatarCategoryName        
        let label = SKLabelNode(text: "^")
        label.fontName = "HelveticaNeue"
        label.fontSize = label.fontSize * 1.1
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        avatar.addChild(label)
        
        return avatar
    }
    
    static func getSafePosition (var x: CGFloat, var y: CGFloat) -> CGPoint {
        x = max(Config.AvatarPositionMinX, min(Config.AvatarPositionMaxX, x))
        y = max(Config.AvatarPositionMinY, min(Config.AvatarPositionMaxY, y))
        return CGPoint(x: x, y: y)
    }
}
