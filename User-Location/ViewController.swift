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
        goButton.layer.cornerRadius = 5
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
    
    func getDirections(){
        guard let location = locationManager.location?.coordinate  else {
            return
        }
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        
        directions.calculate {  [unowned self] (response, error) in
            
            if let error = error {
                print("\(error) refer to error handler in gerDirections function")
            }
            guard let response = response else {return}
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate  = getCenterLocation(for: mapView).coordinate
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    @IBAction func goButtonTapped(_ sender : UIButton){
        getDirections()
    }
    
    @IBOutlet weak var goButton: UIButton!
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3.0
        
        return renderer
    }
}
