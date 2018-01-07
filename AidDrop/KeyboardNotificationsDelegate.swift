//
//  KeyboardNotificationsDelegate.swift
//  AidDrop
//
//  Created by John Corry on 1/6/18.
//  Copyright © 2018 John Corry. All rights reserved.
//

import Foundation

@objc
protocol KeyboardNotificationsDelegate {
    
    @objc optional func keyboardWillShow(notification: NSNotification)
    @objc optional func keyboardWillHide(notification: NSNotification)
    @objc optional func keyboardDidShow(notification: NSNotification)
    @objc optional func keyboardDidHide(notification: NSNotification)
}
