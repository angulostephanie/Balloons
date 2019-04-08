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
    
    var canShoot: Bool = false
    var lives: Int = 3
    var timer: Timer = Timer()
    var seconds: Int = 0
    var score: Int = 0
    
    var balloonsLowerBound: Int = 1
    
    var hit: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        configuration.planeDetection = [.vertical]
        sceneView.session.run(configuration)
    }
    
    func addNewTarget() {
        // https://developer.apple.com/documentation/scenekit/scnscene/1524029-rootnode
        // "All scene content—nodes, geometries and their materials, lights, cameras, and related objects—is
        // organized in a node hierarchy with a single common root node."
        
        if lives > 0 {
            canShoot = true
            let balloons = determineNumberOfNewBalloons()
            print("ADDING THIS MANY BALLOONS")
            print(balloons)
            for _ in 1...balloons {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5, execute: {
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
                let ball = Projectile()
                ball.position = self.getUserPosition()
                ball.physicsBody?.applyForce(self.getProjectileDirectionFromUserOrientation(), asImpulse: true)
                DispatchQueue.main.async {
                    self.sceneView.scene.rootNode.addChildNode(ball)
                }
            }
            canShoot = false
        }
    }
    
    func runTimer() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
                self.seconds += 1
                if self.lives <= 0 {
                    self.timer.invalidate()
                    self.timerLabel.text = "game over!"
                    self.canShoot = false
                   // DispatchQueue.main.sync
                    self.performSegue(withIdentifier: "gameOverView", sender: nil)
                }
            })
        }
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
    
    func determineNumberOfNewBalloons() -> Int {
        let x = score / 10
        return Int.random(in: balloonsLowerBound ... balloonsLowerBound + x + 1)
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
        
       
        playSound(sound : "balloon_pop", format: "mp3")
        
        
        let numberOfNodes = numberOfActiveBalloonNodes()
        DispatchQueue.main.async {
            hitTarget.removeFromParentNode()
            self.score += 1
            self.scoreLabel.text = String(self.score)
            projectile.removeFromParentNode()
            self.canShoot = true
            if numberOfNodes < 2 {
                print("BALLO0N WAS HIT - number of nodes currently???")
                print(numberOfNodes)
                self.addNewTarget()
            }
        }
        
    }
    
    func numberOfActiveBalloonNodes() -> Int {
        return self.sceneView.scene.rootNode.childNodes.filter({ $0.name == "Target" }).count
    }
    
    // https://stackoverflow.com/questions/32036146/how-to-play-a-sound-using-swift
    func playSound(sound : String, format: String) {
        var player: AVAudioPlayer?
        if let url = Bundle.main.url(forResource: sound, withExtension: format) {
            do {
                print("url")
                print(url)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                guard let player = player else { return }
                player.play()
                print("playing?")
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("no sound")
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
        if let arr: [SCNNode] = getCloseTargets() {
            for target in arr {
                DispatchQueue.main.async {
                    target.removeFromParentNode()
                    print("too close")
                }
            }
        }
        
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
                    if balloons < 2 {
                        self.addNewTarget()
                    }
                }
            }
        }
        
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
                        let nodePosition = node.presentation.position
                        // https://stackoverflow.com/questions/52565937/arkit-after-apply-force-get-location-of-node
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
                        // just based on height?
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
    
}
