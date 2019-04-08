//
//  SplashView.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 2/12/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var startGameBtn: UIButton! // start button
    

    override func viewDidLoad() {
        super.viewDidLoad()
        startGameBtn.layer.cornerRadius = 12
    }
    
    
    @IBAction func onHighScoresBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "highScoreSegue", sender: nil)
    }
    
    @IBAction func onStartGameBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "gameSegue", sender: nil)
    }
    
    @IBAction func onHowToPlayBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "howToPlaySegue", sender: nil)
    }
}
