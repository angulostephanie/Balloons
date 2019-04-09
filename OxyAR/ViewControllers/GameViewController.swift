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
import AVFoundation

class GameViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var targetImage: UIImageView!
    
    var canShoot: Bool = false
    var lives: Int = 3
    var timer: Timer = Timer()
    var seconds: Int = 0
    var score: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetImage.isHidden = true
        scoreLabel.text = String(score)
        livesLabel.text = String(lives)
        timerLabel.text = ""
        
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
        startGame()
        targetImage.isHidden = false
        canShoot = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    
    @IBAction func onTap(_ sender: Any) {
        fireBall()
    }
    
    func startGame() {
        addNewTarget()
    }
    
    func setupSessionConfiguration()  {
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.vertical, .horizontal]
        configuration.worldAlignment = .gravity
        sceneView.session.run(configuration)
    }
    
    func addNewTarget() {
        if lives > 0 {
            canShoot = true
            let balloons = determineNumberOfNewBalloons()
            for _ in 1...balloons {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.7, execute: {
                    // https://stackoverflow.com/questions/41180748/how-to-add-scnnodes-without-blocking-main-thread?noredirect=1&lq=1
                    // creating nodes should be done on a background thread
                    let speed = 1.0 + (Double(Int(self.score / 5)) * 0.1)
                    let target : SCNNode = Target(speed: speed).targetNode!
                    DispatchQueue.main.async {
                        self.sceneView.scene.rootNode.addChildNode(target)
                    }
                })
            }
        } else {
            self.canShoot = false
        }
    }
    
    func fireBall() {
        if canShoot {
            DispatchQueue.global(qos: .background).async {
                /*
                 Create the projectile's geometry on the background thread
                 */
                let ball = Projectile()
                ball.position = self.getUserPosition()
                ball.physicsBody?.applyForce(self.getProjectileDirection(), asImpulse: true)
                DispatchQueue.main.async {
                    /*
                     Call the main thread and add it onto the scene graph.
                     */
                    self.sceneView.scene.rootNode.addChildNode(ball)
                }
            }
            canShoot = false
        }
    }
    
    func runTimer() {
        /*
         This was used previously when the game was based on a countdown timer.
         Now, this just helps us segue into our next view controller when the user loses.
         */
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            self.seconds += 1
            if self.lives <= 0 {
                self.timer.invalidate()
                self.targetImage.isHidden = true
                self.timerLabel.text = "game over!"
                self.canShoot = false
                /*
                 Seguing into the next view controller with a small delay so transition seems a bit more natural.
                 */
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                      self.performSegue(withIdentifier: "gameOverSegue", sender: String(self.score))
                })
            }
        })
    }
    
    func getUserPosition() -> SCNVector3 {
        /*
         The last row of the ARCamera's transformation matrix is the camera's current position
         */
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43)
            return pos
        }
        return SCNVector3(0, 0, -0.2)
    }
    
    func getProjectileDirection() -> SCNVector3 {
        /*
         Right now, projectiles are designed to shoot directly out into the -z direction.
         The third row of the ARCamera's transformation matrix is the z unit vector.
         This function then multiplies the unit vector by some negative constant to 1. add speed to
         the projectile and 2. ensure the projectile shoots out of the camera, rather than into it.
         */
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform)
            let dir = SCNVector3(Constants.speedConstant * mat.m31, Constants.speedConstant * mat.m32,
                                 Constants.speedConstant * mat.m33)
            return dir
        }
        return SCNVector3(0, 0, -1)
    }
    
    func determineNumberOfNewBalloons() -> Int {
        /*
         Randomizes how many balloons appear upon balloon creation.
         Dependent on user's score.
         */
        let x = score / 10
        return Int.random(in: Constants.balloonsLowerBound ... Constants.balloonsLowerBound + x + 1)
    }
    
    
    // MARK: - Contact Delegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var projectile: SCNNode = contact.nodeA
        var hitTarget: SCNNode = contact.nodeB
        
        if contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.target.rawValue {
            projectile = contact.nodeB
            hitTarget = contact.nodeA
        }
       
        let explosion = SCNParticleSystem(named: "explode3", inDirectory: "art.scnassets")
        hitTarget.addParticleSystem(explosion!)
        
        
        let numberOfNodes = numberOfActiveBalloonNodes()
        DispatchQueue.main.async {
            hitTarget.removeFromParentNode()
            self.score += 1
            self.scoreLabel.text = String(self.score)
            projectile.removeFromParentNode()
            self.canShoot = true
            /*
             Only add new targets if there are less than 2 balloons on the screen.
             The game is difficult as it is lol.
             */
            if numberOfNodes < 2 {
                self.addNewTarget()
            }
        }
        
    }
    
    func numberOfActiveBalloonNodes() -> Int {
        /*
         Counts the number of nodes with the name "Target" – aka returns number of balloons.
        */
        return self.sceneView.scene.rootNode.childNodes.filter({ $0.name == "Target" }).count
    }
    
    func computeDistance(yourPos: SCNVector3, nodePos: SCNVector3) -> Float {
        /*
         
         */
        return (pow(yourPos.x - nodePos.x, 2) + pow(yourPos.y - nodePos.y, 2) + pow(yourPos.z - nodePos.z, 2)).squareRoot()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        /*
         Remove targets if they (for some reason) appear too close to the camera.
         Weird things happen when the SCNNodes appear too close (the geometry is completely distorted).
         */
        if let arr: [SCNNode] = getCloseTargets() {
            for target in arr {
                DispatchQueue.main.async {
                    target.removeFromParentNode()
                }
            }
        }
        
        /*
         Remove targets if they fly too far away!
         Decrement lives and create a vibration, notifying the user they messed up.
         */
        if let arr: [SCNNode] = getFarTargets() {
            for target in arr {
                if lives > 0 {
                     self.lives -= 1
                }
                DispatchQueue.main.async {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.livesLabel.text = String(self.lives)
                    target.removeFromParentNode()
                    let balloons = self.numberOfActiveBalloonNodes()
                    /*
                     Again, only add new balloons if there are currently less than 2 in the view.
                     */
                    if balloons < 2 {
                        self.addNewTarget()
                    }
                }
            }
        }
        
        /*
         Remove projectiles from view once they're far away enough.
         */
        if let arr: [SCNNode] = getFarProjectiles() {
            for projectile in arr {
                projectile.removeFromParentNode()
                canShoot = true
            }
        }
    }
    
    func getCloseTargets() -> [SCNNode]? {
        let tooCloseTargets = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Target") {
                    if let frame = self.sceneView.session.currentFrame {
                        let matrix = SCNMatrix4(frame.camera.transform)
                        let yourPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                        /*
                            https://stackoverflow.com/questions/52565937/arkit-after-apply-force-get-location-of-node
                            node.presentation.position get the UPDATED position of the node.
                            SCNNodes have updating positions once a physics force is applied
                            In this game, all the the involved nodes have updating positions.
                        */
                       
                        let nodePosition = node.presentation.position
                        if (computeDistance(yourPos: yourPosition, nodePos: nodePosition) < Constants.minBalloonDistance) {
                            return true
                        }
                    }
                }
            }
            return false
        })
        
        return tooCloseTargets
    }
    
    func getFarTargets() -> [SCNNode]? {
        let farAwayTargets = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Target") {
                    if let frame = self.sceneView.session.currentFrame {
                        let matrix = SCNMatrix4(frame.camera.transform)
                        let yourPosition = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
                        let nodePosition = node.presentation.position
                        let heightDifference = abs(yourPosition.y - nodePosition.y)
                        if (heightDifference > Constants.maxBalloonHeight) {
                            return true
                        }
                    }
                    
                }
            }
            return false
        })
        return farAwayTargets
    }
    
    func getFarProjectiles() -> [SCNNode]? {
        let farAwayProjectiles = self.sceneView?.scene.rootNode.childNodes(passingTest: { (node, stop) -> Bool in
            if (node.name != nil) {
                if (node.name == "Projectile") {
                    if let frame = self.sceneView.session.currentFrame {
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
        
        return farAwayProjectiles
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameOverSegue" {
            let gameOverController = segue.destination as! GameOverViewController
            gameOverController.score = self.score
        }
    }
    
}
