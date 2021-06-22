//
//  MainViewController.swift
//  cellcomTest
//
//  Created by Alex Vaiman on 21/06/2021.
//

import UIKit
import Foundation
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate, MainAPIResponseDelegate {
    
    
    @IBOutlet weak var settingsButton: UIButton!
    
    let locationManager = CLLocationManager()
    let mainAPI = MainAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsButton.isHidden = true
        locationManager.delegate = self
        mainAPI.mainAPIResponseDelegate = self
    }
    
    func onBranchesResponse(data: Dictionary<String, AnyObject>?, error: Error?) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if #available(iOS 14.0, *) {
            updateAuthorization(status: status, accuracyAuthorization: manager.accuracyAuthorization)
        } else {
            // Fallback on earlier versions
            updateAuthorization(status: status, accuracyAuthorization: .fullAccuracy)
        }
    }
    
    private func updateAuthorization(status: CLAuthorizationStatus, accuracyAuthorization: CLAccuracyAuthorization) {
        if status == .authorizedAlways && accuracyAuthorization == .fullAccuracy {
            locationPermissionReady()
            return
        }
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        self.settingsButton.isHidden = false
        //else somthing missing
    }
    
    private func locationPermissionReady() {
        self.settingsButton.isHidden = true
        self.mainAPI.getBranches(location: locationManager.location ?? CLLocation.init())
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
