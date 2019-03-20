//
//  Target.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 3/5/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import Foundation

import SceneKit
import ARKit


class Target: SCNNode {
   // var userPosition: SCNVector3 = SCNVector3(0, 0, -0.2)
  
    init (userPosition: SCNVector3) {
        super.init()
        let geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        let material = SCNMaterial()
        let boxVector = createRandomVector3()
        let forceVector = getForceVector(boxPosition: boxVector, userPosition: userPosition)
        print(forceVector)
        print("------------")
        material.diffuse.contents = UIImage(named: "art.scnassets/brick.png")
        geometry.materials = [material]
        
        self.geometry = geometry
        self.geometry?.materials = [material]
        self.position = boxVector
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = Constants.CollisionCategory.projectile.rawValue
        self.physicsBody?.contactTestBitMask = Constants.CollisionCategory.target.rawValue
        self.physicsBody?.applyForce(forceVector, asImpulse: true)
        self.name = "Target"
 
        //addRotation()
    }
    
    private func getForceVector(boxPosition: SCNVector3, userPosition: SCNVector3) -> SCNVector3 {
        let magnitude: Float = (pow((userPosition.x - boxPosition.x), 2) + pow((userPosition.y - boxPosition.y), 2) + pow((userPosition.z - boxPosition.z), 2)).squareRoot()
       
        let unit = SCNVector3((userPosition.x - boxPosition.x)/magnitude, (userPosition.y - boxPosition.y)/magnitude, (userPosition.z - boxPosition.z)/magnitude)
        let speed: Float =  Float.random(in: 0.15...0.35)
        let vector = SCNVector3(speed * unit.x, speed * unit.y, speed * unit.z)
        return vector
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
