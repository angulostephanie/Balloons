//
//  NetworkPlayer.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/1/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct Player {
    
    let peerID: MCPeerID
    var username: String { return peerID.displayName }
    
    init(peerID: MCPeerID) {
        self.peerID = peerID
    }
    
    init(username: String) {
        self.peerID = MCPeerID(displayName: username)
    }
}

//extension Player: Hashable {
//    static func == (lhs: Player, rhs: Player) -> Bool {
//        return lhs.peerID == rhs.peerID
//    }
//
//    func hash(into hasher: inout Hasher) {
//        peerID.hash(into: &hasher)
//    }
//}
