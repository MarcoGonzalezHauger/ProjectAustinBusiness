//
//  NewObjectClass.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 31/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
class CityObject: NSObject {
    var city: String
    var zipcodes: [String]
    
    init(dictionary: [String: AnyObject]) {
        self.city = dictionary["city"] as? String ?? ""
        self.zipcodes = dictionary["zipcodes"] as? [String] ?? []
    }
    
}
