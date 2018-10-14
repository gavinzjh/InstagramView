//
//  LogInViewController.swift
//  InstagramView
//
//  Created by ZJH on 2018/10/15.
//  Copyright © 2018年 ZJH. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.frame = CGRect(x: 10, y: 80, width: self.view.frame.size.width - 20, height: 50)
        usernameText.frame = CGRect(x: 10, y: titleLabel.frame.origin.y + 70, width: self.view.frame.size.width - 20, height: 30)
        passwordText.frame = CGRect(x: 10, y: usernameText.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        logInButton.frame = CGRect(x: 20, y: passwordText.frame.origin.y + 70, width: self.view.frame.size.width / 4, height: 30)
        signUpButton.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: logInButton.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
    }
    
    @objc func hideKeyboard(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        if (usernameText.text?.isEmpty)! || (passwordText.text?.isEmpty)! {
            let alert = UIAlertController(title: "Warning", message: "Please fill all textfields", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        PFUser.logInWithUsername(inBackground: usernameText.text!, password: passwordText.text!) { (user, error) in
            if error == nil {
                UserDefaults.standard.set(user!.username, forKey: "username")
                UserDefaults.standard.synchronize()
                
                let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.login()
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
