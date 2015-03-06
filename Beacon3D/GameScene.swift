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

class GameScene: SKScene, SKPhysicsContactDelegate, MCBrowserViewControllerDelegate, ButtonPressDelegate, ESTIndoorLocationManagerDelegate, MotionEndedDelegate {
    
    var ball: SKShapeNode!
    let button = Button(circleOfRadius: Config.ButtonRadius)
    let scoreBoardPlayer = ScoreBoard(rectOfSize: Config.ScoreBoardSize)
    let scoreBoardOpponent = ScoreBoard(rectOfSize: Config.ScoreBoardSize)
    let scoreBoardPlayerPipe = SKShapeNode(rectOfSize: Config.ScoreBoardPipeSize)
    let scoreBoardOpponentPipe = SKShapeNode(rectOfSize: Config.ScoreBoardPipeSize)
    var scoreBoardBox: SKSpriteNode!
    
    let avatarPlayer = Avatar.getAvatar(Config.AvatarRadius, position: Config.AvatarPosition, isOpponent: false)
    var avatarPlayerCurrentRadians: Double = 0
    let avatarOpponent = Avatar.getAvatar(Config.AvatarRadius, position: Config.AvatarOpponentPosition, isOpponent: true)
    let avatarOpponentDefaultRotation = Math.degreesToRadians(180)
    
    var mainMap: ESTLocation!
    let locationManager: ESTIndoorLocationManager = ESTIndoorLocationManager()
    
    let motionManager: CMMotionManager = CMMotionManager()
    var timer: NSTimer!
    var firstFire: Bool = true
    
    var rotateTimer: NSTimer!
    
    let labelHint = SKLabelNode(text: "")
    let hints = ["Hold", "To", "Create", "Game", "Touch", "To", "Join", "Game"]
    var hintIndex = 0
    
    var appDelegate: AppDelegate!
    var gameSceneExitDelegate: GameSceneExitDelegate!
    var viewController: UIViewController!
    
