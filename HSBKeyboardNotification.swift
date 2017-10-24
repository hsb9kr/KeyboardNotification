//
//  HSBKeyboardFrame.swift
//  HSBKeyboardFrame
//
//  Created by hsb9kr on 2017. 10. 24..
//  Copyright © 2017년 hsb9kr. All rights reserved.
//

import UIKit

@objc protocol HSBKeyboardNotificationDelegate {
   func hsbKeyboardNotification(show keyboardSize: CGSize)
   func hsbKeyboardNotification(hide keyboardSize: CGSize)
   func hsbKeyboardNotification(change keyboardSize: CGSize)
}

class HSBKeyboardNotification: NSObject {
    static let shared = HSBKeyboardNotification()
    weak var delegate: HSBKeyboardNotificationDelegate?
    var isKeyboardHidden = true
    
    override init() {
        super.init()
        registKeyboardNotification()
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    //MARK: Private
    
    func registKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willChangeKeyboard), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func willShowKeyboard(notification: Notification) {
        guard isKeyboardHidden else {
            return
        }
        isKeyboardHidden = false
        keyboardSize(notification: notification, animations: { (keyboardSize) in
            self.delegate?.hsbKeyboardNotification(show: keyboardSize)
        })
    }
    
    @objc private func willHideKeyboard(notification: Notification) {
        guard !isKeyboardHidden else {
            return
        }
        isKeyboardHidden = true
        keyboardSize(notification: notification, animations: { (keyboardSize) in
            self.delegate?.hsbKeyboardNotification(hide: keyboardSize)
        })
    }
    
    @objc private func willChangeKeyboard(notification: Notification)  {
        guard !isKeyboardHidden, let (keyboardSize, _, _) = self.keyboardSize(notification: notification) else {
            return
        }
        self.delegate?.hsbKeyboardNotification(change: keyboardSize)
    }
    
    private func keyboardSize(notification: Notification) -> (CGSize, TimeInterval, UIViewAnimationOptions)? {
        guard let userInfo = notification.userInfo else {
            return nil
        }

        /*
         * Get Keyboard Size
         */
        let keyboardEndValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardEndValue.cgRectValue.size
        
        /*
         * Get Keyboard Animation Duration
         */
        let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationDuration: TimeInterval = durationValue.doubleValue

        /*
         * Get Keyboard Animation
         */
        let curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber
        let animationCurve: UIViewAnimationCurve = UIViewAnimationCurve(rawValue: curveValue.intValue<<16)!
        let options = UIViewAnimationOptions(rawValue: UIViewAnimationOptions.RawValue(animationCurve.rawValue))

        return (keyboardSize, animationDuration, options)
    }
    
    private func keyboardSize(notification: Notification, animations: @escaping (CGSize) -> ()) {
        guard let (keyboardSize, animationDuration, options) = self.keyboardSize(notification: notification) else {
            return
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: {
            animations(keyboardSize)
        })
    }
}
