//
//  SignUpViewController.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 21/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet var userlineViews: [UIView]!
    
    var animator: Animator!
    var messenger: Message!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.Setup()
    }
    
    @IBAction func signUp(_ sender:UIButton) {
        if userName.text != "" && email.text != "" && password.text != "" && confirmPassword.text != "" {
            if password.text == confirmPassword.text {
                self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
                self.register()
            } else {
                //password and confirm password is not same
                messenger.show(massage: "Password and confirm password is not equal!", massageTitle: "Field Error", andAlertTitle: "Ok")
            }
        } else {
            // every field is required
            messenger.show(massage: "All fields are required!", massageTitle: "Field Error", andAlertTitle: "Ok")
        }
    }
    
    @IBAction func signIn(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.userlineViews[textField.tag].backgroundColor = CustomColour.appThemeColour
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for index in 0..<self.userlineViews.count {
            self.userlineViews[index].backgroundColor = CustomColour.viewColour
        }
    }
}

extension SignUpViewController {
    
    // for private function
    private func Setup() {
        self.email.delegate = self
        self.password.delegate = self
        self.userName.delegate = self
        self.confirmPassword.delegate = self
        
        self.signUpButton.layer.cornerRadius = 10
        self.signUpView.layer.cornerRadius = 10
        setUp().makeCardView(forView: self.signUpView, withShadowHight: 4, shadowWidth: 0, shadowOpacity: 0.3, shadowRadius: 15)
        self.animator = Animator(view: self.view)
        self.messenger = Message(superViewController: self)
    }
    
    //Networking
    private func register() {
        let param = ["email": email.text!, "name": userName.text!, "pass": password.text!]
        Network().getResponse(from: url.signUp, having: param, method: .post) { (response) in
            self.animator.stopAnimation()
            if let response = response {
                switch response["status"] {
                case 200:
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(self.email.text!, forKey: "email")
                    self.dismiss(animated: true, completion: nil)
                case 409:
                    self.messenger.show(massage: "User already existing!", massageTitle: "User Error", andAlertTitle: "Ok")
                case 400:
                    self.messenger.show(massage: "Bad request made", massageTitle: "App Error", andAlertTitle: "Ok")
                default:
                    //something wint wrong
                    self.messenger.show(massage: "Something went wrong!", massageTitle: "Server Error", andAlertTitle: "Ok")
                    break
                }
            } else {
                //login failed due to network issue
                self.messenger.show(massage: "Please check your netwrk connection!", massageTitle: "Network Eroor", andAlertTitle: "Ok")
            }
        }
    }
}
