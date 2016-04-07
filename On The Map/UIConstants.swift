//
//  UIConstants.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/6/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

// MARK: UIConstants

struct UIConstants {
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.97, green: 0.39, blue: 0.0, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red:1.00, green:0.56, blue:0.27, alpha:1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red:1.00, green:0.74, blue:0.57, alpha:1.0)
    }
    
    // MARK: Selectors
    struct Selectors {
        static let KeyboardWillShow: Selector = "keyboardWillShow:"
        static let KeyboardWillHide: Selector = "keyboardWillHide:"
        static let KeyboardDidShow: Selector = "keyboardDidShow:"
        static let KeyboardDidHide: Selector = "keyboardDidHide:"
    }
}