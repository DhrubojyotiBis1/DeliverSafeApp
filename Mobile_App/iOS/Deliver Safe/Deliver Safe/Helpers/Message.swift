//
//  Message.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 21/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit

class Message {
    
    let titleColour = "titleTextColor"
    private var superViewController: UIViewController!
    
    init(superViewController: UIViewController) {
        self.superViewController = superViewController
    }
    
    func show(massage:String,massageTitle title:String,andAlertTitle alertTitle:String ){
        let alertController = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        let alert = UIAlertAction(title: alertTitle, style: .destructive) { (alertAction) in
        }
        alert.setValue(CustomColour.appThemeColour, forKey: self.titleColour)
        alertController.addAction(alert)
        self.superViewController.present(alertController, animated: true, completion: nil)
    }
}
