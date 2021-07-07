//
//  PostingViewController.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 04.07.2021.
//

import UIKit
import CoreLocation


class PostingViewController: UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var actiityIndicator: UIActivityIndicatorView!
    var coordinates: CLLocationCoordinate2D!
    

    
    @IBAction func findLocationButtonTapped(_ sender: Any) {
        let geocoder = CLGeocoder()
        actiityIndicator.startAnimating()
        geocoder.geocodeAddressString(locationTextField.text!) {placemarks, error in
            self.actiityIndicator.stopAnimating()
            guard let urlText = self.urlTextField.text else {
                self.showFailure(title: "Error", message: "Can't get URL information.")
                return
            }
            
            guard urlText != "" else {
                self.showFailure(title: "Link is empty!", message: "Please fill in the link field.")
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.showFailure(title: "Error", message: "Unable to define address.")
                return
            }
            
            self.coordinates = placemark.location!.coordinate
            self.performSegue(withIdentifier: "showOnTheMap", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PostingMapViewController
        controller.coordinates = self.coordinates
        controller.mapString = self.locationTextField.text!
        controller.mediaURL = self.urlTextField.text!
    }
    
    func showFailure(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    
}
