//
//  MainViewController.swift
//  AidDrop
//
//  Created by John Corry on 12/13/17.
//  Copyright © 2017 John Corry. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITabBarController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dropController: DropController?
    var managedContext: NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managedContext = appDelegate.persistentContainer.viewContext
        self.dropController = DropController(context: managedContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

