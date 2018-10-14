//
//  SignUpViewController.swift
//  InstagramView
//
//  Created by ZJH on 2018/10/15.
//  Copyright © 2018年 ZJH. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var repeatPasswordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var scrollViewHeight: CGFloat = 0
    var keyboard = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboardTap(_:)))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width/2
        profilePhoto.clipsToBounds = true
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(self.chooseProfilePhoto(_:)))
        imageTap.numberOfTapsRequired = 1
        profilePhoto.isUserInteractionEnabled = true
        profilePhoto.addGestureRecognizer(imageTap)
        
        profilePhoto.frame = CGRect(x: self.view.frame.size.width / 2 - 40, y: 40, width: 80, height: 80)
        usernameText.frame = CGRect(x: 10, y: profilePhoto.frame.origin.y + 90, width: self.view.frame.size.width - 20, height: 30)
        emailText.frame = CGRect(x: 10, y: usernameText.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        passwordText.frame = CGRect(x: 10, y: emailText.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        repeatPasswordText.frame = CGRect(x: 10, y: passwordText.frame.origin.y + 40, width: self.view.frame.size.width - 20, height: 30)
        signUpButton.frame = CGRect(x: 20, y: repeatPasswordText.frame.origin.y + 50, width: self.view.frame.size.width / 4, height: 30)
        cancelButton.frame = CGRect(x: self.view.frame.size.width - self.view.frame.size.width / 4 - 20, y: signUpButton.frame.origin.y, width: self.view.frame.size.width / 4, height: 30)
    }
    
    @objc func chooseProfilePhoto(_ recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePhoto.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboardTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(_ notification: Notification) {
        keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue)!
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.scrollViewHeight - self.keyboard.height
        }
    }
    
    @objc func hideKeyboard(_ notification: Notification) {
        UIView.animate(withDuration: 0.4) {
            self.scrollView.frame.size.height = self.view.frame.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        if (usernameText.text?.isEmpty)! || (emailText.text?.isEmpty)! || (passwordText.text?.isEmpty)! || (repeatPasswordText.text?.isEmpty)! {
            let alert = UIAlertController(title: "Warning", message: "Please fill all textfields", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        if passwordText.text != repeatPasswordText.text {
            let alert = UIAlertController(title: "Warning", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        let user = PFUser()
        user.username = usernameText.text?.lowercased()
        user.email = emailText.text?.lowercased()
        user.password = passwordText.text
        
        let photoData = UIImageJPEGRepresentation(profilePhoto.image!, 0.5)
        let photoFile = PFFile(name: "profilePhoto.jpg", data: photoData!)
        user["profilePhoto"] = photoFile
        
        user.signUpInBackground { (success, error) in
            if success {
                UserDefaults.standard.set(user.username, forKey: "username")
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
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
