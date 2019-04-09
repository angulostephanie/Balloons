//
//  Constants.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 3/18/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

struct Constants {
    // projectile speed
    static let speedConstant: Float = -8.2
    // remove projectile after they exceed this distance
    static let maxProjectileDistance: Float = 3.7
    // remove balloons after they exceed this height
    static let maxBalloonHeight: Float = 2.3
    // remove balloons if they're too close
    static let minBalloonDistance: Float = 0.15
    // lower bound on balloon creation, minimum of 1 balloon will be created per creation
    static let balloonsLowerBound: Int = 1
}
