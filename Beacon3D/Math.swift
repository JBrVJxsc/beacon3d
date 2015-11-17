//
//  Math.swift
//  Beacon3D
//
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
    
    static func radiansToVector(radians: Double, times: Double) -> CGVector {
        let vector = CGVector(dx: sin(-radians) * 10 * times, dy: cos(-radians) * 10 * times)
        return vector
    }
    
    static func getDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let x = p1.x - p2.x
        let y = p1.y - p2.y
        return sqrt(x * x + y * y)
    }
    
    static func getDistance(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGFloat {
        let x = x1 - x2
        let y = y1 - y2
        return sqrt(x * x + y * y)
    }
}
