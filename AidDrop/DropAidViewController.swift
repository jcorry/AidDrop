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

class DropAidViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var locationManager:CLLocationManager!
    var dropController: DropController!
    var locationOverlay:MKCircle?
    var activeField: UITextView?
    private var keyboardNotifications: KeyboardNotifications!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aidTypeSelector: UISegmentedControl!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    
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
        // Set the notesField delegate
        notesField.delegate = self
        
        // Hide the keyboard after editing the quantity
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
        
        // Add a border to the notes field
        notesField.layer.cornerRadius = 5
        notesField.layer.borderColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.00).cgColor
        notesField.layer.borderWidth = 0.7
        
        // Set the scroll view's content size to the view content size
        self.scrollView.contentSize = self.view.frame.size
        
        // KeyboardNotifications
        keyboardNotifications = KeyboardNotifications(notifications: [.willShow, .willHide, .didShow, .didHide], delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardNotifications.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardNotifications.isEnabled = false
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
            drop.notes = notesField.text
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
        if self.locationOverlay != nil {
            self.mapView.remove(self.locationOverlay!)
        }
        guard self.mapView.overlays.count == 0 else { return }
        self.locationOverlay = MKCircle(center: center, radius: radius)
        print("Adding circle overlay at \(center.latitude), \(center.longitude)")
        self.mapView.add(self.locationOverlay!)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating location...")
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
        
        print("Lat: \(userLocation.coordinate.latitude), Lng: \(userLocation.coordinate.longitude)");
        manager.stopUpdatingLocation()
        
        self.mapView.setRegion(region, animated: true)
        self.dropAreaOverlay(center: center, radius: 30.0)
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor(red:0.18, green:0.49, blue:0.85, alpha:0.25)
        circleRenderer.strokeColor = UIColor(red:0.24, green:0.25, blue:0.25, alpha:1.0)
        circleRenderer.lineWidth = 0.7
        return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        self.dropAreaOverlay(center: center, radius: 30)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        quantityField.text = ""
        self.activeField = nil
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Setting activeField")
        self.activeField = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("Nulling activeField")
        self.activeField = nil
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

extension DropAidViewController: KeyboardNotificationsDelegate {
    func keyboardDidShow(notification: NSNotification) {
        print("Keyboard did show")
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if (self.activeField != nil) {
            print("Trying to scroll view...")
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
            self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        print("Keyboard will hide")
    }
}


