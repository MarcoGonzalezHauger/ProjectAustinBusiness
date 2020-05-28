//
//  DistributeVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/27/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class DistributeVC: BaseVC, changedDelegate {
	
	@IBOutlet weak var categorySwitch: UISwitch!
	@IBOutlet weak var locationSwitch: UISwitch!
	@IBOutlet weak var genderSwitch: UISwitch!
	
	func updateFilterApproximation() {
		///Ram, code should be written here.
		
		///When you get your result:
		//SetAvaliableInfluencers(_ numberOfInfluencers: Double)
	}
	
	
	///All you need to know about the code below:
	
//	getDesiredCashPower() -> Double
//	getIncreasePay() -> Double
//	getMustBe21() -> Bool
	
	//SetAvaliableInfluencers(_ numberOfInfluencers: Double)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		updateIncreasePayLabel()
		money.changedDelegate = self
		money.moneyValue = amountOfMoneyInCents
		moneyChanged()
        self.addDoneButtonOnKeyboard(textField: self.money)
		SetComissionText()
		updateFilterApproximation()
    }
	
	@IBOutlet weak var avaliableInfluencerLabel: UILabel!
	
	func SetAvaliableInfluencers(_ numberOfInfluencers: Double) {
		avaliableInfluencerLabel.textColor = numberOfInfluencers < 8 ? .systemRed : .systemBlue
		avaliableInfluencerLabel.text = "\(NumberToStringWithCommas(number: numberOfInfluencers))"
	}
	
	@IBOutlet weak var comissionLabel: UILabel!
	func SetComissionText() {
        let commission = Singleton.sharedInstance.getCommision() * 100
        if commission == floor(commission) {
            comissionLabel.text = "Based on average benchmarks of nano-influencing ROI across multiple industries. Ambassadoor will take \(Int(commission))%."
        } else {
            comissionLabel.text = "Based on average benchmarks of nano-influencing ROI across multiple industries. Ambassadoor will take \(commission)%."
        }
	}
	
	@IBAction func FilterSwitched(_ sender: Any) {
		updateFilterApproximation()
	}
	
	func getDesiredCashPower() -> Double {
		return Double(amountOfMoneyInCents) / 100
	}
	
	@IBOutlet weak var twentyOne: UISegmentedControl!
	func getMustBe21() -> Bool {
		return twentyOne.selectedSegmentIndex == 1
	}
	
	func getIncreasePay() -> Double {
		let val = Double(increasePaySlider.value)
		var newVal: Double = 1.0
		if val > 1 {
			newVal = 1 + (val / 10)
		} else if val < 1 {
			newVal = 1.1 + (val * 0.9)
		} else {
			newVal = 1.1
		}
		return floor(newVal * 100) / 100
	}
	
	func updateIncreasePayLabel() {
		if getIncreasePay() == 1 {
			increasePayLabel.text = "Nothing"
		} else if getIncreasePay() == 2 {
			increasePayLabel.text = "Double"
		} else {
			increasePayLabel.text = "+\(floor((getIncreasePay() - 1) * 100))%"
		}
		updateReturnsLabels()
	}
	
	@IBOutlet weak var increasePayLabel: UILabel!
	@IBOutlet weak var increasePaySlider: UISlider!
	@IBAction func increasePayChanged(_ sender: Any) {
		updateIncreasePayLabel()
	}
	
	@IBOutlet weak var moneySlider: UISlider!
    @IBOutlet weak var ExpectedReturns: UILabel!
    @IBOutlet weak var ExpectedPROFIT: UILabel!
	var amountOfMoneyInCents: Int = 10000
	func changed() {
		editMode = .manual
		amountOfMoneyInCents = money.moneyValue
		moneyChanged()
	}
	var editMode: EditingMode = .manual
	@IBOutlet weak var money: MoneyField!
    override func doneButtonAction() {
        self.money.removeTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
        self.money.resignFirstResponder()
        self.money.addTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
    }
	func updateReturnsLabels() {
		let centsToBeUsedOnLabels: Int = Int(floor(Double(amountOfMoneyInCents) / getIncreasePay()))
		ExpectedReturns.text = "Expected Return: \(LocalPriceGetter(Value: Int(Double(centsToBeUsedOnLabels) * 5.85)))"
		ExpectedPROFIT.text = "Expected Profit: \(LocalPriceGetter(Value: Int(Double(amountOfMoneyInCents) * (5.85 - getIncreasePay()))))"
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
		updateReturnsLabels()
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
	
}
