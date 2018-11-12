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

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(titlePin: String, subtitlePin: String, coordinatePin: CLLocationCoordinate2D){
        self.title = titlePin
        self.subtitle = subtitlePin
        self.coordinate = coordinatePin
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        mapView.showsCompass = true
        
        let foodTruckLocation = CLLocationCoordinate2D(latitude: 37.806433301430566, longitude: -122.43752356890508)
        let foodTruckPin = customPin(titlePin: "In Queso Emergency", subtitlePin: "A cheesy delight.", coordinatePin: foodTruckLocation)
        self.mapView.addAnnotation(foodTruckPin)
        self.mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotation")
        annotationView.image = UIImage(named: "Pin -cheap")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pinLocation = view.annotation?.coordinate {
            focusMapOnPin(coord: pinLocation)
        }
    }
    
    func focusMapOnPin( coord: CLLocationCoordinate2D ) {
        /* When the user touches a pin the map focuses on their location
         latitude: latidue of the pin
         longitude: longitude of the pin */
        let region = MKCoordinateRegion.init(center: coord, latitudinalMeters: regionInMeters / 2, longitudinalMeters: regionInMeters / 2)
        mapView.setRegion(region, animated: true)
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
    
    @IBAction func showLocationAlert() {
        let alertController = UIAlertController(title: "Enable Location Services",
                                      message: "To enable location service go to Settings > Privacy > Location Services",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled(){
            //set up location manager
            setupLocationManager()
            checkLocationAuthorization() 
        } else {
            //show an alert
            showLocationAlert()
        }
    }
    
    func checkLocationAuthorization() {
        /* determines the location authorization settings of the user */
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            /* set up all the map stuff */
            mapView.showsUserLocation = true
            focusMapOnUserLocation()
//            locationManager.startUpdatingLocation()
            break
        case .denied:
            /* user does not want their location to be known :(
             to fix they have to go through settings,
             set up alert to do that */
            showLocationAlert()
            break
        case .notDetermined:
            /* The user has not determined the location settings,
            so we ask them */
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            /* The user has something like child services on,
             show an alert to let them know */
            showLocationAlert()
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
