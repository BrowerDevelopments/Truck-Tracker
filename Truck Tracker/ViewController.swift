//
//  ViewController.swift
//  Truck Tracker
//
//  Created by Jacob Brower on 11/9/18.
//  Copyright © 2018 Dorm Creation. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        mapView.showsCompass = true
    }
    
    func focusMapOnUserLocation(){
        /* Zooms the map in around the location  */
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            //set up location manager
            setupLocationManager()
            checkLocationAuthorization() 
        } else {
            //show an alert
        }
    }
    
    func checkLocationAuthorization() {
        /* determines the location authorization settings of the user */
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            /* set up all the map stuff */
            mapView.showsUserLocation = true
            focusMapOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            /* user does not want their location to be known :(
             to fix they have to go through settings,
             set up alert to do that */
            break
        case .notDetermined:
            /* The user has not determined the location settings,
            so we ask them */
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            /* The user has something like child services on,
             show an alert to let them know */
            break
        case .authorizedAlways:
            /* The user has it set up so all apps can just work */
            break
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* If the code is uncommented then the app automatically refocuses on the  */
        
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
