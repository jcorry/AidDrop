//
//  KeyboardNotifications.swift
//  AidDrop
//
//  Created by John Corry on 1/6/18.
//  Copyright © 2018 John Corry. All rights reserved.
//

import Foundation

class KeyboardNotifications {
    
    fileprivate var _isEnabled: Bool
    fileprivate var notifications:  [KeyboardNotificationsType]
    fileprivate var delegate: KeyboardNotificationsDelegate
    
    init(notifications: [KeyboardNotificationsType], delegate: KeyboardNotificationsDelegate) {
        _isEnabled = false
        self.notifications = notifications
        self.delegate = delegate
    }
    
    deinit {
        if isEnabled {
            isEnabled = false
        }
    }
}

// MARK: - enums

extension KeyboardNotifications {
    
    enum KeyboardNotificationsType {
        case willShow, willHide, didShow, didHide
        
        var selector: Selector {
            switch self {
                
            case .willShow:
                return #selector(KeyboardNotifications.keyboardWillShow(notification:))
                
            case .willHide:
                return #selector(KeyboardNotifications.keyboardWillHide(notification:))
                
            case .didShow:
                return #selector(KeyboardNotifications.keyboardDidShow(notification:))
                
            case .didHide:
                return #selector(KeyboardNotifications.keyboardDidHide(notification:))
                
            }
        }
        
        var notificationName: NSNotification.Name {
            switch self {
                
            case .willShow:
                return .UIKeyboardWillShow
                
            case .willHide:
                return .UIKeyboardWillHide
                
            case .didShow:
                return .UIKeyboardDidShow
                
            case .didHide:
                return .UIKeyboardDidHide
            }
        }
    }
}

// MARK: - isEnabled

extension KeyboardNotifications {
    
    private func addObserver(type: KeyboardNotificationsType) {
        NotificationCenter.default.addObserver(self, selector: type.selector, name: type.notificationName, object: nil)
        print("\(type.notificationName.rawValue) inited")
    }
    
    var isEnabled: Bool {
        set {
            if newValue {
                
                for notificaton in notifications {
                    addObserver(type: notificaton)
                }
            } else {
                NotificationCenter.default.removeObserver(self)
                print("Keyboard notifications deinited")
            }
            _isEnabled = newValue
        }
        
        get {
            return _isEnabled
        }
    }
    
}

// MARK: - Notification functions

extension KeyboardNotifications {
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        delegate.keyboardWillShow?(notification: notification)
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        delegate.keyboardWillHide?(notification: notification)
    }
    
    @objc
    func keyboardDidShow(notification: NSNotification) {
        delegate.keyboardDidShow?(notification: notification)
    }
    
    @objc
    func keyboardDidHide(notification: NSNotification) {
        delegate.keyboardDidHide?(notification: notification)
    }
}
