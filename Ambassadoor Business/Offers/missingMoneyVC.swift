//
//  missingMoneyVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/31/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol missingMoneyDelegate {
	func changeCashPowerAndRetry(_ newCashPower: Double)
	func RetryDistribution()
}

class missingMoneyVC: UIViewController {

	@IBOutlet weak var amountMissingLabel: UILabel!
	@IBOutlet weak var payNowInfo: UILabel!
	@IBOutlet weak var withoutBudgetInfo: UILabel!
	@IBOutlet weak var distribWithoutBudget: ShadowView!
	
	var delegate: missingMoneyDelegate?
	
	var desiredCashPower: Double = 0
	var avaliableFunds: Double = 0
	var missingFunds: Double {
		get {
			return desiredCashPower - avaliableFunds
		}
	}
	var actualCharge: Double {
		get {
			return (missingFunds * 1.029) + 0.30
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		distribWithoutBudget.isHidden = avaliableFunds == 0
		amountMissingLabel.text = NumberToPrice(Value: missingFunds, enforceCents: true)
		payNowInfo.text = "With transaction fees, you will be charged \(NumberToPrice(Value: actualCharge, enforceCents: true))"
		withoutBudgetInfo.text = "Distribute this offer with only \(NumberToPrice(Value: avaliableFunds, enforceCents: true)) out of \(NumberToPrice(Value: desiredCashPower, enforceCents: true))"
    }
	
	@IBAction func payTheDifference(_ sender: Any) {
		//1: Display the Credit Card VC that's used on the deposit tab for the amount "actualCharge"
		//If the user depostied the correct amount:
			//2: Download the company's balance from Firebase (again).
			//3: Add the new amount to the balance.
			//4: Upload the Balance to Firebase.
			
			//Finally, to distribute:
			//dismiss(animated: true) {
			//	self.delegate?.RetryDistribution()
			//}
	}
	
	@IBAction func distributeWithoutFullBudget(_ sender: Any) {
		dismiss(animated: true) {
			self.delegate?.changeCashPowerAndRetry(self.avaliableFunds)
		}
	}
	
	@IBAction func cancelDistribution(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
