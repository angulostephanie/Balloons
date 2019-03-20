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
import AudioToolbox

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var hitLabel: UILabel!
    
    var canShoot: Bool = true
    var timer = Timer()
    var seconds = 15
    var score = 0
    var hit = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = "Score: 0"
        hitLabel.text = "Hit: 0"
        timerLabel.text = String(seconds) + "s"
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
        
        addNewTarget()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
        runTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func onTap(_ sender: Any) {
        fireMissile()
    }
    
    func getUserPosition() -> SCNVector3 {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return pos
        }
        return SCNVector3(0, 0, -0.2)
    }
    
    func getUserOrientation() -> SCNVector3 {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let constant: Float = -2
            let dir = SCNVector3(constant * mat.m31, constant * mat.m32, constant * mat.m33)
            return dir
        }
        return SCNVector3(0, 0, -1)
    }
    
    func fireMissile() {
        if canShoot {
            let missile = Projectile()
            
            missile.position = getUserPosition()
            missile.physicsBody?.applyForce(getUserOrientation(), asImpulse: true)
            
            sceneView.scene.rootNode.addChildNode(missile)
            canShoot = false
        } else {
            print("can't shoot yet")
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            self.seconds -= 1
            print(self.seconds)
            self.timerLabel.text = String(self.seconds) + "s"
            if self.seconds == 0 {
                self.timer.invalidate()
                self.timerLabel.text = "GAME OVER :("
            }
        })

    }
    
    func addNewTarget() {
        // https://developer.apple.com/documentation/scenekit/scnscene/1524029-rootnode
        // "All scene content—nodes, geometries and their materials, lights, cameras, and related objects—is organized in a node hierarchy with a single common root node."
        if seconds > 0 {
            let position = getUserPosition()
            let target = Target(userPosition: position)
            print("adding new target")
            sceneView.scene.rootNode.addChildNode(target)
        }
    }
    
    func setupSessionConfiguration()  {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    // MARK: - Contact Delegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // http://sfbgames.com/chiptone/
        var projectile: SCNNode = contact.nodeA
        var hitTarget: SCNNode = contact.nodeB
        
        if contact.nodeB.physicsBody?.categoryBitMask == Constants.CollisionCategory.target.rawValue {
            projectile = contact.nodeB
            hitTarget = contact.nodeA
        }
        projectile.removeFromParentNode()
        self.canShoot = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            hitTarget.removeFromParentNode()
            self.score += 1
            self.scoreLabel.text = "Score: " + String(self.score)
            self.addNewTarget()
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
    func computeDistance(yourPos: SCNVector3, nodePos: SCNVector3) -> Float {
        return (pow(yourPos.x - nodePos.x, 2) + pow(yourPos.y - nodePos.y, 2) + pow(yourPos.z - nodePos.z, 2)).squareRoot()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // remove projectiles that are too far
        // maybe do this based off time instead idk
        let farAwayProjectiles = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Projectile") {
                     if let frame = self.sceneView.session.currentFrame {
                        // frame.camera.transform
                        let matrix = SCNMatrix4(frame.camera.transform)
                        let yourPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                        let nodePosition = node.presentation.position
                        
                        // https://stackoverflow.com/questions/52565937/arkit-after-apply-force-get-location-of-node
                        if (computeDistance(yourPos: yourPosition, nodePos: nodePosition) > 1.2) {
                            return true
                        }
                    }
                   
                }
            }
            return false
        })
        
        // if a target is too close, it "hits" the user
        // -1 on their overall score
        let tooCloseTargets = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Target") {
                    if let frame = self.sceneView.session.currentFrame {
                        let matrix = SCNMatrix4(frame.camera.transform)
                        let yourPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                        let nodePosition = node.presentation.position
                        // https://stackoverflow.com/questions/52565937/arkit-after-apply-force-get-location-of-node
                        if (computeDistance(yourPos: yourPosition, nodePos: nodePosition) < 0.15) {
                            return true
                        }
                    }
                    
                }
            }
            return false
        })
        
        // redirect targets if they're moving away from the user
        // this can happen when a user first dodges the target
        
        /*
        let tooFarTargets = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Target") {
                    if let frame = self.sceneView.session.currentFrame {
                        let matrix = SCNMatrix4(frame.camera.transform)
                        let yourPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                        let nodePosition = node.presentation.position
                        // https://stackoverflow.com/questions/52565937/arkit-after-apply-force-get-location-of-node
                        if (computeDistance(yourPos: yourPosition, nodePos: nodePosition) < 0.15) {
                            return true
                        }
                    }
                    
                }
            }
            return false
        })
         */
        
        if let arr: [SCNNode] = tooCloseTargets {
            for target in arr {
                self.hit += 1
                DispatchQueue.main.async {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.hitLabel.text = "Hit: " + String(self.hit)
                }
                target.removeFromParentNode()
                print("TOO DANG CLOSE")
                addNewTarget()
            }
        }
        
        if let arr: [SCNNode] = farAwayProjectiles {
            for projectile in arr {
                projectile.removeFromParentNode()
                print("REMOVING PROJECTILE")
                canShoot = true
            }
        }
    }
    
    // https://developer.apple.com/documentation/arkit/managing_session_lifecycle_and_tracking_quality
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("was interrupted")
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
         print("interruption ended")
       
        
    }
    /*
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        //ARCamera.TrackingState.Reason.relocalizing
        return true
    }
 */
}
