//
//  KeyboardHandler.swift
//  OnTheWay
//
//  Created by Vedran Novoselac on 05/03/2020.
//  Copyright © 2020 Vedran Novoselac. All rights reserved.
//

import Foundation
import UIKit


class KeyboardHandler {
    
    var view: UIView! = nil
    var textFields = [UITextField]()
    var shifted = false
    
    init(view v: UIView, textFields tfs: [UITextField]) {
        view = v
        textFields = tfs
    }
    
    func subscribe() {
        subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShow))
        subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillHide))
    }
    
    func unsubscribe() {
        unsubscribeFromNotification(UIResponder.keyboardWillShowNotification)
        unsubscribeFromNotification(UIResponder.keyboardWillHideNotification)
    }
    
    private func subscribeToNotification(_ notificationName: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
    
    private func unsubscribeFromNotification(_ notificationName: NSNotification.Name) {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
    private func editingTextField() -> UITextField? {
        for textField in textFields {
            if textField.isEditing {
                return textField
            }
        }
        
        return nil
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let textField = editingTextField() {
            let keyboardRect = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let textFieldRect = textField.superview!.convert(textField.frame, to: textField.window)

            let overlap = max(0, textFieldRect.origin.y + textFieldRect.height - keyboardRect.origin.y)
            view.frame.origin.y += -overlap - view.frame.origin.y
            shifted = overlap >= 0.0
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if shifted {
            view.frame.origin.y = 0.0
            shifted = false
        }
    }
}
