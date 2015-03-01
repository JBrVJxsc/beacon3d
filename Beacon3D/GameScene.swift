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

protocol ExitDelegate {
    func didExit(sender: GameScene)
}

class GameScene: SKScene, SKPhysicsContactDelegate, MCBrowserViewControllerDelegate, ButtonPressDelegate, ESTIndoorLocationManagerDelegate {
    
    let ball = Ball.getBall(Config.BallRadius, position: Config.BallPosition)
    let button = Button(circleOfRadius: Config.ButtonRadius)
    let motionManager: CMMotionManager = CMMotionManager()
    
    var appDelegate: AppDelegate!
    var viewController: UIViewController!
    
    var isHolder: Bool = false
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
        initBackground()
        initSensors()
        initMPC()
    }
    
    func initMPC() {
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    
    func initSensors() {
        
        if  motionManager.accelerometerAvailable {
            let speed = 18.0
            motionManager.accelerometerUpdateInterval = 1.0 / 30.0
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()) {
                (data : CMAccelerometerData!, error: NSError!) in

                let x = self.ball.position.x + CGFloat(data.acceleration.x * speed)
                let y = self.ball.position.y + CGFloat(data.acceleration.y * speed)
                let move = SKAction.moveTo(Ball.getSafePosition(x, y: y), duration: self.motionManager.accelerometerUpdateInterval)
                self.ball.runAction(move)
                
                let messageDict = ["type": "AMoving", "x": x, "y": y]
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
    
    func makeBall () {
        let ball = Ball.getBall(Config.BallRadius, position: CGPoint(x: Config.BallPositionMinX, y: Config.BallPositionMinY))
        ball.fillColor =  UIColor(netHex: Config.ButtonColor)
        addChild(ball)
        
        let duration = 1.0
        let moveAction = SKAction.moveTo(CGPoint(x: Config.BallPositionMaxX, y: Config.BallPositionMaxY), duration: duration)
        moveAction.timingMode = .EaseInEaseOut
        
        let scaleToBig = SKAction.scaleBy(3.0, duration: duration / 2)
        let scaleToSmall = SKAction.scaleBy(0.25, duration: duration / 2)
        let scaleSeq = SKAction.sequence([scaleToBig, scaleToSmall])
        scaleSeq.timingMode = .EaseInEaseOut
        ball.runAction(SKAction.group([moveAction, scaleSeq]))
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
        
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: Config.GameBoardRect)
        physicsBody.friction = 2000
        physicsBody.categoryBitMask = Config.BorderCategory
        
        self.physicsBody = physicsBody
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        button.buttonPressDelegate = self
        setAnorPoint([background, gameBoard, leftBorder, topBorder, rightBorder, bottomBorder])
        addChildren([background, gameBoard, leftBorder, topBorder, rightBorder, bottomBorder, ball, button])
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
        }
    }
    
    func connectWithPlayer() {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self            
            viewController.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    func peerChangedStateWithNotification(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.objectForKey("state") as Int
        
        if state != MCSessionState.Connecting.rawValue {
            if !isHolder {
//                viewController.dismissViewControllerAnimated(true, completion: nil)
                println("dismiss")
            }
        }
        
        println(state)
    }
    
    func handleReceivedDataWithNotification(notification: NSNotification) {
        let userInfo = notification.userInfo! as Dictionary
        let receivedData: NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        
        if message.objectForKey("type") as? String == "AMoving" {
            
            let x1: Float? = message.objectForKey("x")?.floatValue
            let y1: Float? = message.objectForKey("y")?.floatValue

            var x: CGFloat = CGFloat(x1!)
            var y: CGFloat = CGFloat(y1!)
            
            let move = SKAction.moveTo(Ball.getSafePosition(x, y: y), duration: self.motionManager.accelerometerUpdateInterval)
            self.ball.runAction(move)
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didPress(sender: Button) {
        println(sender.name)
        if isHolder {
            return
        }
        connectWithPlayer()
    }
    
    func didLongPress(sender: Button) {
        appDelegate.mpcHandler.advertiseSelf(!appDelegate.mpcHandler.advertising)
        isHolder = appDelegate.mpcHandler.advertising
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
