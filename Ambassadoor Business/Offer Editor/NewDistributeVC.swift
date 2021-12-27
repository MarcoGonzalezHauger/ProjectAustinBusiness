//
//  NewDistributeVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/04/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewDistributeVC: BaseVC, changedDelegate {
    // changedDelegate delegate method. set amountOfMoneyInCents from money textfield.
    func changed() {
        //money.moneyValue = amountOfMoneyInCents
        amountOfMoneyInCents = money.moneyValue
    }
    
    
    @IBOutlet weak var money: MoneyField!
    
    var amountOfMoneyInCents: Int = 10000
    
    var draftOffer: DraftOffer!
    
    var filter: OfferFilter!

    override func viewDidLoad() {
        super.viewDidLoad()
        money.changedDelegate = self
        money.moneyValue = amountOfMoneyInCents
        self.addDoneButtonOnKeyboard(textField: self.money)
        // Do any additional setup after loading the view.
    }
    
    // Change amount of cents to dollar
    func getDesiredCashPower() -> Double {
        return Double(amountOfMoneyInCents) / 100
    }
    
    /// Distribute action
    /// - Parameter sender: UIButton referrance.
    @IBAction func DistributeOfferAction(sender: UIButton){
		
		let basicBusiness = globalBasicBusinesses.filter { (basic) -> Bool in
			return basic.basicId == self.draftOffer.basicId!
		}
		
		let isXo = basicBusiness.first!.name == "XO Taco"
		
		if isXo {
			
			print("this offer will be sent using credit card feature.")
			
			// THIS IS FOR CASE STUDY WITH XO TACO.
			
			let alert = UIAlertController.init(title: "Gift Cards", message: "XO Taco Only: Use Gift Cards as payment?", preferredStyle: .actionSheet)
			
			
			alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { alert in
				self.distributeOffer(xoTaco: true)
			}))
			
			alert.addAction(UIAlertAction.init(title: "No, use cash", style: .default, handler: { alert in
				self.distributeOffer(xoTaco: true)
			}))
			
			alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
				
			self.present(alert, animated: true, completion: nil)
			
		} else {
			distributeOffer(xoTaco: false)
		}
    }
    
    /// Check cash power if not equal to zero. check offer amount if more than 3. check user balance if more than zero. Distribute offer to offer pool.
    /// - Parameter xoTaco: send true business is "XO Taco" othe wise false
	func distributeOffer(xoTaco: Bool) {
		if getDesiredCashPower() != 0 {
			let offerAmount = getDesiredCashPower()
				if offerAmount >= 3 {
					
					if MyCompany.finance.balance > 0 {
						
						let basicBusiness = globalBasicBusinesses.filter { (basic) -> Bool in
							return basic.basicId == self.draftOffer.basicId!
						}
				   
						
						
						self.draftOffer.distributeToPool(asBusiness: MyCompany, asBasic: basicBusiness.first!, filter: self.filter, xoTacoCaseStudy: xoTaco, withMoney: offerAmount, withDrawFundsFalseForTestingOnly: true) { (error, dataOfBusiness) in
							
							if dataOfBusiness == nil{
								self.showAlertMessage(title: "Alert", message: error) {
									
								}
							}else{
								MyCompany = dataOfBusiness!
								self.showAlertMessage(title: "Offer has been Sent!", message: "Keep up to date with the results on the Statistics page!") {
									DispatchQueue.main.async {
										self.navigationController?.popToRootViewController(animated: true)
									}
								}
							}
							
						}
						
					}else{
						
						self.showAlertMessage(title: "Couldn't Distribute Offer.", message: "You don't have any money in your account. (Balance: \(NumberToPrice(Value: MyCompany.finance.balance))") {
							
						}
						
					}
					
				}else{
					self.showAlertMessage(title: "$3 minimum", message: "You must distribute the offer with a minimum of $3.") {
						
					}
			}
				
		}else{
			self.showAlertMessage(title: "No Budget", message: "You did not select a budget for the offer.") {
				
			}
		}
	}
    /// Custom textfield done button. resign first responder UITextField.
    override func doneButtonAction() {
        self.money.resignFirstResponder()
    }
    
    
    /// Dismiss current viewcontroller.
    /// - Parameter sender: UIButton referrance.
    @IBAction func cancelAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
