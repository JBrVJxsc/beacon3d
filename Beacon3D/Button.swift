//
//  Button.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/12/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

protocol ButtonPressDelegate {
    func didPress(sender: Button)
    func didLongPress(sender: Button)
}

class Button: SKShapeNode {
    
    var allowLongPress: Bool = true
    var timer: NSTimer!
    var firstFire: Bool = false
    var isWaiting: Bool = false
    var isLongPress: Bool = false
    var isAnimating: Bool = false
    var buttonPressDelegate: ButtonPressDelegate!
    var buttonBorder: SKShapeNode!
    var scale: CGFloat = 1.0
    
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
    
    override func setScale(scale: CGFloat) {
        super.setScale(scale)
        self.scale = scale
    }
    
    func startShining(duration: NSTimeInterval) {
        let smaller = SKAction.scaleTo(scale * 0.8, duration: duration)
        smaller.timingMode = .EaseOut
        let bigger = SKAction.scaleTo(scale * 1.1, duration: 0.2)
        bigger.timingMode = .EaseIn
        let biggerSmaller = SKAction.scaleTo(scale * 0.9, duration: 0.1)
        let biggerSmallerBigger = SKAction.scaleTo(scale * 1.0, duration: 0.1)
        let forever = SKAction.repeatActionForever(SKAction.sequence([smaller, bigger, biggerSmaller, biggerSmallerBigger]))
        runAction(forever)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (allowLongPress) {
        
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
        }
        
        fillColor = UIColor(netHex: Config.ButtonBorderColor)
        strokeColor = UIColor(netHex: Config.ButtonBorderColor)    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if (allowLongPress) {
            timer.invalidate()
        }
        
        if !isWaiting {
            fillColor = UIColor(netHex: Config.ButtonColor)
            strokeColor = UIColor(netHex: Config.ButtonColor)
        }
        
        if !isLongPress {
            buttonPressDelegate.didPress(self)
        } else {
            isLongPress = false
        }
    }
    
    func fire() {
        if firstFire {
            firstFire = false
            return
        }
        buttonPressDelegate.didLongPress(self)
        isLongPress = true
        timer.invalidate()
        
        isWaiting = !isWaiting
        
        isAnimating = true
        
        if isWaiting {
            let bigger = SKAction.scaleTo(scale * 1.1, duration: 0.25)
            bigger.timingMode = .EaseOut
            let smaller = SKAction.scaleTo(scale * 0.6, duration: 0.2)
            smaller.timingMode = .EaseIn
            let smallerBigger = SKAction.scaleTo(scale * 0.7, duration: 0.1)
            let smallerBiggerSmaller = SKAction.scaleTo(scale * 0.6, duration: 0.1)
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
            let smaller = SKAction.scaleTo(scale * 0.5, duration: 0.2)
            smaller.timingMode = .EaseOut
            let bigger = SKAction.scaleTo(scale * 1.1, duration: 0.2)
            bigger.timingMode = .EaseIn
            let biggerSmaller = SKAction.scaleTo(scale * 0.9, duration: 0.1)
            let biggerSmallerBigger = SKAction.scaleTo(scale * 1.0, duration: 0.1)
            runAction(SKAction.group([fadeIn, SKAction.sequence([smaller, bigger, biggerSmaller, biggerSmallerBigger])]), completion: { () -> Void in
                self.isAnimating = false
            })
        }
    }
}
