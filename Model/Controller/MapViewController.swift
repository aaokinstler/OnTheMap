//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 29.06.2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LocationModel.locationsDownloaded {
            UdacityClient.getStudentsLodcations(completion: handleLocationsDownload(downloaded:errorString:))
        } else {
            setAnnotations()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didUpdateLocations, object: nil)
    }
    
    func handleLocationsDownload(downloaded: Bool, errorString: String?) {
        if downloaded {
            setAnnotations()
        } else {
            showFailure(message: errorString ?? "")
        }
    }
    
    func setAnnotations() {
        var annotations = [MKPointAnnotation]()
        
        for location in LocationModel.locations {
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(location.firstName) \(location.lastName)"
            annotation.subtitle = location.mediaURL
            annotations.append(annotation)
        }

        self.mapView.addAnnotations(annotations)
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Failed to update data", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!)
            }
        }
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        setAnnotations()
    }
}
