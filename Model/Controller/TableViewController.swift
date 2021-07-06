//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Anton Kinstler on 30.06.2021.
//

import UIKit


class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !LocationModel.locationsDownloaded {
            UdacityClient.getStudentsLodcations(completion: handleLocationsDownload(downloaded:errorString:))
        } else {
            tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didUpdateLocations, object: nil)
    }
    
    func handleLocationsDownload(downloaded: Bool, errorString: String?) {
        if downloaded {
            tableView.reloadData()
        } else {
            showFailure(message: errorString ?? "")
        }
    }
    
    func showFailure(message: String) {
        let alertVC = UIAlertController(title: "Failed to update data", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationModel.locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! LocationTableViewCell
        let location = LocationModel.locations[indexPath.row]
        
        cell.nameLabel.text = "\(location.firstName) \(location.lastName)"
        cell.urlLabel.text = location.mediaURL
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = LocationModel.locations[indexPath.row].mediaURL
        let app = UIApplication.shared
        app.open(URL(string: urlString)!)
    }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        tableView.reloadData()
    }
}

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    
}
