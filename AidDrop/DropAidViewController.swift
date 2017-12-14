//
//  DropAidViewController.swift
//  AidDrop
//
//  Created by John Corry on 12/13/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

class DropAidViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    var locationManager:CLLocationManager!
    var dropController: DropController!
    var locationOverlay:MKCircle!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aidTypeSelector: UISegmentedControl!
    @IBOutlet weak var quantityField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tbvc = self.tabBarController as! MainViewController
        dropController = tbvc.dropController
        
        // Get location service authorization
        checkLocationAuthorizationStatus()
        
        self.mapView.delegate = self
        
        // Configure mapView
        centerMapOnUserLocation()
        
        // Set the quantityView delegate
        quantityField.delegate = self
        // Hide the keyboard after editing the quantity
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dropAidButtonTapped(_ sender: UIButton) {
        // Create a new Drop
        var drop: Drop!
        if let aidTypeValue = self.aidTypeSelector.titleForSegment(at: aidTypeSelector.selectedSegmentIndex) {
            drop = Drop(
                location: CLLocation(
                    latitude: self.mapView.centerCoordinate.latitude,
                    longitude: self.mapView.centerCoordinate.longitude
                ),
                aidType: AidType(rawValue: aidTypeValue)!,
                quantity: Int(quantityField.text!)
            )
        }
        
        // Add the Drop to the collection
        dropController.collection.append(drop)
        
        // Update the tab bar badge
        updateViewDropsTabBarBadge()
    }
    
    /**
    * Centers the map on the location
    */
    func centerMapOnUserLocation() {
        // guard self.mapView.showsUserLocation else { return }
        // Can I get the user's location?
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not available...")
        }
    }

    func dropAreaOverlay(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        guard self.mapView.overlays.count == 0 else { return }
        
        self.locationOverlay = MKCircle(center: center, radius: radius)
        print("Adding circle overlay at \(center.latitude), \(center.longitude)")
        self.mapView.add(self.locationOverlay)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating location...")
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        print("Lat: \(userLocation.coordinate.latitude), Lng: \(userLocation.coordinate.longitude)");
        manager.stopUpdatingLocation()
        
        self.mapView.setRegion(region, animated: true)
        self.dropAreaOverlay(center: center, radius: 50.0)
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor(red:0.18, green:0.49, blue:0.85, alpha:0.4)
        circleRenderer.strokeColor = UIColor(red:0.24, green:0.25, blue:0.25, alpha:0.6)
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        quantityField.text = ""
    }
    
    func updateViewDropsTabBarBadge() {
        if let tabItems = self.tabBarController?.tabBar.items as Array! {
            let viewDropsTabBarItem = tabItems[1] as UITabBarItem
            viewDropsTabBarItem.badgeValue = String(self.dropController.collection.count)
        }
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
