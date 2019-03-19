//
//  Constants.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 3/18/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

class Constants {
    struct CollisionCategory: OptionSet {
        let rawValue: Int
        static let target  = CollisionCategory(rawValue: 1 << 1)
        static let projectile = CollisionCategory(rawValue: 1 << 2)
    }
}
