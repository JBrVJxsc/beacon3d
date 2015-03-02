//
//  Config.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/12/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

struct Config {
    
    static var ScreenSize = UIScreen.mainScreen().bounds.size
    static var ScreenWidth: CGFloat = ScreenSize.width
    static var ScreenHeight: CGFloat = ScreenSize.height
    
    static var AvatarRadius: CGFloat = 1.5 * BallRadius
    static var AvatarColor: Int = ButtonBorderColor
    static var AvatarOpponentColor: Int = 0xEF5350
    static var AvatarCategoryName = "avatar"
    static var AvatarCategory: UInt32 = 0x1 << 2
    static var AvatarPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: GameBoardPosition.y - GameBoardHeight + AvatarRadius * 2)
    static var AvatarOpponentPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: GameBoardPosition.y - AvatarRadius * 2)
    static var AvatarPositionMinX: CGFloat = BorderWidth + AvatarRadius
    static var AvatarPositionMaxX: CGFloat = ScreenWidth - BorderWidth - AvatarRadius
    static var AvatarPositionMinY: CGFloat = -BorderWidth - GameBoardHeight + AvatarRadius
    static var AvatarPositionMaxY: CGFloat = -BorderWidth - AvatarRadius

    static var BallRadius: CGFloat = 10
    static var BallColor: Int = 0x61C3DB
    static var BallCategoryName = "ball"
    static var BallCategory: UInt32 = 0x1 << 1
    static var BallPosition: CGPoint = CGPoint(x: BallPositionMinX, y: BallPositionMaxY)
    static var BallPositionMinX: CGFloat = BorderWidth + BallRadius
    static var BallPositionMaxX: CGFloat = ScreenWidth - BorderWidth - BallRadius
    static var BallPositionMinY: CGFloat = -BorderWidth - GameBoardHeight + BallRadius
    static var BallPositionMaxY: CGFloat = -BorderWidth - BallRadius
    
    static var ButtonRadius: CGFloat = min(ScreenWidth, ScreenHeight - ScreenWidth) / 2 * 0.8
    static var ButtonColor: Int = 0xD2D800
    static var ButtonCategoryName = "button"
    static var ButtonLongPressInterval = 0.8
    static var ButtonPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: -ScreenWidth - (ScreenHeight - ScreenWidth) / 2)
    static var ButtonBorderWidth: CGFloat = ButtonRadius * 0.15
    static var ButtonBorderColor: Int = 0xE3E536
    
    static var BorderColor: Int = 0x3896BA
    static var BorderCategory: UInt32 = 0x1 << 0
    static var BorderWidth: CGFloat = 15
    
    static var BackgroungColor: Int = 0x61C3DB
    static var BackgroundPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    static var GameBoardColor: Int = 0xC9E9E8
    static var GameBoardPosition: CGPoint = CGPoint(x: BorderWidth, y: -BorderWidth)
    static var GameBoardWidthHeightRatio: CGFloat = 1
    static var GameBoardWidth: CGFloat = ScreenWidth - BorderWidth * 2
    static var GameBoardHeight: CGFloat = GameBoardWidth * GameBoardWidthHeightRatio
    static var GameBoardSize: CGSize = CGSize(width: GameBoardWidth, height: GameBoardHeight)
    static var GameBoardRect: CGRect = CGRect(x: GameBoardPosition.x, y: GameBoardPosition.y - GameBoardHeight, width: GameBoardWidth, height: GameBoardHeight)
}