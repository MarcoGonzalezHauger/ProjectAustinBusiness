//
//  MoneyField.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol changedDelegate {
	func changed()
}

class MoneyField: UITextField, UITextFieldDelegate {

	var moneyValue: Int = 0 {
		didSet {
			self.text = moneyValue == 0 ? "" : updateAmount()
		}
	}
	
	var changedDelegate: changedDelegate?
	
	override func awakeFromNib() {
		self.delegate = self
		self.placeholder = updateAmount()
	}
		
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if let digit = Int(string) {
			if moneyValue < 100000000000 {
				moneyValue = moneyValue * 10 + digit
			}
		}
		
		if string == "" {
			moneyValue = moneyValue / 10
		}
		changedDelegate?.changed()
		
		return false
	}
	
	func updateAmount() -> String? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		let amount = Double(moneyValue/100) + Double(moneyValue%100)/100
		
		return formatter.string(from: NSNumber(value: amount))
	}

}
