//
//  Button.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/12/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

protocol ButtonPressDelegate {
    func didPress()
    func didLongPress()
}

class Button: SKShapeNode {
    
    var timer: NSTimer!
    var firstFire: Bool = false
    var isWaiting: Bool = false
    var isLongPress: Bool = false
    var isAnimating: Bool = false
    var buttonPressDelegate: ButtonPressDelegate!
    var buttonBorder: SKShapeNode!
    
    override init() {
        super.init()
        
        userInteractionEnabled = true
        
        fillColor = UIColor(netHex: Config.ButtonColor)
        strokeColor = UIColor(netHex: Config.ButtonColor)
        position = Config.ButtonPosition
        name = Config.ButtonCategoryName
        buttonBorder = SKShapeNode(circleOfRadius: Config.ButtonRadius)
        buttonBorder.strokeColor = UIColor(netHex: Config.ButtonBorderColor)
        buttonBorder.lineWidth = Config.ButtonBorderWidth
        addChild(buttonBorder)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if isAnimating {
            return
        }
        
        if timer != nil {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(Config.ButtonLongPressInterval, target: self, selector: Selector("fire"), userInfo: nil, repeats: true)
        firstFire = true
        timer.fire()
        
        if isWaiting {
            return
        }
        
        fillColor = UIColor(netHex: Config.ButtonBorderColor)
        strokeColor = UIColor(netHex: Config.ButtonBorderColor)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        timer.invalidate()
        
        if !isLongPress {
            buttonPressDelegate.didPress()
        } else {
            isLongPress = false
        }
        
        if !isWaiting {
            fillColor = UIColor(netHex: Config.ButtonColor)
            strokeColor = UIColor(netHex: Config.ButtonColor)
        }
    }
    
    func fire() {
        if firstFire {
            firstFire = false
            return
        }
        buttonPressDelegate.didLongPress()
        isLongPress = true
        timer.invalidate()
        
        isWaiting = !isWaiting
        
        isAnimating = true
        
        if isWaiting {
            let bigger = SKAction.scaleTo(1.1, duration: 0.25)
            bigger.timingMode = .EaseOut
            let smaller = SKAction.scaleTo(0.6, duration: 0.2)
            smaller.timingMode = .EaseIn
            let smallerBigger = SKAction.scaleTo(0.7, duration: 0.1)
            let smallerBiggerSmaller = SKAction.scaleTo(0.6, duration: 0.1)
            runAction(SKAction.sequence([bigger, smaller,smallerBigger, smallerBiggerSmaller]), completion: { () -> Void in
                self.isAnimating = false
            })
            let fadeOut = SKAction.fadeAlphaTo(0.4, duration: 0.8)
            let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.8)
            let forever = SKAction.repeatActionForever(SKAction.sequence([fadeOut, fadeIn]))
            runAction(forever)
        } else {
            removeAllActions()
            let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.6)
            let smaller = SKAction.scaleTo(0.5, duration: 0.2)
            smaller.timingMode = .EaseOut
            let bigger = SKAction.scaleTo(1.1, duration: 0.2)
            bigger.timingMode = .EaseIn
            let biggerSmaller = SKAction.scaleTo(0.9, duration: 0.1)
            let biggerSmallerBigger = SKAction.scaleTo(1.0, duration: 0.1)
            runAction(SKAction.group([fadeIn, SKAction.sequence([smaller, bigger, biggerSmaller, biggerSmallerBigger])]), completion: { () -> Void in
                self.isAnimating = false
            })
        }
    }
}
