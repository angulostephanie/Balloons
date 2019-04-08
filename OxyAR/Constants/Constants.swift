//
//  Constants.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 3/18/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

struct Constants {
    static let lives = 3
    // projectile speed
    static let speedConstant: Float = -8.0
    // remove projectile after they exceed this distance
    static let maxProjectileDistance: Float = 3.5
    // remove balloons after they exceed this height
    static let maxBalloonHeight: Float = 1.7
    
    // remove balloons after they
    static let minBalloonDistance: Float = 0.12
    
    static let targetImage = "target_aim.png"
}
