//
//  ViewController.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 2/5/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    struct CollisionCategory: OptionSet {
        let rawValue: Int
        static let missiles  = CollisionCategory(rawValue: 1 << 0)
        static let projectile = CollisionCategory(rawValue: 1 << 1)
    }
    
    @IBOutlet weak var counter: UILabel!
    @IBOutlet var sceneView: ARSCNView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        
        let boxNode = createBoxNode(with: 0.1)
        boxNode.position = SCNVector3(-0.4, 0.1, -0.4)
        boxNode.name = "box"
        
        let boxNode2 = createBoxNode(with: 0.1)
        boxNode2.position = SCNVector3(-0.7, 0.1, -0.7)
        boxNode2.name = "box"
        
        boxNode.physicsBody?.categoryBitMask = CollisionCategory.projectile.rawValue
        boxNode.physicsBody?.contactTestBitMask = CollisionCategory.missiles.rawValue
        boxNode.physicsBody?.collisionBitMask = 0
        
        boxNode2.physicsBody?.categoryBitMask = CollisionCategory.projectile.rawValue
        boxNode2.physicsBody?.contactTestBitMask = CollisionCategory.missiles.rawValue
        boxNode2.physicsBody?.collisionBitMask = 0
        // Set the scene to the view
        
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
       // print(sceneView.scene.physicsWorld.contactDelegate)
        sceneView.scene.rootNode.addChildNode(boxNode) // explain this
        sceneView.scene.rootNode.addChildNode(boxNode2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func onTap(_ sender: Any) {
        /*
        let randomDouble = Double.random(in: -1...1)
        let randomDouble2 = Double.random(in: -0.5...0.5)
        let boxNode = createBoxNode(with: 0.05)
        boxNode.position = SCNVector3(randomDouble, randomDouble2, randomDouble) // 1 meter in front of camera
        boxNode.constraints = [SCNBillboardConstraint()]
        */
        // Set the scene to the view
        // sceneView.scene.rootNode.addChildNode(boxNode)
        print("tap")
        print("fire!!!")
        fireMissile()
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func createMissile(with radius: CGFloat) -> SCNNode {
        let geometry = SCNSphere(radius: radius)
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.isDoubleSided = true
        geometry.materials = [material]
        let sphereNode = SCNNode(geometry: geometry)
        
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        sphereNode.physicsBody?.isAffectedByGravity = false
        sphereNode.physicsBody?.categoryBitMask = CollisionCategory.missiles.rawValue
        sphereNode.physicsBody?.contactTestBitMask = CollisionCategory.projectile.rawValue
        sphereNode.physicsBody?.collisionBitMask = CollisionCategory.projectile.rawValue
        return sphereNode
    }
    
    func fireMissile() {
        let missile = createMissile(with: 0.03)
        let (direction, position) = self.getUserVector()
        
        missile.position = position
        missile.physicsBody?.applyForce(direction, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(missile)
    }
    
    func createSphereNode(with radius: CGFloat) -> SCNNode {
        //let image = UIImage(named: "art.scnassets/earth.png")
        let geometry = SCNSphere(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/earth.png")
        material.isDoubleSided = true
        geometry.materials = [material]
        let sphereNode = SCNNode(geometry: geometry)
        print("hello")

        return addRotationToNode(with: sphereNode)
    }

    func createBoxNode(with len: CGFloat) -> SCNNode {
        let geometry = SCNBox(width: len, height: len, length: len, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/brick.png")
        geometry.materials = [material]
        
        let boxNode = SCNNode(geometry: geometry)
        print("box")
        
        return addRotationToNode(with: boxNode)
    }
    
    func addRotationToNode(with node:SCNNode) -> SCNNode {
        let rotateOnce = SCNAction.rotateBy(x: 0, y: 2*CGFloat.pi, z: 0, duration: 4)
        let rotateSequence = SCNAction.repeatForever(rotateOnce)
        node.runAction(rotateSequence)
        return node
    }
    func addAnimationToNode(with node:SCNNode) -> SCNNode {
        let moveDown = SCNAction.move(by: SCNVector3(0, -0.2, 0), duration: 1)
        let moveUp = SCNAction.move(by: SCNVector3(0,0.2,0), duration: 1)
        let waitAction = SCNAction.wait(duration: 0.20)
        let hoverSequence = SCNAction.sequence([moveUp,waitAction,moveDown])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        
        node.runAction(loopSequence)
        return node
    }
    
    // MARK: - Contact Delegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("hello, collision! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            
            
            print("hit!!!!")
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
