//
//  Student.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/13/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    let uniqueKey: String
    let firstName: String
    let lastName: String
    var mediaURL: String?
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(uniqueKey: String, firstName: String, lastName: String) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        
    }
    
}