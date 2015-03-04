//
//  GameScene.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/11/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit
import CoreMotion
import MultipeerConnectivity

protocol GameSceneExitDelegate {
    func gameSceneDidExit(sender: GameScene)
}

class GameScene: SKScene, SKPhysicsContactDelegate, MCBrowserViewControllerDelegate, ButtonPressDelegate, ESTIndoorLocationManagerDelegate {
    
    let ball = Ball.getBall(Config.BallRadius, position: Config.BallPosition)
    let button = Button(circleOfRadius: Config.ButtonRadius)
    let scoreBoardPlayer = ScoreBoard(rectOfSize: Config.ScoreBoardSize)
    let scoreBoardOpponent = ScoreBoard(rectOfSize: Config.ScoreBoardSize)
    var scoreBoardBox: SKSpriteNode!
    
    let avatar = Avatar.getAvatar(Config.AvatarRadius, position: Config.AvatarPosition, isOpponent: false)
    let avatarOpponent = Avatar.getAvatar(Config.AvatarRadius, position: Config.AvatarOpponentPosition, isOpponent: true)
    
    var mainMap: ESTLocation!
    let motionManager: CMMotionManager = CMMotionManager()
    var timer: NSTimer!
    var firstFire: Bool = true
    
    let labelHint = SKLabelNode(text: "")
    let hints = ["Hold", "To", "Create", "Game", "Touch", "To", "Join", "Game"]
    var hintIndex = 0
    
    var appDelegate: AppDelegate!
    var gameSceneExitDelegate: GameSceneExitDelegate!
    var viewController: UIViewController!
    
    var isHolder: Bool = false
    var isGaming: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        scaleMode = .AspectFill
        
