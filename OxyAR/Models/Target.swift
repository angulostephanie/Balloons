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
    let colors: [UIColor]! = [UIColor.red, UIColor.blue, UIColor.green, UIColor.purple, UIColor.yellow, UIColor.magenta, UIColor.lightGray, UIColor.cyan, UIColor.orange]
    
    init(speed: Double) {
        super.init()
        targetNode = createBalloonNode(speed: speed)
    }
    
    func createBalloonNode(speed: Double) -> SCNNode {
        let balloonScene = SCNScene(named: "art.scnassets/simple_balloon.scn")!
        let node: SCNNode = balloonScene.rootNode.childNode(withName: "balloon", recursively: true)!
        let shape = SCNPhysicsShape(node: node, options: [SCNPhysicsShape.Option.keepAsCompound: true])
        
        let posVector = createRandomPostition()
        let direction = createRandomForce(speed: speed)
        
        node.geometry?.firstMaterial?.shininess = 0.30
        node.geometry?.firstMaterial?.transparency = 0.89
        node.geometry?.firstMaterial?.diffuse.contents = colors.randomElement()
      
        node.position = posVector
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody?.damping = 0.0
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.projectile.rawValue
        node.physicsBody?.contactTestBitMask = CollisionCategory.target.rawValue
    
        node.physicsBody?.applyForce(direction, asImpulse: true)
        
        node.name = "Target"
        
        addMovement(node: node)
       
        return node
    }
    
    private func createRandomPostition () -> SCNVector3 {
        let randomDouble = Double.random(in: -1.5...1.5)
        let randomDouble2 = Double.random(in: -0.8 ... -0.2)
        let randomDouble3 = Double.random(in: -1.9 ... -1.3)
        return SCNVector3(randomDouble, randomDouble2, randomDouble3)
    }
    
    private func createRandomForce(speed: Double) -> SCNVector3 {
        // .1 to .35
        let upperBound: Double = speed * 0.4
        let randomDouble = Double.random(in: 0.25...upperBound)
        return SCNVector3(0, randomDouble, 0)
    }
    
    
    
    private func addMovement(node: SCNNode) {
        let moveLeft = SCNAction.move(by: SCNVector3(0.05, 0, 0.05), duration: 2)
        let moveRight = SCNAction.move(by: SCNVector3(-0.05, -0.04, -0.05), duration: 2)
        let hoverSequence = SCNAction.sequence([moveLeft, moveRight])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        node.runAction(loopSequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
