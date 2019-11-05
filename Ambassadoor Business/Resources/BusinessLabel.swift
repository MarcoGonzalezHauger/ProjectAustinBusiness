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
		self.textColor = GetForeColor()
		self.text = "Ambassadoor Business"
		self.font = UIFont.systemFont(ofSize: 21, weight: .regular)
	}

}