        initBackground()
        initSensors()
        initMPC()
        initLabels()
        initAvatars()
        initHintTimer()
    }
    
    func initMPC() {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    
    func initSensors() {
        
        return
        
        if  motionManager.accelerometerAvailable {
            let speed = 18.0
            motionManager.accelerometerUpdateInterval = 1.0 / 30.0
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) {
                (data : CMAccelerometerData!, error: NSError!) in

                let x = self.ball.position.x + CGFloat(data.acceleration.x * speed)
                let y = self.ball.position.y + CGFloat(data.acceleration.y * speed)
                let move = SKAction.moveTo(Ball.getSafePosition(x, y: y), duration: self.motionManager.accelerometerUpdateInterval)
                self.ball.runAction(move)
                
                let messageDict = ["type": Enum.MoveAvatar.rawValue, "x": x, "y": y]
                let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
                
                self.appDelegate.mpcHandler.session.sendData(messageData, toPeers: self.appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: nil)
                
//          self.physicsWorld.gravity = CGVectorMake(CGFloat(data.acceleration.x * 2), CGFloat(data.acceleration.y * 2))
            }
        }
        
        //        if motionManager.gyroAvailable {
        //            motionManager.gyroUpdateInterval = 1.0 / 0.5
        //            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()) {
        //            (data : CMGyroData!, error: NSError!) in
        //                println(data.description)
        //            }
        //        }
    }
    
    func initHintTimer() {
        firstFire = true
        if timer != nil {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("hintFire"), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func hintFire() {
        if firstFire {
            firstFire = false
            return
        }
        animateHint(true)
        timer.invalidate()
    }
    
    func initAvatars() {
        let fadeOut = SKAction.fadeOutWithDuration(0.01)
        let rotate = SKAction.rotateByAngle(Math.degreesToRadians(180), duration: 0.01)
        avatar.runAction(fadeOut)
        avatarOpponent.runAction(SKAction.group([fadeOut, rotate]))
        avatar.hidden = true
        avatarOpponent.hidden = true
        
        addChildren([avatar, avatarOpponent])
    }
    
    func initLabels() {
        labelHint.fontName = "HelveticaNeue-Bold"
        labelHint.fontSize = labelHint.fontSize * 1.5
        labelHint.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelHint.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        let hintFadeOut = SKAction.fadeOutWithDuration(0.01)
        labelHint.runAction(hintFadeOut)
        
        button.addChild(labelHint)
    }
    
    func animateHint(b: Bool) {
        if b {
            let hintFadeDuration = 0.5
            let hintFadeIn = SKAction.fadeInWithDuration(hintFadeDuration)
            let hintFadeOut = SKAction.fadeOutWithDuration(hintFadeDuration)
            let actionHint = SKAction.sequence([hintFadeIn, hintFadeOut])
            labelHint.text = hints[hintIndex]
            labelHint.runAction(actionHint, completion: { () -> Void in
                self.hintIndex++
                if self.hintIndex == self.hints.count {
                    self.hintIndex = 0
                }
                self.animateHint(true)
            })
        } else {
            hintIndex = 0
            self.labelHint.removeAllActions()
            let hintFadeOut = SKAction.fadeOutWithDuration(0.5)
            labelHint.runAction(hintFadeOut, completion: { () -> Void in
                self.labelHint.text = "Wait"
                let wait = SKAction.waitForDuration(0.2)
                let fadeIn = SKAction.fadeInWithDuration(0.5)
                self.labelHint.runAction(SKAction.sequence([wait, fadeIn]))
            })
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == Config.BorderCategory && secondBody.categoryBitMask == Config.BallCategory {
            scoreBoardPlayer.addScore()
            scoreBoardOpponent.addScore()
        } else if firstBody.categoryBitMask == Config.AvatarCategory && secondBody.categoryBitMask == Config.BallCategory {
            scoreBoardPlayer.addScore()
            scoreBoardOpponent.addScore()
        } else if firstBody.categoryBitMask == Config.BallCategory && secondBody.categoryBitMask == Config.AvatarCategory {
            scoreBoardPlayer.addScore()
            scoreBoardOpponent.addScore()
        }
    }
    
    func startGame() {
        isGaming = true
        
        // 设置Button。
        button.allowLongPress = false
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.8)
        
        if isHolder {
            button.removeAllActions()
            button.runAction(fadeIn, completion: { () -> Void in
                self.button.isAnimating = false
                self.button.isWaiting = false
            })
            button.fillColor = UIColor(netHex: Config.ButtonColor)
            button.strokeColor = UIColor(netHex: Config.ButtonColor)
        }
        labelHint.removeAllActions()
        let fadeOut = SKAction.fadeOutWithDuration(0.5)
        labelHint.runAction(fadeOut, completion: { () -> Void in
            self.labelHint.text = "| |"
            self.labelHint.fontSize = self.labelHint.fontSize * 1.5
            let wait = SKAction.waitForDuration(0.2)
            let fadeIn = SKAction.fadeInWithDuration(0.5)
            self.labelHint.runAction(SKAction.sequence([wait, fadeIn]))
        })
        let small = SKAction.scaleTo(Config.ButtonScaleRatioInGaming, duration: 0.8)
        small.timingMode = .EaseOut
        let move = SKAction.moveTo(Config.ButtonPositionInGaming, duration: 0.8)
        move.timingMode = .EaseOut
        button.runAction(SKAction.group([small, move]))
        
        // 显示计分板。
        scoreBoardPlayer.show(0.3)
        scoreBoardOpponent.show(0.5)
        
        // 显示玩家图标。
        avatar.hidden = false
        avatarOpponent.hidden = false
        avatar.runAction(fadeIn)
        avatarOpponent.runAction(fadeIn)
        
        // 如果当前是主机，则将地图发送给对方。
        if isHolder {
            let defaults = NSUserDefaults.standardUserDefaults()
            let map = defaults.dictionaryForKey("location")!
            mainMap = ESTLocation(fromDictionary: map)
            let messageData = NSJSONSerialization.dataWithJSONObject(map, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
            self.appDelegate.mpcHandler.session.sendData(messageData, toPeers: self.appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: nil)
        }
    }
    
    func handleReceivedDataWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo! as Dictionary
        let receivedData: NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        var type = message.objectForKey("type") as? String
        let mapType = message.objectForKey("creationDate") as? String
        if mapType != nil {
            type = Enum.SendMap.rawValue
        }
        
        // 角色移动信息。
        if type == Enum.MoveAvatar.rawValue {
            let x1: Float? = message.objectForKey("x")?.floatValue
            let y1: Float? = message.objectForKey("y")?.floatValue

            var x: CGFloat = CGFloat(x1!)
            var y: CGFloat = CGFloat(y1!)
            
            let move = SKAction.moveTo(Ball.getSafePosition(x, y: y), duration: self.motionManager.accelerometerUpdateInterval)
            self.ball.runAction(move)
        }
        // 接收地图信息。
        else if type == Enum.SendMap.rawValue {
            mainMap = ESTLocation(fromDictionary: message)
        }
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, inLocation location: ESTLocation!) {
        
        let text = NSString(format: "x: %.2f   y: %.2f    α: %.2f",
            position.x,
            position.y,
            position.orientation)
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didFailToUpdatePositionWithError error: NSError!) {
        let text = "It seems you are outside the location."
        let err = NSLog(error.localizedDescription)
    }
    
    func initBackground() {
        
        let background = SKSpriteNode(color: UIColor(netHex: Config.BackgroungColor), size: Config.ScreenSize)
        background.position = Config.BackgroundPosition
        
        let gameBoard = SKSpriteNode(color: UIColor(netHex: Config.GameBoardColor), size: Config.GameBoardSize)
        gameBoard.position = Config.GameBoardPosition
        
        let leftBorder = SKSpriteNode(color: UIColor(netHex: Config.BorderColor), size: CGSizeMake(Config.BorderWidth, Config.ScreenSize.width))
        leftBorder.position = CGPoint(x: 0, y: 0)
        
        let topBorder = SKSpriteNode(color: UIColor(netHex: Config.BorderColor), size: CGSizeMake(Config.GameBoardWidth, Config.BorderWidth))
        topBorder.position = CGPoint(x: Config.BorderWidth, y: 0)
        
        let rightBorder = SKSpriteNode(color: UIColor(netHex: Config.BorderColor), size: CGSizeMake(Config.BorderWidth, Config.ScreenSize.width))
        rightBorder.position = CGPoint(x: Config.ScreenSize.width - Config.BorderWidth, y: 0)
        
        let bottomBorder = SKSpriteNode(color: UIColor(netHex: Config.BorderColor), size: CGSizeMake(Config.GameBoardWidth, Config.BorderWidth))
        bottomBorder.position = CGPoint(x: Config.BorderWidth, y: -Config.ScreenSize.width + Config.BorderWidth)
        
        let centerLine = SKSpriteNode(color: UIColor(netHex: Config.CenterLineColor), size: Config.CenterLineSize)
        centerLine.position = Config.CenterLinePosition
        
        let centerCircle = SKShapeNode(circleOfRadius: Config.CenterCircleRadius)
        centerCircle.strokeColor = UIColor(netHex: Config.CenterCircleColor)
        centerCircle.lineWidth = Config.CenterCircleLineWidth
        centerCircle.position = Config.CenterCirclePosition

        scoreBoardBox = SKSpriteNode(color: UIColor(netHex: Config.BackgroungColor), size: Config.ScoreBoardBoxSize)
        scoreBoardBox.position = Config.ScoreBoardBoxPosition
        scoreBoardBox.addChild(scoreBoardPlayer)
        scoreBoardBox.addChild(scoreBoardOpponent)
        scoreBoardPlayer.hidden = true
        scoreBoardPlayer.position = Config.ScoreBoardPlayerPosition
        scoreBoardPlayer.setAvatar(false)
        scoreBoardOpponent.hidden = true
        scoreBoardOpponent.position = Config.ScoreBoardOpponentPosition
        scoreBoardOpponent.setAvatar(true)
        let fadeOut = SKAction.fadeOutWithDuration(0.01)
        let scaleToZero = SKAction.scaleTo(0, duration: 0.01)
        scoreBoardPlayer.runAction(SKAction.group([fadeOut, scaleToZero]))
        scoreBoardOpponent.runAction(SKAction.group([fadeOut, scaleToZero]))
        
        // 设置游戏界面物理属性。
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: Config.GameBoardRect)
        physicsBody.categoryBitMask = Config.BorderCategory
        self.physicsBody = physicsBody
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        // 设置Button点击事件代理。
        button.buttonPressDelegate = self
        
        setAnorPoint([background, gameBoard, leftBorder, topBorder, rightBorder, bottomBorder, centerLine, scoreBoardBox])
        addChildren([background, gameBoard, leftBorder, topBorder, rightBorder, bottomBorder, centerLine, centerCircle, scoreBoardBox, button])
    }
    
    func makeBall() {
        let ball = Ball.getBall(Config.BallRadius, position: Config.CenterCirclePosition)
        ball.fillColor =  UIColor(netHex: Config.ButtonColor)
        addChild(ball)
        let duration = 6.0
        let scaleToBig = SKAction.scaleTo(3.0, duration: duration / 2)
        scaleToBig.timingMode = .EaseOut
        let scaleToSmall = SKAction.scaleTo(1.0, duration: duration / 2)
        scaleToSmall.timingMode = .EaseIn
        let scaleSeq = SKAction.sequence([scaleToBig, scaleToSmall])
        let action = SKAction.repeatActionForever(scaleSeq)
        ball.runAction(action)
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
        if isHolder && !isGaming {
            return
        }
        if !isGaming {
            connectWithPlayer()
        } else {
            exitGameScene()
        }
    }
    
    func didLongPress(sender: Button) {
        // 如果当前没有地图，则弹出地图设置界面。
        let defaults = NSUserDefaults.standardUserDefaults()
        let location = defaults.dictionaryForKey("location")
        if location == nil {
            showLocationSetup()
        }
        
        // 切换广播状态。
        switchAdvertising()
        if !isHolder {
            let hintFadeOut = SKAction.fadeOutWithDuration(0.4)
            labelHint.runAction(hintFadeOut)
            initHintTimer()
        } else {
            animateHint(false)
        }
    }
    
    func connectWithPlayer() {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            viewController.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    func switchAdvertising() {
        appDelegate.mpcHandler.advertiseSelf(!appDelegate.mpcHandler.advertising)
        isHolder = appDelegate.mpcHandler.advertising
    }
    
    func exitGameScene() {
        appDelegate.mpcHandler.advertiseSelf(false)
        isHolder = appDelegate.mpcHandler.advertising
        gameSceneExitDelegate.gameSceneDidExit(self)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func peerChangedStateWithNotification(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as Int
        
        // 如果连接成功。
        if state == MCSessionState.Connected.rawValue {
            if !isHolder {
                viewController.dismissViewControllerAnimated(true, completion: nil)
            }
            startGame()
        }
        
        println(state)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
