//
//  MyProfileViewController.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 23/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var profileBackgroundView: UIView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var numberOfCoins: UILabel!
    var userEmail: String?
    
    var messenger: Message!
    var animator: Animator!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.toInitialVC {
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "address")
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        }
    }
    
    @IBAction func logout(_ sender: UIButton) {
        performSegue(withIdentifier: Segue.toInitialVC, sender: nil)
    }

}

extension MyProfileViewController {
    private func setup() {
        self.userEmail = UserDefaults.standard.string(forKey: "email")
        self.messenger = Message(superViewController: self)
        self.animator = Animator(view: self.view)
        self.profileBackgroundView.layer.cornerRadius = 10
        self.navigationView.layer.cornerRadius = 20
        setUp().makeCardView(forView: self.navigationView, withShadowHight: 3, shadowWidth: 0, shadowOpacity: 0.35, shadowRadius: 8)
        setUp().makeCardView(forView: self.profileBackgroundView, withShadowHight: 4, shadowWidth: 0, shadowOpacity: 0.3, shadowRadius: 15)
        self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
        self.network()
    }
    
    private func network() {
        if let email = self.userEmail {
            let param = ["email": email]
            Network().getResponse(from: url.userDetails, having: param, method: .get) { (details) in
                if let details = details {
                    self.animator.stopAnimation()
                    switch details["status"] {
                    case 200:
                        //got response
                        self.parseRequest(details: details)
                    case 404:
                        self.parseRequest(details: nil)
                    case 400:
                        self.messenger.show(massage: "Bad request made!", massageTitle: "App Error", andAlertTitle: "Ok")
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
    
    private func parseRequest(details: JSON?){
        if let details = details {
            self.email.text = "Email: " + self.userEmail!
            self.name.text = "Name: " + details["name"].string!
            if let address = details["address"].string {
             self.address.text = "Address: " + address
            }
            self.numberOfCoins.text = "Balance: " + "\(details["coinnum"].int!)"
        } else if details == nil {
            self.messenger.show(massage: "No User found!", massageTitle: "User Error", andAlertTitle: "Ok")
        }
    }
}
