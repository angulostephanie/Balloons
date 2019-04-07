//
//  HighScoreViewController.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/6/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit

class HighScoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var highScoreTable: UITableView!
    
    var highScores: [Player]! = [Player(username:"Steph", score: 100), Player(username:"brian", score: 200)]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        highScoreTable.delegate = self
        highScoreTable.dataSource = self
        highScoreTable.layer.cornerRadius = 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = highScoreTable.dequeueReusableCell(withIdentifier: "highScoreCell") as! HighScoreCell
        let player = highScores![indexPath.row]
        cell.usernameLabel.text = player.username
        cell.highscoreLabel.text = String(player.score)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        highScoreTable.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    /*
     
     let userID = Auth.auth().currentUser?.uid
     ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
     // Get user value
     let value = snapshot.value as? NSDictionary
     let username = value?["username"] as? String ?? ""
     let user = User(username: username)
     
     // ...
     }) { (error) in
     print(error.localizedDescription)
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
