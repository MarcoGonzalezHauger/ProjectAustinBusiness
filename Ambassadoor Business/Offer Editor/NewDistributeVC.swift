//
//  NewDistributeVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/04/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewDistributeVC: BaseVC, changedDelegate {
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
    
    func getDesiredCashPower() -> Double {
        return Double(amountOfMoneyInCents) / 100
    }
    
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
    
    override func doneButtonAction() {
        self.money.resignFirstResponder()
    }
    
    @IBAction func cancelAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}
