//
//  HowToPlayViewController.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/6/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit

class HowToPlayViewController: UIViewController {

    @IBOutlet weak var mainMenuBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMenuBtn.layer.cornerRadius = 12
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onMainMenuBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "backToMainMenu2Segue", sender: nil)
    }

}
