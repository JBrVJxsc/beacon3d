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
}
