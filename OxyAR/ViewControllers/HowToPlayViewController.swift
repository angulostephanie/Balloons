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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
