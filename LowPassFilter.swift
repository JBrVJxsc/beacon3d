//
//  LowPassFilter.swift
//  Beacon3D
//
//  Copyright © 2015 Xu ZHANG. All rights reserved.
//

class LowPassFilter {
    var smoothed: CGFloat = 0
    var smoothing: CGFloat = 148
    var lastUpdate: CFAbsoluteTime = 0.0

    func filter(newValue: CGFloat) -> CGFloat {
        let now = CFAbsoluteTimeGetCurrent()
        if (lastUpdate == 0.0) {
            lastUpdate = CFAbsoluteTimeGetCurrent()
        }
        let elapsedTime = now - lastUpdate
        smoothed += CGFloat(elapsedTime) * CGFloat(((newValue - smoothed) / smoothing))
        lastUpdate = now;
        return smoothed;
    }
}