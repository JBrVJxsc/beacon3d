//
//  Config.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 1/12/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import SpriteKit

struct Config {
    
    static var TransparentColor: Int = 0x00FFFFFF
    
    static var ScreenSize = UIScreen.mainScreen().bounds.size
    static var ScreenWidth: CGFloat = ScreenSize.width
    static var ScreenHeight: CGFloat = ScreenSize.height
    
    static var TitleSize = CGSize(width: ScreenWidth * 0.85, height: ScreenHeight * 0.13)
    static var TitlePosition = CGPoint(x: Config.ScreenWidth / 2, y: -Config.ScreenHeight / 8.7)
    
    static var AvatarRadius: CGFloat = 1.5 * BallRadius
    static var AvatarColor: Int = BorderColor
    static var AvatarOpponentColor: Int = 0xEF5350
    static var AvatarCategoryName = "avatar"
    static var AvatarCategory: UInt32 = 0x1 << 2
    static var AvatarPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: GameBoardPosition.y - GameBoardHeight + AvatarRadius * 2)
    static var AvatarOpponentPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: GameBoardPosition.y - AvatarRadius * 2)
    static var AvatarPositionMinX: CGFloat = BorderWidth + AvatarRadius
    static var AvatarPositionMaxX: CGFloat = ScreenWidth - BorderWidth - AvatarRadius
    static var AvatarPositionMinY: CGFloat = -BorderWidth - GameBoardHeight + AvatarRadius
    static var AvatarPositionMaxY: CGFloat = -BorderWidth - AvatarRadius

    static var BallRadius: CGFloat = BorderWidth / 2
    static var BallColor: Int = 0x61C3DB
    static var BallCategoryName = "ball"
    static var BallCategory: UInt32 = 0x1 << 0
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
    static var ButtonPositionInGaming = CGPoint(x: ButtonPosition.x, y: -ScreenHeight * 0.9)
    static var ButtonScaleRatioInGaming: CGFloat = 0.35
    
    static var BorderColor: Int = 0x3896BA
    static var BorderCategory: UInt32 = 0x1 << 1
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
    
    static var CenterLineColor: Int = BorderColor
    static var CenterLinePosition: CGPoint = CGPoint(x: GameBoardPosition.x, y: GameBoardPosition.y - GameBoardHeight / 2)
    static var CenterLineWidth: CGFloat = GameBoardWidth
    static var CenterLineHeight: CGFloat = 2
    static var CenterLineSize: CGSize = CGSize(width: CenterLineWidth, height: CenterLineHeight)
    
    static var CenterCircleColor: Int = BorderColor
    static var CenterCirclePosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: GameBoardPosition.y - GameBoardHeight / 2)
    static var CenterCircleLineWidth: CGFloat = 2
    static var CenterCircleRadius: CGFloat = GameBoardWidth / 5.5
    
    static var ScoreBoardBoxPosition: CGPoint = CGPoint(x: 0, y: -ScreenWidth)
    static var ScoreBoardBoxWidth: CGFloat = ScreenWidth
    static var ScoreBoardBoxHeight: CGFloat = (-ButtonPositionInGaming.y - ButtonRadius * ButtonScaleRatioInGaming + ScoreBoardBoxPosition.y) * 0.8
    static var ScoreBoardBoxSize: CGSize = CGSize(width: ScoreBoardBoxWidth, height: ScoreBoardBoxHeight)
    
    static var ScoreBoardMarge: CGFloat = BorderWidth * 1.5
    static var ScoreBoardSize: CGSize = CGSize(width: ScoreBoardBoxWidth / 3, height: ScoreBoardBoxHeight / 1.8)
    static var ScoreBoardBorderWidth: CGFloat = BorderWidth
    static var ScoreBoardPlayerPosition: CGPoint = CGPoint(x: (ScoreBoardSize.width + ScoreBoardBorderWidth) / 2 + ScoreBoardMarge, y: -Config.ScoreBoardBoxHeight / 2.1)
    static var ScoreBoardOpponentPosition: CGPoint = CGPoint(x: ScoreBoardBoxWidth - (ScoreBoardSize.width + ScoreBoardBorderWidth) / 2 - ScoreBoardMarge, y: -Config.ScoreBoardBoxHeight / 2.1)
    static var ScoreBoardPipeColor: Int = BorderColor
    static var ScoreBoardPipeSize: CGSize = CGSize(width: BorderWidth,height: -ScoreBoardPlayerPosition.y - (ScoreBoardSize.height + ScoreBoardBorderWidth) / 2)
    static var ScoreBoardPipePlayerPosition: CGPoint = CGPoint(x: ScoreBoardPlayerPosition.x, y: -ScoreBoardPipeSize.height / 2)
    static var ScoreBoardPipeOpponentPosition: CGPoint = CGPoint(x: ScoreBoardOpponentPosition.x, y: -ScoreBoardPipeSize.height / 2)

    static var DoorColor: Int = BorderColor
    static var DoorLineWidth: CGFloat = 2
    static var DoorPlayerPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: -BorderWidth - GameBoardHeight + DoorHeight / 2 - (DoorLineWidth + 1) / 2)
    static var DoorPlayerCategory: UInt32 = 0x1 << 3
    static var DoorOpponentPosition: CGPoint = CGPoint(x: ScreenWidth / 2, y: -BorderWidth - DoorHeight / 2 + (DoorLineWidth + 1) / 2)
    static var DoorOpponentCategory: UInt32 = 0x1 << 4
    static var DoorWidth: CGFloat = ScreenWidth / 3
    static var DoorHeight: CGFloat = BorderWidth / 2
    static var DoorSize: CGSize = CGSize(width: DoorWidth, height: DoorHeight)
}