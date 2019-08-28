//
//  DepositVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import BraintreeDropIn
import Braintree

enum EditingMode {
	case slider, manual
}

class DepositVC: BaseVC, changedDelegate {
	
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
    
    @IBAction func proceedAction(sender: UIButton){
        print("cccc=",money.text!.count)
        print("cccc=1",money.text!.replacingOccurrences(of: " ", with: "").count)
        if money.text?.dropFirst() != "0.00" && money.text!.replacingOccurrences(of: " ", with: "").count != 0 {
        
        NetworkManager.sharedInstance.getClientTokenFromServer { (result, errorValue, data) in

            if result == "success" {

                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]

                    let clientToken = json!["token"] as! String
                    DispatchQueue.main.async(execute: {
                    self.getDropInUI(token: clientToken)
                    })
                } catch _ {

                }

            }else{

            }
            
        }
    }else{
            
            self.showAlertMessage(title: "Alert", message: "Please deposit any amount") {
                
            }
            
        }
        
    }
    
    func getDropInUI(token: String) {
        
        let request =  BTDropInRequest()
        
        let dropIn = BTDropInController(authorization: token, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                // result.paymentDescription
                print("nonce=",result.paymentMethod!.nonce)
                let companyUser = Singleton.sharedInstance.getCompanyUser()
                let params = ["nonce":result.paymentMethod!.nonce,"userID":companyUser.userID!,"amount":String(self.money.text!.dropFirst())]
                self.depositAmountToWallet(params: params as [String : AnyObject])
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
        //})
        
    }
    
    func depositAmountToWallet(params: [String: AnyObject]) {
        
        if params["amount"] as! String != "" && params["amount"] as! String != "0.00" {
        
        NetworkManager.sharedInstance.postNonceWithAmountToServer(params: params) { (status, error, data) in
            
            if error == nil {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    print("dataString=",dataString)
                    
                    if let statusCode = json!["code"] as? Int {
                        
                        if statusCode == 200 {
                            
                            if let transactionDetails = json!["result"] as? NSDictionary {
                            
                                if let success = transactionDetails["success"] as? Bool {
                                    if success == true {
                                        let transaction = transactionDetails["transaction"] as! [String: Any]
                            getDepositDetails(companyUser: params["userID"] as! String) { (deposit, status, error) in
                                /*var userID: String?
                                 var currentBalance: Double?
                                 var totalDepositAmount: Double?
                                 var totalDeductedAmount: Double?
                                 var lastDeductedAmount: Double?
                                 var lastDepositedAmount: Double?
                                 var lastTransactionHistory: TransactionDetails?
                                 var depositHistory: [AnyObject]?
                                 */
                                if status == "new" {
                                    let transactionObj = TransactionDetails.init(dictionary: transaction )
                                    let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                                    var depositHistory = [Any]()
                                    depositHistory.append(tranObj)
                                    let deposit = Deposit.init(dictionary: ["userID":params["userID"] as! String,"currentBalance":Double(transaction["amount"] as! String)!,"totalDepositAmount":Double(transaction["amount"] as! String)!,"totalDeductedAmount":0.00,"lastDeductedAmount":0.00,"lastDepositedAmount":Double(transaction["amount"] as! String)!,"lastTransactionHistory":transaction,"depositHistory":depositHistory])
                                    sendDepositAmount(deposit: deposit, companyUser: params["userID"] as! String) { (deposit, status) in
                                        self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                                        DispatchQueue.main.async(execute: {
                                            
                                        self.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                    
                                }else if status == "success" {
                                    
                                    let transactionObj = TransactionDetails.init(dictionary: transaction )
                                    let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                                    
                                    let currentBalance = deposit!.currentBalance! + Double(transaction["amount"] as! String)!
                                    let totalDepositAmount = deposit!.totalDepositAmount! + Double(transaction["amount"] as! String)!
                                    deposit?.totalDepositAmount = totalDepositAmount
                                    deposit?.currentBalance = currentBalance
                                    deposit?.lastDepositedAmount = Double(transaction["amount"] as! String)!
                                    deposit?.lastTransactionHistory = transactionObj
                                    var depositHistory = [Any]()
                                    
                                    depositHistory.append(contentsOf: (deposit!.depositHistory!))
                                    depositHistory.append(tranObj)
                                    
                                    deposit?.depositHistory = depositHistory
                                    
                                    sendDepositAmount(deposit: deposit!, companyUser: params["userID"] as! String) { (modifiedDeposit, status) in
                                        self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                                        DispatchQueue.main.async(execute: {
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                    
                                }
                                else{
                                    
                                    
                                    
                                }
                                
                            }
                                }else{
                                }
                            
                            }else{
                            }
                            }else {
                                self.showAlertMessage(title: "Alert", message: "Transaction Failed. Please try again later") {
                                    
                                }
                            }
                            
                        }
                        
                    }
                    
                    
                } catch _ {
                    
                }
                
            }
            
        }
    }else {
    
        
    }
	
    }
	
}
