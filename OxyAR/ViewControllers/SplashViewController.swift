//
//  SplashView.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 2/12/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class SplashViewController: UIViewController {

    @IBOutlet weak var sessionTableView: UITableView!
    @IBOutlet weak var startGameBtn: UIButton! // start button
    @IBOutlet weak var viewHighScoresBtn: UIButton!
    @IBOutlet weak var howToPlayBtn: UIButton!
    
    var myself: Player?
//    var games: [NetworkGame]! = [NetworkGame(host: Player(peerID: MCPeerID(displayName: "fake person 1"))),
//                                 NetworkGame(host: Player(peerID: MCPeerID(displayName: "fake person 2"))),
//                                 NetworkGame(host: Player(peerID: MCPeerID(displayName: "fake person 3")))]
//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // myself = Player(username: UIDevice.current.name)
//        print(myself?.peerID)
//        print(myself?.username)
//        sessionTableView.dataSource = self
//        sessionTableView.delegate = self
//        sessionTableView.reloadData()
        // Do any additional setup after loading the view.
        applyButtonDesign()
//        sessionTableView.layer.cornerRadius = 7
    }
    
    @IBAction func onStartGameBtn(_ sender: Any) {
        print("host game!")
        self.performSegue(withIdentifier: "gameSegue", sender: nil)
    }
    
    func applyButtonDesign() {
        startGameBtn.layer.cornerRadius = 12
    }
    /*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sessionTableView.dequeueReusableCell(withIdentifier: "gameCell") as! GameCell
        let game = games![indexPath.row]
        cell.game = game
        cell.sessionName.text = game.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sessionTableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
 */
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
