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


class Target: NSObject {
    var targetNode: SCNNode?
    init (userPosition: SCNVector3) {
        super.init()
        targetNode = createBalloonNode(userPos: userPosition)
    }
    
    func createBalloonNode(userPos: SCNVector3) -> SCNNode {
        let balloonScene = SCNScene(named: "art.scnassets/simple_balloon.scn")!
        let node: SCNNode = balloonScene.rootNode.childNode(withName: "balloon", recursively: true)!
        let shape = SCNPhysicsShape(node: node, options: [SCNPhysicsShape.Option.keepAsCompound: true])
        
        let posVector = createRandomPostition()
        let direction = createRandomDirection()
        node.geometry?.firstMaterial?.shininess = 0.5
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
      
        node.position = posVector
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody?.damping = 0.0
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = Constants.CollisionCategory.projectile.rawValue
        node.physicsBody?.contactTestBitMask = Constants.CollisionCategory.target.rawValue
        /*
         let negativeHorizontal = Int(arc4random_uniform(2)) == 0 ? -1 : 1
         let xCord = 10 + Float(arc4random_uniform(50))
         let yCord = 20 + Float(arc4random_uniform(100))
         balloonNode.physicsBody?.applyForce(SCNVector3(Float(negativeHorizontal)*xCord,yCord,0), asImpulse: false)
         */
        node.physicsBody?.applyForce(direction, asImpulse: true)
        
        node.name = "Target"
       // addMovement(node: node)
       
        print(node)
        return node
    }
    
    /*
    private func getForceVector(position: SCNVector3, userPosition: SCNVector3) -> SCNVector3 {
        let magnitude: Float = (pow((userPosition.x - position.x), 2) + pow((userPosition.y - position.y), 2) + pow((userPosition.z - position.z), 2)).squareRoot()
       
        let unit = SCNVector3((userPosition.x - position.x)/magnitude, (userPosition.y - position.y)/magnitude, (userPosition.z - position.z)/magnitude)
        let speed: Float =  Float.random(in: 0.15...0.35)
        let vector = SCNVector3(speed * unit.x, speed * unit.y, speed * unit.z)
        return vector
    }
*/
    // node.position = SCNVector3(-0.2, 0.1, -0.7)
    private func createRandomPostition () -> SCNVector3 {
        let randomDouble = Double.random(in: -0.4...0.5)
        let randomDouble2 = Double.random(in: -0.3...0.0)
        let randomDouble3 = Double.random(in: -2 ... -1)//Double.random(in: -2.0... -1.0)
        return SCNVector3(randomDouble, randomDouble2, randomDouble3) // (x, y, )
    }
    
    private func createRandomDirection () -> SCNVector3 {
        // .1 to .35
        let randomDouble = Double.random(in: 0.2...0.35)
        return SCNVector3(0, randomDouble, 0)
    }
    
    private func addRotation(node: SCNNode) {
        let rotateOnce = SCNAction.rotateBy(x: 0, y: 2*CGFloat.pi, z: 0, duration: 4)
        let rotateSequence = SCNAction.repeatForever(rotateOnce)
        node.runAction(rotateSequence)
    }
    
    
    private func addMovement(node: SCNNode) {
        let moveDown = SCNAction.move(by: SCNVector3(0.01, -0.15, 0), duration: 2)
        let moveUp = SCNAction.move(by: SCNVector3(-0.01,0.15,0), duration: 2)
        let waitAction = SCNAction.wait(duration: 0.02)
        let hoverSequence = SCNAction.sequence([moveUp,waitAction,moveDown])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        node.runAction(loopSequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
