//
//  GameOverViewController.swift
//  OxyAR
//
//  Created by Stephanie Angulo on 4/7/19.
//  Copyright © 2019 Stephanie Angulo. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GameOverViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var inputNameField: UITextField!
    
    var score: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = String(score)
        
        inputNameField.delegate = self
        hideKeyboardWhenOutsideTap()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboard(notification:)), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @IBAction func onSendMyScorebtn(_ sender: Any) {
        let name = inputNameField.text
        if let username = name {
            if username.count == 0 {
                let alert = UIAlertController(title: "Username needed", message: "Please enter in a username in the input field.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in print("cool") }))
                self.present(alert, animated: true, completion: nil)
            } else if username.count < 2 {
                print("username must be greater than 2 characters")
                let alert = UIAlertController(title: "Invalid username", message: "Please enter in a username longer than 2 characters.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in print("cool") }))
                self.present(alert, animated: true, completion: nil)
            } else {
                addScoreToDatabase(username: username)
                returnToMainMenu()
            }
        } else {
            let alert = UIAlertController(title: "Username needed", message: "Please enter in a username in the input field.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in print("cool") }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onNoThanksBtn(_ sender: Any) {
        returnToMainMenu()
    }
    
    func returnToMainMenu() {
        self.performSegue(withIdentifier: "mainMenuSegue", sender: nil)
    }
    
    @objc func keyboard(notification:Notification) {
        guard let keyboardReact = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification ||  notification.name == UIResponder.keyboardWillChangeFrameNotification {
            self.view.frame.origin.y = -keyboardReact.height
        } else {
            self.view.frame.origin.y = 0
        }
        
    }
    // https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
    func hideKeyboardWhenOutsideTap() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    func addScoreToDatabase(username: String!) {
        DispatchQueue.global().async {
            let ref: DatabaseReference! = Database.database().reference()
            ref.child("scores").childByAutoId().setValue(["username": username, "highscore": self.score], withCompletionBlock: { (error: Error?, ref: DatabaseReference) in
                if let error = error {
                    print("data was not successfully added.")
                    print(error)
                } else {
                    print("successfully added")
                }
            })
            
        }
    }
    
}
