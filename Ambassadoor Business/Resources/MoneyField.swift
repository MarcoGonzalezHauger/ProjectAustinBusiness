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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      self.resignFirstResponder()
      return true;
    }
	
//    func resign() {
//        self.resignFirstResponder()
//    }
    
//    func addDoneNativeButtonOnKeyboard()
//    {
//        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
//        doneToolbar.barStyle = UIBarStyle.default
//
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneNativeButtonAction))
//
//        let items = [flexSpace,done]
//        //        items.addObject(flexSpace)
//        //        items.addObject(done)
//
//        doneToolbar.items = items
//        doneToolbar.sizeToFit()
//
//        self.inputAccessoryView = doneToolbar
//
//
//    }
    
//    @objc func doneNativeButtonAction(){
//
//        self.endEditing(true)
//    }
    
	func updateAmount() -> String? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
		let amount = Double(moneyValue/100) + Double(moneyValue%100)/100
		return formatter.string(from: NSNumber(value: amount))
	}

}
