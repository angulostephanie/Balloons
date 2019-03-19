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
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var targetPositionLabel: UILabel!
    @IBOutlet weak var userVectorLabel: UILabel!
    @IBOutlet weak var projectileDirectionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let target = Target()
        userVectorLabel.text = ""
        projectileDirectionLabel.text = ""
        targetPositionLabel.text = "Target pos (" + (NSString(format: "%.2f", target.position.x) as String) + ", " + (NSString(format: "%.2f", target.position.y) as String) + ", " + (NSString(format: "%.2f", target.position.z) as String) + ")"
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        // Set the scene to the view
        
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
        
        // https://developer.apple.com/documentation/scenekit/scnscene/1524029-rootnode
        // "All scene content—nodes, geometries and their materials, lights, cameras, and related objects—is organized in a node hierarchy with a single common root node."
        sceneView.scene.rootNode.addChildNode(Target())
        
//        sceneView.scene.rootNode.addChildNode(boxNode) // explain this
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
        fireMissile()
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            projectileDirectionLabel.text = "Projectile dir: at (" + (NSString(format: "%.2f", dir.x) as String) + ", " + (NSString(format: "%.2f", dir.y) as String) + ", " + (NSString(format: "%.2f", dir.z) as String) + ")"
            userVectorLabel.text = "User pos: (" + (NSString(format: "%.2f", pos.x) as String) + ", " + (NSString(format: "%.2f", pos.y) as String) + ", " + (NSString(format: "%.2f", pos.z) as String) + ")"
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func fireMissile() {
        let missile = Projectile()
        let (direction, position) = self.getUserVector()
        
        missile.position = position
        missile.physicsBody?.applyForce(direction, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(missile)
    }
    
    
    // MARK: - Contact Delegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var projectile: SCNNode = contact.nodeA
        var hitTarget: SCNNode = contact.nodeB
        
        if contact.nodeB.physicsBody?.categoryBitMask == Constants.CollisionCategory.target.rawValue {
            projectile = contact.nodeB
            hitTarget = contact.nodeA
        }
        projectile.removeFromParentNode()

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            hitTarget.removeFromParentNode()
            // add a new target
            let target = Target()
            self.targetPositionLabel.text = "Target pos (" + (NSString(format: "%.2f", target.position.x) as String) + ", " + (NSString(format: "%.2f", target.position.y) as String) + ", " + (NSString(format: "%.2f", target.position.z) as String) + ")"
            self.sceneView.scene.rootNode.addChildNode(target)
        })
            
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
