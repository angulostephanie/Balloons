//
//  NetworkGame.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/1/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

struct NetworkGame {
    var name: String
    var host: Player
    
//
//    init(host: Player, name: String? = nil) {
//        self.host = host
//        self.name = name ?? "\(host.username)'s game"
//    }
    
    
}
/*
extension NetworkGame: Hashable {
    static func == (lhs: NetworkGame, rhs: NetworkGame) -> Bool {
        return lhs.host == rhs.host
    }
    
    func hash(into hasher: inout Hasher) {
        host.hash(into: &hasher)
    }
}
*/
