//
//  SignUpViewController.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 21/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit

protocol SignInProtocol {
    func didDismiss(address: String?, email: String?)
}


class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextView: UIView!
    @IBOutlet weak var passwordTextView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var animator: Animator!
    var messenger: Message!
    var delegate: SignInProtocol?
    var isLoggedIn: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.Setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if  self.isLoggedIn == true{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isLoggedIn == true {
            delegate?.didDismiss(address: nil, email: nil)
        }
    }
    
    @IBAction func signUP(_ sender: UIButton){
        performSegue(withIdentifier: Segue.toSignUpVC, sender: nil)
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        if self.email.text != "" && self.password.text != "" {
            self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
            self.login()
        } else {
            //every fielf is required
            messenger.show(massage: "All fields are required!", massageTitle: "Field Error", andAlertTitle: "Ok")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.emailTextView.backgroundColor = CustomColour.appThemeColour
        } else {
            self.passwordTextView.backgroundColor = CustomColour.appThemeColour
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.passwordTextView.backgroundColor = CustomColour.viewColour
        self.emailTextView.backgroundColor = CustomColour.viewColour
    }
    
}

extension SignInViewController {
    
    // for private function
    private func Setup() {
        self.email.delegate = self
        self.password.delegate = self
        
        self.signUpButton.layer.cornerRadius = 10
        self.signUpView.layer.cornerRadius = 10
        setUp().makeCardView(forView: self.signUpView, withShadowHight: 4, shadowWidth: 0, shadowOpacity: 0.3, shadowRadius: 15)
        
        self.animator = Animator(view: self.view)
        self.messenger = Message(superViewController: self)
    }
    
    //Networking
    private func login() {
        let param = ["email": self.email.text!, "pass": self.password.text!]
        
        Network().getResponse(from: url.signIn, having: param, method: .post) { (response) in
            self.animator.stopAnimation()
            if let response = response {
                switch response["status"] {
                case 200:
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self.dismiss(animated: true) {
                        self.delegate?.didDismiss(address: response["address"].string, email: self.email.text!)
                    }
                case 404:
                    self.messenger.show(massage: "User not found", massageTitle: "User Error", andAlertTitle: "Ok")
                case 401:
                    self.messenger.show(massage: "Password ented wrong", massageTitle: "User Error", andAlertTitle: "Ok")
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
