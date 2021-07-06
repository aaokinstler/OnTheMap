//
//  PostingMapViewController.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 04.07.2021.
//

import UIKit
import CoreLocation
import MapKit

class PostingMapViewController: UIViewController {
    var coordinates: CLLocationCoordinate2D!
    var mapString: String = "" 
    var mediaURL: String = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
        
        let regionRadius: CLLocationDistance = 4000
        let coordinateRegion = MKCoordinateRegion(center: coordinates,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    @IBAction func finishButtonTapped(_ sender: Any) {
        
        let udacityUserID = Settings.udacityUserID
        
        if udacityUserID == nil {
            UdacityClient.setUserLocation(mediaURL: mediaURL, mapString: mapString, location: coordinates, completion: handleRequest(success:error:))
        } else {
            UdacityClient.updateUserLocation(udacityUserId: udacityUserID!, mediaURL: mediaURL, mapString: mapString, location: coordinates, completion: handleRequest(success:error:))
        }
    }
    
    func handleRequest(success: Bool, error: String?) {
        
        if success {
            UdacityClient.getStudentsLodcations() { success, error in
                if success {
                    NotificationCenter.default.post(name: .didUpdateLocations, object: nil)
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            let alertVC = UIAlertController(title: "Failed to set location", message: error ?? "", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
}
