//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 04.07.2021.
//

import UIKit

class TabBarController: UITabBarController{
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    @IBOutlet weak var updateLocationButtons: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        UdacityClient.getStudentsLodcations() { success, error in
            if success {
                NotificationCenter.default.post(name: .didUpdateLocations, object: nil)
            } else {
                let alertVC = UIAlertController(title: "Failed to update locations", message: error ?? "", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)

            }
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        UdacityClient.deleteSession() { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addLocationButtonTapped(_ sender: Any) {
        let udacityUserID = Settings.udacityUserID
        
        
        
        if udacityUserID != nil {
            let messageString = "You have already posted a student location. Would you like to overwrite your current location?"
            let alertVC = UIAlertController(title: "", message: messageString, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Overvrite", style: .default) { action in
                self.performSegue(withIdentifier: "addLocation", sender: nil)
            })
            alertVC.addAction(UIAlertAction(title: "Cancell", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "addLocation", sender: nil)
        }
    }
}

extension Notification.Name {
    static let didUpdateLocations = Notification.Name("didUpdateLocations")
    static let didReceiveError = Notification.Name("didReceiveError")
}
