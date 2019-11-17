//
//  LocationPicker.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 11/9/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class LocationPicker: StandardNC, LocationFilterDelegate {
	
	func LocationFilterChosen(filter: String) {
		locationDelegate?.LocationFilterChosen(filter: filter)
	}
	
	var locationDelegate: LocationFilterDelegate?
	var locationString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
		if let top = self.topViewController as? FilterTypeVC {
			top.locationDelegate = self
		}
    }
	
	func GetLocationString() -> String {
		return locationString
	}

}