    var isHolder: Bool = false
    var isGaming: Bool = false
    var isServing: Bool = false
    
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
        initRotateTime()
        initHintTimer()
        initLocationManager()
    }
    
    func initSensors() {
        
//        if  motionManager.accelerometerAvailable {
//            let speed = 18.0
//            motionManager.accelerometerUpdateInterval = 1.0 / 30.0
//            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) {
//                (data : CMAccelerometerData!, error: NSError!) in
//                let x = self.ball.position.x + CGFloat(data.acceleration.x * speed)
//                let y = self.ball.position.y + CGFloat(data.acceleration.y * speed)
//                let move = SKAction.moveTo(Ball.getSafePosition(x, y: y), duration: self.motionManager.accelerometerUpdateInterval)
//                self.ball.runAction(move)
//                
//                let messageDict = ["type": Enum.MoveAvatar.rawValue, "x": x, "y": y]
//                let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
//                
//                self.appDelegate.mpcHandler.session.sendData(messageData, toPeers: self.appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: nil)
//            }
//        }
//        
//        if motionManager.gyroAvailable {
//            motionManager.gyroUpdateInterval = 1 / 30
//            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()) {
//            (data : CMGyroData!, error: NSError!) in
//                println(data.description)
//            }
//        }
//        
//        if motionManager.magnetometerAvailable {
//            motionManager.magnetometerUpdateInterval = 1 / 20
//            motionManager.startMagnetometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {
//            (data: CMMagnetometerData!, error: NSError!) -> Void in
//                println(data.description)
//            })
//        }
        
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1 / 4
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {
            (data: CMDeviceMotion!, error: NSError!) -> Void in
                
                // 如果不在游戏中，则不检测。
                if !self.isGaming {
                    return
                }
                
                // 旋转角色。
                self.avatarPlayerCurrentRadians = data.attitude.yaw
                let rotate = SKAction.rotateToAngle(CGFloat(self.avatarPlayerCurrentRadians), duration: self.motionManager.deviceMotionUpdateInterval)
                self.avatarPlayer.runAction(rotate)
            })
        }
    }
    
    // 碰撞检测。
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
        
        if firstBody.categoryBitMask == Config.BallCategory && secondBody.categoryBitMask == Config.BorderCategory {

        } else if firstBody.categoryBitMask == Config.BallCategory && secondBody.categoryBitMask == Config.DoorPlayerCategory {
            ball.physicsBody = nil
            addScore(true)
        } else if firstBody.categoryBitMask == Config.BallCategory && secondBody.categoryBitMask == Config.DoorOpponentCategory {
            ball.physicsBody = nil
            addScore(false)
        }
    }
    
    func addScore(isOpponent: Bool) {
        if isOpponent {
            let wait = SKAction.waitForDuration(0.1)
            let moveToOriginal = SKAction.moveTo(CGPoint(x: Config.ScreenWidth / 2, y: -Config.BorderWidth - Config.GameBoardHeight - Config.BorderWidth / 2), duration: 0.3)
            moveToOriginal.timingMode = .EaseIn
            let moveRight = SKAction.moveTo(CGPoint(x: Config.ScoreBoardPipeOpponentPosition.x, y: -Config.BorderWidth - Config.GameBoardHeight - Config.BorderWidth / 2), duration: 0.3)
            moveRight.timingMode = .EaseIn
            let moveDown = SKAction.moveTo(CGPoint(x: Config.ScoreBoardPipeOpponentPosition.x, y: -Config.BorderWidth - Config.GameBoardHeight - Config.BorderWidth / 2 - Config.ScoreBoardPipeSize.height - Config.ScoreBoardBorderWidth * 2), duration: 0.4)
            moveDown.timingMode = .EaseIn
            let fadeOut = SKAction.fadeOutWithDuration(0.4)
            
            let action = SKAction.sequence([wait, moveToOriginal, moveRight, SKAction.group([moveDown, fadeOut])])
            ball.runAction(action, completion: { () -> Void in
                self.scoreBoardOpponent.addScore()
                self.ball.removeFromParent()
                self.ball = nil
                self.serveBall(false)
            })
        } else {
            let wait = SKAction.waitForDuration(0.1)
            let moveToOriginal = SKAction.moveTo(CGPoint(x: Config.ScreenWidth / 2, y: -Config.BorderWidth / 2), duration: 0.3)
            moveToOriginal.timingMode = .EaseIn
            let moveLeft = SKAction.moveTo(CGPoint(x: Config.BallRadius, y: -Config.BorderWidth / 2), duration: 0.3)
            moveLeft.timingMode = .EaseIn
            let moveDown = SKAction.moveTo(CGPoint(x: Config.BallRadius, y: -Config.BorderWidth - Config.GameBoardHeight - Config.BorderWidth / 2), duration: 0.3)
            moveDown.timingMode = .EaseIn
            let moveRight = SKAction.moveTo(CGPoint(x: Config.ScoreBoardPipePlayerPosition.x, y: -Config.BorderWidth - Config.GameBoardHeight - Config.BorderWidth / 2), duration: 0.5)
            moveRight.timingMode = .EaseIn
            let moveDown1 = SKAction.moveTo(CGPoint(x: Config.ScoreBoardPipePlayerPosition.x, y: -Config.BorderWidth - Config.GameBoardHeight - Config.BorderWidth / 2 - Config.ScoreBoardPipeSize.height - Config.ScoreBoardBorderWidth * 2), duration: 0.4)
            moveDown1.timingMode = .EaseIn
            let fadeOut = SKAction.fadeOutWithDuration(0.4)
            
            let action = SKAction.sequence([wait, moveToOriginal, moveLeft, moveDown, moveRight, SKAction.group([moveDown1, fadeOut])])
            ball.runAction(action, completion: { () -> Void in
                self.scoreBoardPlayer.addScore()
                self.ball.removeFromParent()
                self.ball = nil
                self.serveBall(true)
            })
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
        showPipe(false, delay: 0.3)
        showPipe(true, delay: 0.5)
        scoreBoardPlayer.show(0.5)
        scoreBoardOpponent.show(0.7)
        
        // 显示玩家图标。
        avatarPlayer.hidden = false
        avatarOpponent.hidden = false
        avatarPlayer.runAction(fadeIn)
        avatarOpponent.runAction(fadeIn)
        
        // 如果当前是主机，则将地图发送给对方。
        if isHolder {
            let defaults = NSUserDefaults.standardUserDefaults()
            let temp = defaults.dictionaryForKey("location")?
            if temp != nil {
                let map = defaults.dictionaryForKey("location")!
                mainMap = ESTLocation(fromDictionary: map)
                sendMessage(map)
                // 启动位置信息监控。
                locationManager.startIndoorLocation(mainMap)
            }
            serveBall(false)
        } else {
            serveBall(true)
        }
        
        // 启动发送角色旋转信息的计时器。
        rotateTimer.fire()
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

            let x: CGFloat = CGFloat(x1!)
            let y: CGFloat = CGFloat(y1!)
            
            let move = SKAction.moveTo(Ball.getSafePosition(x, y: y), duration: self.motionManager.accelerometerUpdateInterval)
            self.ball.runAction(move)
        }
        // 接收地图信息。
        else if type == Enum.SendMap.rawValue {
            mainMap = ESTLocation(fromDictionary: message)
            
            // 启动位置信息监控。
            locationManager.startIndoorLocation(mainMap)
        }
        // 角色旋转信息。
        else if type == Enum.RotateAvatar.rawValue {
            let r1: Float? = message.objectForKey("radians")?.floatValue
            let r: CGFloat = CGFloat(r1!)

            let rotate = SKAction.rotateToAngle(avatarOpponentDefaultRotation + r, duration: 0.5)
            self.avatarOpponent.runAction(rotate)
        }
        // 对方发球信息。
        else if type == Enum.SendBall.rawValue {
            var x1: Float? = message.objectForKey("x")?.floatValue
            var y1: Float? = message.objectForKey("y")?.floatValue
            
            var x: CGFloat = CGFloat(x1!)
            var y: CGFloat = CGFloat(y1!)
            
            ball = Ball.getBall(Config.BallRadius, position: Math.positionTurnover(CGPoint(x: x, y: y)))
            ball.fillColor =  UIColor(netHex: Config.ButtonColor)
            // 设置球的向量。
            x1 = message.objectForKey("dx")?.floatValue
            y1 = message.objectForKey("dy")?.floatValue
            
            x = CGFloat(x1!)
            y = CGFloat(y1!)

            let vector = Math.vectorTurnover(CGVector(dx: x, dy: y))
            ball.physicsBody?.velocity = vector
            addChild(ball)
        }
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didUpdatePosition position: ESTOrientedPoint!, inLocation location: ESTLocation!) {
        
        let text = NSString(format: "x: %.2f   y: %.2f    α: %.2f",
            position.x,
            position.y,
            position.orientation)
    }
    
    func indoorLocationManager(manager: ESTIndoorLocationManager!, didFailToUpdatePositionWithError error: NSError!) {
//        let err: () = NSLog(error.localizedDescription)
    }
    
    func didMotionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            // 如果玩家发球。
            if isServing {
                makeBall()
                avatarPlayer.stopShining()
                isServing = false
                return
            }
            
            if ball != nil {
                // Check if the ball is around.
                // If so, hit the ball.
                println("x: \(ball.position.x), y: \(ball.position.y)")
            }
        }
    }
    
    func makeBall() {
        ball = Ball.getBall(Config.BallRadius, position: avatarPlayer.position)
        ball.fillColor =  UIColor(netHex: Config.ButtonColor)
        // 设置球的向量。
        let vector = Math.radiansToVector(avatarPlayerCurrentRadians, times: 40)
        ball.physicsBody?.velocity = vector
        // 将球的位置与向量发送给对方。
        let messageDict = ["type": Enum.SendBall.rawValue, "x": avatarPlayer.position.x, "y": avatarPlayer.position.y, "dx": vector.dx, "dy": vector.dy]
        sendMessage(messageDict)
        addChild(ball)
    }
    
    func sendMessage(obj: AnyObject) {
        let messageData = NSJSONSerialization.dataWithJSONObject(obj, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: self.appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: nil)
    }
    
    func serveBall(isOpponent: Bool) {
        if isOpponent {
            isServing = false
            avatarPlayer.stopShining()
            avatarOpponent.startShining(0.8, fadeTo: 0.4)
        } else {
            isServing = true
            avatarPlayer.startShining(0.8, fadeTo: 0.4)
            avatarOpponent.stopShining()
        }
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
        
        // 设置中心线。
        let centerLine = SKSpriteNode(color: UIColor(netHex: Config.CenterLineColor), size: Config.CenterLineSize)
        centerLine.position = Config.CenterLinePosition
        
        // 设置中心圆。
        let centerCircle = SKShapeNode(circleOfRadius: Config.CenterCircleRadius)
        centerCircle.strokeColor = UIColor(netHex: Config.CenterCircleColor)
        centerCircle.lineWidth = Config.CenterCircleLineWidth
        centerCircle.position = Config.CenterCirclePosition
        
        // 设置门框。
        let doorPlayer = SKShapeNode(rectOfSize: Config.DoorSize)
        doorPlayer.strokeColor = UIColor(netHex: Config.DoorColor)
        doorPlayer.lineWidth = Config.DoorLineWidth
        doorPlayer.position = Config.DoorPlayerPosition
        let doorPlayerPhysicsBody = SKPhysicsBody(rectangleOfSize: Config.DoorSize)
        doorPlayerPhysicsBody.categoryBitMask = Config.DoorPlayerCategory
        doorPlayerPhysicsBody.contactTestBitMask = Config.BallCategory
        doorPlayerPhysicsBody.dynamic = false
        doorPlayer.physicsBody = doorPlayerPhysicsBody
        
        let doorOpponent = SKShapeNode(rectOfSize: Config.DoorSize)
        doorOpponent.strokeColor = UIColor(netHex: Config.DoorColor)
        doorOpponent.lineWidth = Config.DoorLineWidth
        doorOpponent.position = Config.DoorOpponentPosition
        let doorOpponentPhysicsBody = SKPhysicsBody(rectangleOfSize: Config.DoorSize)
        doorOpponentPhysicsBody.categoryBitMask = Config.DoorOpponentCategory
        doorOpponentPhysicsBody.contactTestBitMask = Config.BallCategory
        doorOpponentPhysicsBody.dynamic = false
        doorOpponent.physicsBody = doorOpponentPhysicsBody

        // 设置计分板。
        scoreBoardBox = SKSpriteNode(color: UIColor(netHex: Config.BackgroungColor), size: Config.ScoreBoardBoxSize)
        scoreBoardBox.position = Config.ScoreBoardBoxPosition
        scoreBoardBox.addChild(scoreBoardPlayer)
        scoreBoardBox.addChild(scoreBoardOpponent)
        scoreBoardBox.addChild(scoreBoardPlayerPipe)
        scoreBoardBox.addChild(scoreBoardOpponentPipe)
        scoreBoardPlayer.hidden = true
        scoreBoardPlayer.position = Config.ScoreBoardPlayerPosition
        scoreBoardPlayer.setAvatar(false)
        scoreBoardOpponent.hidden = true
        scoreBoardOpponent.position = Config.ScoreBoardOpponentPosition
        scoreBoardOpponent.setAvatar(true)
        scoreBoardPlayerPipe.hidden = true
        scoreBoardPlayerPipe.position = Config.ScoreBoardPipePlayerPosition
        scoreBoardPlayerPipe.fillColor = UIColor(netHex: Config.ScoreBoardPipeColor)
        scoreBoardPlayerPipe.strokeColor = UIColor(netHex: Config.ScoreBoardPipeColor)
        scoreBoardOpponentPipe.hidden = true
        scoreBoardOpponentPipe.position = Config.ScoreBoardPipeOpponentPosition
        scoreBoardOpponentPipe.fillColor = UIColor(netHex: Config.ScoreBoardPipeColor)
        scoreBoardOpponentPipe.strokeColor = UIColor(netHex: Config.ScoreBoardPipeColor)

        let fadeOut = SKAction.fadeOutWithDuration(0.01)
        let scaleToZero = SKAction.scaleTo(0, duration: 0.01)
        scoreBoardPlayer.runAction(SKAction.group([fadeOut, scaleToZero]))
        scoreBoardOpponent.runAction(SKAction.group([fadeOut, scaleToZero]))
        scoreBoardPlayerPipe.runAction(SKAction.group([fadeOut, scaleToZero]))
        scoreBoardOpponentPipe.runAction(SKAction.group([fadeOut, scaleToZero]))
        
        // 设置游戏界面物理属性。
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: Config.GameBoardRect)
        physicsBody.categoryBitMask = Config.BorderCategory
        self.physicsBody = physicsBody
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        // 设置Button点击事件代理。
        button.buttonPressDelegate = self
        
        setAnorPoint([background, gameBoard, leftBorder, topBorder, rightBorder, bottomBorder, centerLine, scoreBoardBox])
        addChildren([background, gameBoard, leftBorder, topBorder, rightBorder, bottomBorder, centerLine, centerCircle, doorPlayer, doorOpponent, scoreBoardBox, button])
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
            startGame()
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
    
    func sendRotateMessage() {
        // 发送角色旋转信息给对方。
        let messageDict = ["type": Enum.RotateAvatar.rawValue, "radians": avatarPlayerCurrentRadians]
        sendMessage(messageDict)
    }
    
    func initLocationManager() {
        ESTConfig.setupAppID("app_28n6m2cfaq", andAppToken: "e6a2c5fcc28276a9ab28de9ea5961dd7")
        locationManager.delegate = self
    }
    
    func initMPC() {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    
    func initHintTimer() {
        firstFire = true
        if timer != nil {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("hintFire"), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func initRotateTime() {
        rotateTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("sendRotateMessage"), userInfo: nil, repeats: true)
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
        let rotate = SKAction.rotateByAngle(avatarOpponentDefaultRotation, duration: 0.01)
        avatarPlayer.runAction(fadeOut)
        avatarOpponent.runAction(SKAction.group([fadeOut, rotate]))
        avatarPlayer.hidden = true
        avatarOpponent.hidden = true
        
        addChildren([avatarPlayer, avatarOpponent])
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
    
    func showPipe(isOpponent: Bool, delay: NSTimeInterval) {
        var pipe: SKShapeNode!
        if isOpponent {
            pipe = scoreBoardOpponentPipe
        } else {
            pipe = scoreBoardPlayerPipe
        }
        pipe.hidden = false
        let delay = SKAction.waitForDuration(delay)
        let fadeIn = SKAction.fadeAlphaTo(1.0, duration: 0.6)
        let bigger = SKAction.scaleTo(1.1, duration: 0.2)
        bigger.timingMode = .EaseIn
        let biggerSmaller = SKAction.scaleTo(0.9, duration: 0.1)
        let biggerSmallerBigger = SKAction.scaleTo(1.0, duration: 0.1)
        let group = SKAction.group([fadeIn, SKAction.sequence([bigger, biggerSmaller, biggerSmallerBigger])])
        let seq = SKAction.sequence([delay, group])
        pipe.runAction(seq)
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
