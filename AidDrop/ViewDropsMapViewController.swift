//
//  ViewDropsMapViewController.swift
//  AidDrop
//
//  Created by John Corry on 12/13/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewDropsMapViewController: UIViewController, CLLocationManagerDelegate {
    var dropController: DropController!
    var locationManager:CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        centerMapOnUserLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("Items in dropController: \(self.dropController.collection.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnUserLocation() {
        self.checkLocationAuthorizationStatus()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services unavailable")
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        self.mapView.setRegion(region, animated: true)
        self.plotDropsOnMap()
        manager.stopUpdatingLocation()
    }
    
    func plotDropsOnMap() {
        var annotations:[MKAnnotation] // Because even though Drop inherits from MKAnnotation, a collection of them isn't a [MKAnnotation]
        annotations = self.dropController.collection
        
        self.mapView.removeAnnotations(annotations)
        self.mapView.addAnnotations(annotations)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ViewDropsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Drop else { return nil }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let boundingBox = mapView.visibleMapRect.getBoundingBox()
        
        self.dropController.getCases(
            maxLatitude: boundingBox[2],
            maxLongitude: boundingBox[3],
            minLatitude: boundingBox[0],
            minLongitude: boundingBox[1]) { result in
                switch result {
                case .success(let cases):
                    print("\(cases)")
                    self.dropController.collection = cases
                    self.plotDropsOnMap()
                case .failure(let error):
                    print("\(error)")
                case .empty():
                    print("No results")
                }
        }
    }
}
