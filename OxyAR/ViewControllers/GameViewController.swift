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

class GameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    
    var canShoot: Bool = true
    var lives: Int = 3
    var timer: Timer = Timer()
    var seconds: Int = 0
    var score: Int = 0
    
    var hit: Int = 0
    let pointsStr: String = "Points: "
    let livesRemaining: String = "Lives: "
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scoreLabel.text = pointsStr + String(score)
        livesLabel.text = livesRemaining + String(lives)
        timerLabel.text = "00:0" + String(seconds)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self

        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSessionConfiguration()

        runTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func startGame() {
        addNewTarget()
    }
    
    @IBAction func onTap(_ sender: Any) {
        fireBall()
    }
    
    func getUserPosition() -> SCNVector3 {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return pos
        }
        return SCNVector3(0, 0, -0.2)
    }
    
    func getProjectileDirectionFromUserOrientation() -> SCNVector3 {
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(Constants.speedConstant * mat.m31, Constants.speedConstant * mat.m32,
                                 Constants.speedConstant * mat.m33)
            return dir
        }
        return SCNVector3(0, 0, -1)
    }
    
    func fireBall() {
        if canShoot {
            let ball = Projectile()
            ball.position = getUserPosition()
            ball.physicsBody?.applyForce(getProjectileDirectionFromUserOrientation(), asImpulse: true)
            sceneView.scene.rootNode.addChildNode(ball)
            canShoot = false
        }
    }
    
    func runTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                self.seconds += 1
                print(self.seconds)
                
                let minutes = self.seconds / 60
                let secondsMod = self.seconds % 60
                
                let minutesString = minutes < 10 ? "0" + String(minutes) : String(minutes)
                let secondsString = secondsMod < 10 ? ":0" + String(secondsMod) : ":" + String(secondsMod)
                
                self.timerLabel.text = minutesString + secondsString
                
                if self.lives == 0 {
                    self.timer.invalidate()
                    self.timerLabel.text = "GAME OVER"
                }
            })
        }
    }
    
    func addNewTarget() {
        // https://developer.apple.com/documentation/scenekit/scnscene/1524029-rootnode
        // "All scene content—nodes, geometries and their materials, lights, cameras, and related objects—is
        // organized in a node hierarchy with a single common root node."
        
        if lives < 0 {
            let position = getUserPosition()
            let target : SCNNode = Target(userPosition: position).targetNode!
            sceneView.scene.rootNode.addChildNode(target)
            canShoot = false
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
        
        if contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            projectile = contact.nodeB
            hitTarget = contact.nodeA
        }
       
        let explosion = SCNParticleSystem(named: "explode3", inDirectory: "art.scnassets")
        
      
        projectile.addParticleSystem(explosion!)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            projectile.removeFromParentNode()
            self.canShoot = true
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.addNewTarget()
        })
        
        DispatchQueue.main.async {
            hitTarget.removeFromParentNode()
            self.canShoot = true
            self.score += 1
            self.scoreLabel.text = self.pointsStr + String(self.score)
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
                        if (computeDistance(yourPos: yourPosition, nodePos: nodePosition) > Constants.maxProjectileDistance) {
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
                        if (computeDistance(yourPos: yourPosition, nodePos: nodePosition) < 0.20) {
                            return true
                        }
                    }
                    
                }
            }
            return false
        })
        let farAwayTargets = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Target") {
                    if let frame = self.sceneView.session.currentFrame {
                        let matrix = SCNMatrix4(frame.camera.transform)
                        let yourPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                        let nodePosition = node.presentation.position
                        let heightDifference = abs(yourPosition.y - nodePosition.y)
                        // just based on height?
                        if (heightDifference > Constants.maxBalloonHeight) {
                            return true
                        }
                    }
                    
                }
            }
            return false
        })
        
        
        if let arr: [SCNNode] = tooCloseTargets {
            for target in arr {
                self.hit += 1
                DispatchQueue.main.async {
                    target.removeFromParentNode()
                }
                print("TOO DANG CLOSE")
            }
        }
        
        if let arr: [SCNNode] = farAwayTargets {
            for target in arr {
                self.lives -= 1
                DispatchQueue.main.async {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.livesLabel.text = self.livesRemaining + String(self.lives)
                    target.removeFromParentNode()
                    self.addNewTarget()
                }
                print("TOO DANG FAR")
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
