//
//  HighScoreViewController.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/6/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HighScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var highScoreTable: UITableView!
    
    @IBOutlet weak var mainMenuBtn: UIButton!
    
    var players: [Player]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        highScoreTable.delegate = self
        highScoreTable.dataSource = self
        highScoreTable.allowsSelection = false
        highScoreTable.layer.cornerRadius = 8
        mainMenuBtn.layer.cornerRadius = 12
        fetchHighScores()
    }
    
    func fetchHighScores() {
        DispatchQueue.global().async {
            var topPlayers: [Player]! = []
            var count = 0
            let ref: DatabaseReference! = Database.database().reference()
            ref.child("scores").queryOrdered(byChild: "highscore").observe(.value, with: { (snapshot) in
                for snap in snapshot.children {
                    if count == 15 { break }
                    let object = snap as! DataSnapshot
                    let dictionary = object.value as! [String: AnyObject]
                    let username = dictionary["username"] as! String
                    let highscore = dictionary["highscore"] as! Int
                    print(username)
                    print(highscore)
                    topPlayers.insert(Player(username: username, score: highscore), at: 0)
                    count = count + 1
                }
                self.players = topPlayers
                self.highScoreTable.reloadData()
            })
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = highScoreTable.dequeueReusableCell(withIdentifier: "highScoreCell") as! HighScoreCell
        let player = players![indexPath.row]
        cell.usernameLabel.text = player.username
        cell.highscoreLabel.text = String(player.score)
        return cell
    }
    
    
    @IBAction func onMainMenuBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "backToMainMenuSegue", sender: nil)
    }
    
}
