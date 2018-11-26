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
            startTrackingUserLocation()
          
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
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longtitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longtitude)
    }
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    let locationManager = CLLocationManager()
    let defaultMeters = 10000.0
    @IBOutlet weak var addressLabel: UILabel!
    var previousLocation : CLLocation?
    
}



extension ViewController : CLLocationManagerDelegate {
    //when location changes
  
    
    //when permision authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension  ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        if let previosLocation = previousLocation {
        guard center.distance(from: previosLocation) > 50 else {return}
            previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) {  [weak self] (placemarks, error) in
            guard let self = self else {return}
            
            if let  _ = error {
                //TODO: Show alert info to the user
                return
            }
            guard let placemark = placemarks?.first else {
                //TODO: Show alert info to the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber)   \(streetName)"
            }
        }
        }
    }
    
    
}
