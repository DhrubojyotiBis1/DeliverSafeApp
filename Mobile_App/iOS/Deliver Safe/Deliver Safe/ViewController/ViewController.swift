//
//  ViewController.swift
//  Deliver Safe
//
//  Created by Dhrubojyoti on 20/06/20.
//  Copyright © 2020 Dhrubojyoti. All rights reserved.
//

import UIKit
import LocationPicker
import CoreLocation
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var navigationView:UIView!
    @IBOutlet weak var requestTableView:UITableView!
    
    var isLogedIn = false
    let locationPicker = LocationPickerViewController()
    var emai: String?
    var address: String?
    var refresher: UIRefreshControl!
    var locationManager: CLLocationManager!
    var requests: [Request]!
    
    var messenger: Message!
    var animator: Animator!
    
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isLogedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if !isLogedIn {
            performSegue(withIdentifier: Segue.toSignInVC, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.toSignInVC {
            let destination = segue.destination as! SignInViewController
            destination.delegate = self
        }
    }
    
    @IBAction func addRequest(_ sender: UIButton) {
        if let _ = self.address {
            let alertController = UIAlertController(title: "Create new request", message: "", preferredStyle: .alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter request title"
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter request details"
            }
            
            let requestAction = UIAlertAction(title: "Request", style: .default, handler: { alert -> Void in
                let requestTitleTextFlied = alertController.textFields![0] as UITextField
                let requestDescriptionTextField = alertController.textFields![1] as UITextField
                
                let requestTitle = requestTitleTextFlied.text!
                let requestDescription = requestDescriptionTextField.text!
                
                if requestTitle != "" && requestDescription != "" {
                    self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .playOnce)
                    self.createRequest(title: requestTitle, desctiption: requestDescription)
                } else {
                   self.messenger.show(massage: "All fileds are required", massageTitle: "Wront Input", andAlertTitle: "Ok")
                }
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
            

            alertController.addAction(cancelAction)
            alertController.addAction(requestAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.showMap()
        }
    }
}

extension ViewController {
    //For private function
    
    private func setup() {
        //non UI stuff
        self.address = UserDefaults.standard.string(forKey: "address")
        self.emai = UserDefaults.standard.string(forKey: "email")
        self.messenger = Message(superViewController: self)
        self.animator = Animator(view: self.view)
        
        //UI stuff
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        self.requestTableView.delegate = self
        self.requestTableView.dataSource = self
        
        self.requests = [Request]()
        self.refresher = UIRefreshControl()
        self.refresher.tintColor = CustomColour.appThemeColour
        self.refresher.addTarget(self, action: #selector(self.getRequests), for: .allEvents)
        self.requestTableView.addSubview(refresher)
        
        setUp().makeCardView(forView: self.navigationView, withShadowHight: 3, shadowWidth: 0, shadowOpacity: 0.35, shadowRadius: 8)
    }
    
    private func showMap() {
        let navigationController = UINavigationController()
    
        locationPicker.showCurrentLocationInitially = true
        locationPicker.mapType = .standard
        locationPicker.searchBarPlaceholder = ""
        locationPicker.searchHistoryLabel = "Previously searched"
        locationPicker.completion = { location in
            // do some awesome stuff with location
            if let location = location {
                self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                let address = location.address.replacingOccurrences(of: " ", with: "%20")
                self.setAddress(latitude: "\(latitude)", longititude: "\(longitude)", address: address)
            }
            
        }
        navigationController.viewControllers = [locationPicker]
        self.present(navigationController, animated: true, completion: nil)
    }
    
    //Networking
    private func setAddress(latitude: String, longititude: String, address: String) {
        if let email = self.emai {
            let param = ["email": email, "address": address, "lat": latitude, "long": longititude]
            Network().getResponse(from: url.address, having: param, method: .post) { (response) in
                if let response = response {
                    switch response["status"] {
                    case 200:
                        self.address = address
                        UserDefaults.standard.set(address, forKey: "address")
                        self.getRequests()
                    case 404:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "User not found !", massageTitle: "User Error", andAlertTitle: "Ok")
                    case 400:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Something went wrong!", massageTitle: "App Error", andAlertTitle: "Ok")
                    case 503:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Something went wrong!", massageTitle: "Server Error", andAlertTitle: "Ok")
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
    
    @objc
    private func getRequests() {
        guard let email = self.emai, let latitude = self.currentLocation?.coordinate.latitude, let longitude = self.currentLocation?.coordinate.longitude else { return }
        let param = ["email": email, "lat": "\(latitude)", "long": "\(longitude)"]
        Network().getResponse(from: url.request, having: param, method: .get) { (response) in
            self.animator.stopAnimation()
            if let response = response {
                switch response["status"] {
                case 200:
                    //got response
                    let requests = response["requests"]
                    self.parseRequest(requests: requests)
                case 404:
                    self.parseRequest(requests: nil)
                case 401:
                    self.messenger.show(massage: "User not found!", massageTitle: "User Error", andAlertTitle: "Ok")
                    self.refresher.endRefreshing()
                case 402:
                    self.messenger.show(massage: "Unable to acess location", massageTitle: "App Error", andAlertTitle: "Ok")
                    self.refresher.endRefreshing()
                case 400:
                    self.messenger.show(massage: "Something went wrong!", massageTitle: "App Error", andAlertTitle: "Ok")
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
    
    private func parseRequest(requests: JSON?) {
        self.requests.removeAll()
        if let requests = requests {
            for index in 0..<requests.count {
                let assinUserId = requests[index]["assinname"].string
                if  assinUserId == nil {
                    let title = requests[index]["title"].string!
                    let description = requests[index]["descrip"].string!
                    let authorName = requests[index]["author"].string!
                    let numberOfCoins = requests[index]["coinnum"].int!
                    let isMyRequest = requests[index]["myreq"].bool!
                    let createdDate = requests[index]["credate"].string!
                    let id = requests[index]["id"].int!
                    
                    let request = Request(titel: title, description: description, author: authorName, numberOfCoins: numberOfCoins, assinUserName: nil, myRequest: isMyRequest, createdDate: createdDate, id: id)
                    self.requests.append(request)
                }
            }
        }
        self.requestTableView.reloadData()
        if self.requests.isEmpty {
            self.messenger.show(massage: "No request found!", massageTitle: "Request Error", andAlertTitle: "Ok")
        }
        self.refresher.endRefreshing()
    }
    
    private func createRequest(title: String, desctiption: String) {
        if let email = self.emai {
            let properperTitle = title.replacingOccurrences(of: " ", with: "%20")
            let properDescription = desctiption.replacingOccurrences(of: " ", with: "%20")
            let param = ["email": email, "rtitle": properperTitle, "rdiscription": properDescription]
            Network().getResponse(from: url.createRequest, having: param, method: .post) { (response) in
                self.animator.stopAnimation()
                if let response = response {
                    switch response["status"] {
                    case 200:
                        //got response
                        let animator = Animator(view: self.view)
                        animator.playAnimationWith(name: lottie.doneAnimation, mode: .playOnce)
                    case 507:
                        self.messenger.show(massage: "There are not enough coins in you accoint to make this request. Please add some coins to make the request.", massageTitle: "Insifficient coin", andAlertTitle: "Ok")
                    case 401:
                        self.messenger.show(massage: "User not found!", massageTitle: "User Error", andAlertTitle: "Ok")
                    case 400:
                        self.messenger.show(massage: "Something went wrong!", massageTitle: "App Error", andAlertTitle: "Ok")
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
    
    private func assinTheRequest(id: Int) {
        //assin the request to current user
        if let email = self.emai {
            let param = ["email": email, "rid": "\(id)"]
            Network().getResponse(from: url.assinRequest, having: param, method: .post) { (response) in
                if let response = response {
                    switch response["status"] {
                    case 200:
                        //got response
                        self.getRequests()
                    case 401:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "User not found!", massageTitle: "User Error", andAlertTitle: "Ok")
                    case 422:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Incorrect request Id", massageTitle: "App Error", andAlertTitle: "Ok")
                    case 409:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Already assigned to another user", massageTitle: "Request Error", andAlertTitle: "Ok")
                    case 400:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "Something went wrong!", massageTitle: "App Error", andAlertTitle: "Ok")
                    case 204:
                        self.animator.stopAnimation()
                        self.messenger.show(massage: "No such request found!", massageTitle: "App Error", andAlertTitle: "Ok")
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

extension ViewController: SignInProtocol, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.requestTableView.dequeueReusableCell(withIdentifier: cellIdentifire.requestTableView) as! RequestTableViewCell
        cell.selectionStyle = .none
        let row = self.requests.count - indexPath.row - 1
        var counter = 0
        var requiredDate = ""
        for char in requests[row].createdDate {
            if char == " "{
                counter += 1
            }
            if counter == 4 {
                break
            }
            requiredDate+=String(char)
        }
        cell.creaetedDate.text = requiredDate
        cell.requestTitle.text = requests[row].titel
        cell.requestDescription.text = requests[row].description
        cell.requestAuthor.text = requests[row].author
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.currentLocation == nil {
            self.currentLocation = locations[0]
            self.isLogedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            if isLogedIn {
                self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
                self.getRequests()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.requests.count - indexPath.row - 1
        if row >= 0 && !self.requests[row].myRequest {
            let alertController = UIAlertController(title: "Accept Request", message: "Do you want to accept the request?", preferredStyle: .alert)
            
            
            let requestAction = UIAlertAction(title: "Sure", style: .default, handler: { alert -> Void in
                //accepeted request
                self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
                self.assinTheRequest(id: self.requests[row].id)
            })
            
            let cancelAction = UIAlertAction(title: "Not now", style: .default, handler: { (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(cancelAction)
            alertController.addAction(requestAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let message = "This request is made by you. But unforfunatelly no one has accepeted the request!"
            messenger.show(massage: message, massageTitle: "Your Request", andAlertTitle: "OK")
        }
    }
    
    func didDismiss(address: String?, email: String?) {
        // Save Email
        if let email = email {
            UserDefaults.standard.set(email, forKey: "email")
            self.emai = email
        } else if email == nil {
            self.emai = UserDefaults.standard.string(forKey: "email")
        }
        if let address = address {
            // save address
            self.animator.playAnimationWith(name: lottie.loadindAnimation, mode: .loop)
            self.address = address
            UserDefaults.standard.set(address, forKey: "address")
            self.getRequests()
        } else {
            self.showMap()
        }
    }
}

