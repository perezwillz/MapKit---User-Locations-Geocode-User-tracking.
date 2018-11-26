//
//  ViewController.swift
//  User-Location
//
//  Created by Perez Willie Nwobu on 11/25/18.
//  Copyright © 2018 Perez Willie Nwobu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //settingUpCustomLocationManager
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    @IBOutlet weak var mapView: MKMapView!
    
    func checkLocationServices(){
        if  CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting user know that he has to turn on location manager
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse :
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            print("Showing user location")
            break
        case .denied :
            //tell them what to do if they wanna come back and say yes
            break
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedAlways:
            break
            
        case .restricted :
            //maybe the got parental control or whatever
            break
        }
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: defaultMeters, longitudinalMeters: defaultMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    let locationManager = CLLocationManager()
    let defaultMeters = 10000.0
    @IBOutlet weak var addressLabel: UILabel!
    
}



extension ViewController : CLLocationManagerDelegate {
    //when location changes
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: defaultMeters, longitudinalMeters: defaultMeters)
//        mapView.setRegion(region, animated: true)
//    }
    
    //when permision authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
