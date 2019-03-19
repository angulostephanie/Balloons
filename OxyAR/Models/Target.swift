//
//  Target.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 3/5/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

import SceneKit

class Target: SCNNode {
    override init () {
        super.init()
        let geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/brick.png")
        geometry.materials = [material]
        
        self.geometry = geometry
        self.geometry?.materials = [material]
        
        self.position = createRandomVector3()
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = Constants.CollisionCategory.projectile.rawValue
        self.physicsBody?.contactTestBitMask = Constants.CollisionCategory.target.rawValue
        self.name = "Target"
        
    }
    
    private func createRandomVector3 () -> SCNVector3 {
        let randomDouble = Double.random(in: -0.4...0.1)
        let randomDouble2 = Double.random(in: -0.3...0.3)
        return SCNVector3(randomDouble, randomDouble2, -0.7)
    }
    
    private func addRotation() {
        let rotateOnce = SCNAction.rotateBy(x: 0, y: 2*CGFloat.pi, z: 0, duration: 4)
        let rotateSequence = SCNAction.repeatForever(rotateOnce)
        self.runAction(rotateSequence)
    }
    
    
    private func addMovement() {
        let moveDown = SCNAction.move(by: SCNVector3(0, -0.2, 0), duration: 1)
        let moveUp = SCNAction.move(by: SCNVector3(0,0.2,0), duration: 1)
        let waitAction = SCNAction.wait(duration: 0.20)
        let hoverSequence = SCNAction.sequence([moveUp,waitAction,moveDown])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        
        self.runAction(loopSequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
