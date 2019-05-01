//
//  BusinessLabel.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BusinessLabel: UILabel {
	
	override func awakeFromNib() {
		self.textColor = UIColor(red: 77/225, green: 161/255, blue: 223/255, alpha: 1)
		self.text = "Ambassadoor Business"
	}

}
