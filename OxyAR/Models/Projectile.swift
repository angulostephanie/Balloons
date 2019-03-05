//
//  Projectile.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 3/5/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

import SceneKit

class Bullet: SCNNode {
    override init () {
        super.init()
        let geometry = SCNSphere(radius: 0.03)
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.isDoubleSided = true
        geometry.materials = [material]
        let sphereNode = SCNNode(geometry: geometry)
        
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        sphereNode.physicsBody?.isAffectedByGravity = false
        sphereNode.physicsBody?.categoryBitMask = CollisionCategory.missiles.rawValue
        sphereNode.physicsBody?.contactTestBitMask = CollisionCategory.target.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
