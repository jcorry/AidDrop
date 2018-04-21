//
//  ViewDropsViewController.swift
//  AidDrop
//
//  Created by John Corry on 12/13/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import UIKit
import CoreLocation
import NotificationCenter
import CoreData

class ViewDropsViewController: UIViewController, CLLocationManagerDelegate {
    
    var dropController: DropController!
    var currentLocation: CLLocation!
    var locationManager: CLLocationManager!
    var context: NSManagedObjectContext?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate?
        self.context = appDelegate?.persistentContainer.viewContext
        
        // Do any additional setup after loading the view.
        let tbvc = self.tabBarController as! MainViewController
        dropController = tbvc.dropController
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDropsViewController didLoad")
        
        // Setup the locationManager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        checkLocationAuthorizationStatus()
        updateUserLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func navigationSegmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            print("Loading map view")
            remove(asChildViewController: listViewController)
            add(asChildViewController: mapViewController)
            break
        default:
            print("Loading list view")
            remove(asChildViewController: mapViewController)
            add(asChildViewController: listViewController)
            break
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParentViewController()
    }
    
    private lazy var listViewController: UITableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "listViewController") as! ViewDropsTableViewController
        
        viewController.dropController = self.dropController
        viewController.currentLocation = self.currentLocation
        
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var mapViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        var viewController = storyboard.instantiateViewController(withIdentifier: "mapViewController") as! ViewDropsMapViewController
        
        viewController.dropController = self.dropController
        
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func updateUserLocation() {
        self.checkLocationAuthorizationStatus()
        
        if CLLocationManager.locationServicesEnabled() {
            print("Trying to update location...")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not available...")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocation = locations[0] as CLLocation
        print("Updated current location")
        print("Location: \(locValue.coordinate.latitude) \(locValue.coordinate.longitude)")
        
        self.currentLocation = locValue
        manager.stopUpdatingLocation()
        
        let delta = 0.01
        dropController.getCases(
            maxLatitude: locValue.coordinate.latitude + delta,
            maxLongitude: locValue.coordinate.longitude + delta,
            minLatitude: locValue.coordinate.latitude - delta,
            minLongitude: locValue.coordinate.longitude - delta,
            completion: { result in
                switch result {
                case .success(let cases):
                    print("success")
                    self.dropController.collection = cases
                    self.add(asChildViewController: self.listViewController)
                case .empty():
                    print("No results from API request")
                case .failure(let error):
                    fatalError("\(error)")
                }
            }
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.desiredAccuracy = kCLLocationAccuracyBest
            self.updateUserLocation()
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
