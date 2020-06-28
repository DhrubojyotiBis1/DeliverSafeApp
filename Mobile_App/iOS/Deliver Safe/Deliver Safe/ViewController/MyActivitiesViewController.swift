//
//  MyActivitiesViewController.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 22/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyActivitiesViewController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var activityTableView: UITableView!
    var refresher: UIRefreshControl!
    
    var activities: [Request]!
    var email: String?
    
    var messenger: Message!
    var animator: Animator!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
}

extension MyActivitiesViewController {
     //For private function
    
    private func setup() {
        self.messenger = Message(superViewController: self)
        self.animator = Animator(view: self.view)
        self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
        setUp().makeCardView(forView: self.navigationView, withShadowHight: 3, shadowWidth: 0, shadowOpacity: 0.35, shadowRadius: 8)
        
        self.activityTableView.dataSource = self
        self.activityTableView.delegate = self
        self.email = UserDefaults.standard.string(forKey: "email")
        
        self.activities = [Request]()
        self.refresher = UIRefreshControl()
        self.refresher.tintColor = CustomColour.appThemeColour
        self.refresher.addTarget(self, action: #selector(self.getActivities), for: .allEvents)
        self.activityTableView.addSubview(refresher)
        
        if email != nil {
            self.getActivities()
        }
    }
    
    //Networking
    @objc
    private func getActivities() {
        if let email = self.email {
            let param = ["email": email]
            Network().getResponse(from: url.request, having: param, method: .get) { (response) in
                self.animator.stopAnimation()
                if let response = response {
                    switch response["status"] {
                    case 200:
                        //got response
                        let requests = response["requests"]
                        self.parseRequest(activities: requests)
                    case 404:
                        self.parseRequest(activities: nil)
                    case 401:
                        self.messenger.show(massage: "User not found!", massageTitle: "User Error", andAlertTitle: "Ok")
                        self.refresher.endRefreshing()
                    case 400:
                        self.messenger.show(massage: "Bad request made!", massageTitle: "App Error", andAlertTitle: "Ok")
                        self.refresher.endRefreshing()
                    default:
                        //something wint wrong
                        self.messenger.show(massage: "Something went wrong!", massageTitle: "Server Error", andAlertTitle: "Ok")
                        self.refresher.endRefreshing()
                        break
                    }
                } else {
                    //login failed due to network issue
                    self.messenger.show(massage: "Please check your netwrk connection!", massageTitle: "Network Eroor", andAlertTitle: "Ok")
                    self.refresher.endRefreshing()
                }
            }
        }
    }
    
    private func parseRequest(activities: JSON?) {
        self.activities.removeAll()
        if let activities = activities {
            for index in 0..<activities.count {
                let assinUserId = activities[index]["assinname"].string
                let title = activities[index]["title"].string!
                let description = activities[index]["descrip"].string!
                let authorName = activities[index]["author"].string!
                let numberOfCoins = activities[index]["coinnum"].int!
                let isMyRequest = activities[index]["myreq"].bool!
                let createdDate = activities[index]["credate"].string!
                let id = activities[index]["id"].int!
                
                let request = Request(titel: title, description: description, author: authorName, numberOfCoins: numberOfCoins, assinUserName: assinUserId, myRequest: isMyRequest, createdDate: createdDate, id: id)
                self.activities.append(request)
            }
        }
        print("activities", activities)
        
        self.activityTableView.reloadData()
        if self.activities.isEmpty {
            self.messenger.show(massage: "No request found!", massageTitle: "Request Error", andAlertTitle: "Ok")
        }
        self.refresher.endRefreshing()
    }
    
    private func completedRequest(id: Int) {
        if let email = self.email {
            let param = ["email": email, "rid": "\(id)"]
            Network().getResponse(from: url.requestCompleted, having: param, method: .post) { (response) in
                if let response = response {
                    switch response["status"] {
                    case 200:
                        //got response
                        self.getActivities()
                    case 404:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "No request found!", massageTitle: "Request Error", andAlertTitle: "Ok")
                    case 401:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "User not found!", massageTitle: "User Error", andAlertTitle: "Ok")
                    case 422:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Unprocessable request Id used!", massageTitle: "App Error", andAlertTitle: "Ok")
                    case 400:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Bad request made!", massageTitle: "App Error", andAlertTitle: "Ok")
                    default:
                        //something wint wrong
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Something went wrong!", massageTitle: "Server Error", andAlertTitle: "Ok")
                        break
                    }
                } else {
                    //login failed due to network issue
                    self.animator.stopAnimation()
                    self.messenger.show(massage: "Please check your netwrk connection!", massageTitle: "Network Eroor", andAlertTitle: "Ok")
                }
            }
        }
    }
}

extension MyActivitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = activityTableView.dequeueReusableCell(withIdentifier: cellIdentifire.activityTableView) as! ActivityTableViewCell
        cell.selectionStyle = .none
        let row = self.activities.count - indexPath.row - 1
        cell.activityAssinTo.text = activities[row].assinUserName
        cell.isAssignView.backgroundColor = activities[row].assinUserName != nil ? CustomColour.assined : CustomColour.appThemeColour
        cell.activityCreatedDate.text = activities[row].createdDate
        
        var counter = 0
        var requiredDate = ""
        for char in activities[row].createdDate {
            if char == " "{
                counter += 1
            }
            if counter == 4 {
                break
            }
            requiredDate+=String(char)
        }
        cell.activityCreatedDate.text = requiredDate
        cell.activityDescription.text = activities[row].description
        cell.activityAuthor.text = activities[row].author
        cell.activityTitle.text = activities[row].titel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.activities.count - indexPath.row - 1
        if activities[row].myRequest {
            let alertController = UIAlertController(title: "Request Completed", message: "Is this request sucessfully completed?", preferredStyle: .alert)
            
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { alert -> Void in
                //request completed
                self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
                self.completedRequest(id: self.activities[row].id)
            })
            
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let message = "You haved completed the request yet or \(activities[row].author) haved updated the request. Please ask \(activities[row].author) to update the request to get the coins!"
            messenger.show(massage: message, massageTitle: "Update Error", andAlertTitle: "Ok")
        }
    }
}
