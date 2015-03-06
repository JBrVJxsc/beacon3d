//
//  Extensions.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/11/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension SKScene {
    
    public func setAnorPoint(nodes: [SKSpriteNode]) {
        for node in nodes {
            node.anchorPoint = anchorPoint
        }
    }
    
    public func addChildren(nodes: [SKNode]) {
        for child in nodes {
            addChild(child)
        }
    }
}

extension SKShapeNode {
    
    public func startShining(interval: NSTimeInterval, fadeTo: CGFloat) {
        let fadeOut = SKAction.fadeAlphaTo(fadeTo, duration: interval / 2)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: interval / 2)
        let seq = SKAction.repeatActionForever(SKAction.sequence([fadeOut, fadeIn]))
        runAction(seq)
    }
    
    public func stopShining() {
        removeAllActions()
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 1)
        runAction(fadeIn)
    }

    public func addChildren(nodes: [SKNode]) {
        for child in nodes {
            addChild(child)
        }
    }
}

extension SKSpriteNode {
    public func addChildren(nodes: [SKNode]) {
        for child in nodes {
            addChild(child)
        }
    }
}