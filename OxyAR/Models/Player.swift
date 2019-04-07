//
//  Player.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/6/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

struct Player {
    let username: String!
    let score: Int!
    
    init(username: String!, score: Int!) {
        self.username = username
        self.score = score
    }
}
