//
//  Ball.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/12/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

enum Ball {
    
    static func getBall (circleOfRadius: CGFloat, position: CGPoint) -> SKShapeNode {
        let ball = SKShapeNode(circleOfRadius: circleOfRadius)
        ball.fillColor = UIColor(netHex: Config.BallColor)
        ball.strokeColor = UIColor(netHex: Config.BallColor)
        ball.position = position
        ball.name = Config.BallCategoryName
        ball.physicsBody = SKPhysicsBody(circleOfRadius: circleOfRadius)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.friction = 0
        ball.physicsBody!.restitution = 1
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.angularDamping = 0
        ball.physicsBody!.categoryBitMask = Config.BallCategory
        return ball
    }
    
    static func getSafePosition (var x: CGFloat, var y: CGFloat) -> CGPoint {
        x = max(Config.BallPositionMinX, min(Config.BallPositionMaxX, x))
        y = max(Config.BallPositionMinY, min(Config.BallPositionMaxY, y))
        return CGPoint(x: x, y: y)
    }
}
