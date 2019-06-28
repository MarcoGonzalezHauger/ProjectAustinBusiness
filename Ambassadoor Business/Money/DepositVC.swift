//
//  DepositVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

enum EditingMode {
	case slider, manual
}

class DepositVC: UIViewController, changedDelegate {
	
	@IBOutlet weak var moneySlider: UISlider!
	
	var amountOfMoneyInCents: Int = 10000
	
	func changed() {
		editMode = .manual
		amountOfMoneyInCents = money.moneyValue
		moneyChanged()
	}
	
	var editMode: EditingMode = .manual
	@IBOutlet weak var money: MoneyField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		money.changedDelegate = self
		money.moneyValue = amountOfMoneyInCents
		moneyChanged()
	}
	
	func moneyChanged() {
		if editMode == .manual {
			let value = amountOfMoneyInCents
			if value > 1000000 {
				moneySlider.value = 3
			} else if value >= 100000 {
				moneySlider.value = (((Float(value) - 100000) / 9) / 100000) + 2
			} else if value >= 10000 {
				moneySlider.value = (((Float(value) - 10000) / 9) / 10000) + 1
			} else {
				moneySlider.value = Float(value) / 10000
			}
		} else {
			money.moneyValue = amountOfMoneyInCents
		}
		ExpectedReturns.text = "Expected Return: \(LocalPriceGetter(Value: Int(Double(amountOfMoneyInCents) * 5.85)))"
		ExpectedPROFIT.text = "Expected Profit: \(LocalPriceGetter(Value: Int(Double(amountOfMoneyInCents) * 4.85)))"
	}
	
	func LocalPriceGetter(Value: Int) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		let amount = Double(Value/100) + Double(Value % 100)/100
		
		return formatter.string(from: NSNumber(value: amount))!
	}
	
	@IBAction func TrackBarTracked(_ sender: Any) {
		editMode = .slider
		let value = Double(moneySlider.value)
		if value > 2 {
			amountOfMoneyInCents = Int((((value - 2) * 9) + 1) * 100000)
		} else if value > 1 {
			amountOfMoneyInCents = Int((((value - 1) * 9) + 1) * 10000)
		} else {
			amountOfMoneyInCents = Int(10000 * value)
		}
		moneyChanged()
	}
	
	@IBAction func dismiss(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBOutlet weak var ExpectedReturns: UILabel!
	@IBOutlet weak var ExpectedPROFIT: UILabel!
	
}
