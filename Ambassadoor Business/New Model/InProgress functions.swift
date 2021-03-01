//
//  InProgress functions.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/14/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

extension InProgressPost {
	func cancelPost() {
		status = "Cancelled"
		dateCancelled = Date()
	}
}
