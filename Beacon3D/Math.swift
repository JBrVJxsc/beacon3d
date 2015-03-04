//
//  Math.swift
//  Beacon3D
//
//  Created by Xu ZHANG on 3/2/15.
//  Copyright (c) 2015 Xu ZHANG. All rights reserved.
//

import Foundation

enum Math {
    static func degreesToRadians(degrees: Double) -> CGFloat {
        let result = degrees / 180 * M_PI
        return CGFloat(result)
    }
    
    static func radiansToDegrees(radians: Double) -> CGFloat {
        let result = radians * 180.0 / M_PI
        return CGFloat(result)
    }
    
    static func positionTurnover(point: CGPoint) -> CGPoint {
        let xAxis = Config.ScreenWidth / 2
        let yAxis = -Config.BorderWidth - Config.GameBoardHeight / 2
        var x = point.x
        var y = point.y
        
        if x < xAxis {
            x = xAxis + (xAxis - x)
        } else if x > xAxis {
            x = xAxis - (x - xAxis)
        }
        
        if y < yAxis {
            y = yAxis + (yAxis - y)
        } else if y > yAxis {
            y = yAxis - (y - yAxis)
        }
        
        return CGPoint(x: x, y: y)
    }
    
    static func vectorTurnover(vector: CGVector) -> CGVector {
        return CGVectorMake(-vector.dx, -vector.dy)
    }
}
