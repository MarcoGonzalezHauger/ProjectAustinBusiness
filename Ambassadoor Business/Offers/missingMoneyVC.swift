//
//  missingMoneyVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/31/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Stripe
import Firebase

protocol missingMoneyDelegate {
	func changeCashPowerAndRetry(_ newCashPower: Double)
	func RetryDistribution(deposit: Deposit)
}

class missingMoneyVC: BaseVC,STPAddCardViewControllerDelegate, STPAuthenticationContext, STPPaymentContextDelegate {
    
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true)
    }
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        
        // Getting payment Method Stripe ID and convert Amount Dollor to Cents(Stripe access cents only) and send to firebase server.
        //actualCharge
        //(self.actualCharge * 100.00)
        let params = ["stripeID":paymentMethod.stripeId,"amount":(Int((self.actualCharge * 100.00).rounded())),"mode":"test"] as [String : Any]
        //let params = ["stripeID":paymentMethod.stripeId,"amount":(self.actualCharge * 100.00)] as [String : Any]
        self.depositAmountToWalletThroughStripe(params: params, paymentMethodParams: paymentMethod)
        

    }
    
    
    

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
    
    var addCardViewController = STPAddCardViewController()
	
	override func viewDidLoad() {
        super.viewDidLoad()
        print("actual Charge=",actualCharge)
        // Do any additional setup after loading the view.
		
		distribWithoutBudget.isHidden = avaliableFunds == 0
		amountMissingLabel.text = NumberToPrice(Value: missingFunds, enforceCents: true)
		payNowInfo.text = "With transaction fees, you will be charged \(NumberToPrice(Value: actualCharge, enforceCents: true))"
		withoutBudgetInfo.text = "Distribute this offer with only \(NumberToPrice(Value: avaliableFunds, enforceCents: true)) out of \(NumberToPrice(Value: desiredCashPower, enforceCents: true))"
    }
	
	@IBAction func payTheDifference(_ sender: Any) {
		UseTapticEngine()
		//1: Display the Credit Card VC that's used on the deposit tab for the amount "actualCharge"
        self.addCardViewController = STPAddCardViewController()
        self.addCardViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: self.addCardViewController)
        self.present(navigationController, animated: true)
		//If the user depostied the correct amount:
			//2: Download the company's balance from Firebase (again).
			//3: Add the new amount to the balance.
			//4: Upload the Balance to Firebase.
			
			//Finally, to distribute:
			//dismiss(animated: true) {
			//	self.delegate?.RetryDistribution()
			//}
	}
    
    //MARK: Stripe Payment
    
        func depositAmountToWalletThroughStripe(params: [String: Any],paymentMethodParams: STPPaymentMethod) {
            
            //if params["amount"] as! String != "" && params["amount"] as! String != "0.00" {
               
                NetworkManager.sharedInstance.postAmountToServerThroughStripe(params: params) { (status, error, data) in
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    print("dataString=",dataString ?? "nil")
                    
                    if error == nil {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                            
                            
                            
                            if let statusCode = json!["code"] as? Int {
                                
                                if statusCode == 200 {
                                    
                                    if let transactionDetails = json!["result"] as? NSDictionary {
                                        
                                        if let clientSecret = transactionDetails["client_secret"] as? String {
                                            self.stripePaymentMethod(clientSecret: clientSecret, paymentMethodParams: paymentMethodParams)
                                            
                                        }
                                        
                                    }else{
                                        
                                        DispatchQueue.main.async(execute: {
                                        
                                        self.addCardViewController.dismiss(animated: true, completion: nil)
                                        self.addCardViewController = STPAddCardViewController()
                                        })
                                        
                                        self.showAlertMessage(title: "Error", message: "Something Wrong!. Please try again later.") {
                                        }
                                        
                                    }
                                    
                                  
                                    
                                }else{
                                    DispatchQueue.main.async(execute: {
                                    
                                    self.addCardViewController.dismiss(animated: true, completion: nil)
                                    self.addCardViewController = STPAddCardViewController()
                                    })
                                    
                                    self.showAlertMessage(title: "Error", message: "Something Wrong!. Please try again later.") {
                                    }
                                }
                                
                            }
                            
                            
                        } catch _ {
                            
                            DispatchQueue.main.async(execute: {
                            
                            self.addCardViewController.dismiss(animated: true, completion: nil)
                            self.addCardViewController = STPAddCardViewController()
                            })
                            
                            self.showAlertMessage(title: "Error", message: "Something Wrong!. Please try again later.") {
                            }
                            
                        }
                        
                    }else{
                        DispatchQueue.main.async(execute: {
                        
                        self.addCardViewController.dismiss(animated: true, completion: nil)
                        self.addCardViewController = STPAddCardViewController()
                        })
                        
                        self.showAlertMessage(title: "Error", message: "Something Wrong!. Please try again later.") {
                        }
                    }
                    
                }

                
                
    //        }else{
    //
    //        }
            
        }
    
    func stripePaymentMethod(clientSecret: String, paymentMethodParams: STPPaymentMethod) {
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        let paymentManager = STPPaymentHandler.shared()
        paymentIntentParams.paymentMethodId = paymentMethodParams.stripeId
        paymentManager.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
            
            switch (status) {
            case .failed: break
            // Handle error
            case .canceled: break
            // Handle cancel
            case .succeeded:
                // Payment Intent is confirmed
                
                DispatchQueue.main.async {
                    self.addCardViewController.dismiss(animated: true, completion: nil)
                }
                getDepositDetails(companyUser: Auth.auth().currentUser!.uid) { (deposit, status, error) in
                    /*var userID: String?
                     var currentBalance: Double?
                     var totalDepositAmount: Double?
                     var totalDeductedAmount: Double?
                     var lastDeductedAmount: Double?
                     var lastDepositedAmount: Double?
                     var lastTransactionHistory: TransactionDetails?
                     var depositHistory: [AnyObject]?
                     */
                    
                    print(paymentIntent?.amount as Any)
                    print(paymentIntent?.clientSecret as Any)
                    print(paymentIntent?.currency as Any)
                    print(paymentIntent?.paymentMethodId as Any)
                    print(paymentIntent?.stripeId as Any)
                    print(paymentIntent?.status as Any)
                    print(paymentMethodParams.card?.expMonth as Any)
                    
                    let depositedAmount = Double(self.actualCharge)
                    
                    let cardDetails = ["last4":(paymentMethodParams.card?.last4)!,"expireMonth":(paymentMethodParams.card?.expMonth)!,"expireYear":(paymentMethodParams.card?.expYear)!,"country":(paymentMethodParams.card?.country)!] as [String : Any]
                    print(paymentIntent?.created?.toString(dateFormat: "yyyy/MMM/dd HH:mm:ssZ") as Any)
                    
                    
                    
                    let transactionDict = ["id":(paymentIntent?.stripeId)!,"status":String(paymentIntent!.status.rawValue),"type":"sale","currencyIsoCode":paymentIntent!.currency,"amount":String(depositedAmount),"createdAt":(paymentIntent!.created?.toString(dateFormat: "yyyy/MMM/dd HH:mm:ssZ"))!,"updatedAt":(paymentIntent?.created?.toString(dateFormat: "yyyy/MMM/dd HH:mm:ssZ"))!,"transactionType":"card","cardDetails":cardDetails,"commission":0.0] as [String : Any]

                    
                    if status == "new" {
                        
                        
                        let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                        
                        let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                                                
                        var depositHistory = [Any]()
                        depositHistory.append(tranObj)
                        
                        let deposit = Deposit.init(dictionary: ["userID":Auth.auth().currentUser!.uid, "currentBalance":depositedAmount, "totalDepositAmount":depositedAmount, "totalDeductedAmount":0.00, "lastDeductedAmount":0.00, "lastDepositedAmount":depositedAmount, "lastTransactionHistory":tranObj, "depositHistory":depositHistory])
                        
                        sendDepositAmount(deposit: deposit, companyUser: Auth.auth().currentUser!.uid) { (deposit, status) in
                            //self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                            self.delegate?.RetryDistribution(deposit: deposit)
                            DispatchQueue.main.async(execute: {
                                
                                self.dismiss(animated: true, completion: nil)
                            })
                        }

                        
                    }else if status == "success" {
                        
                        let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                        
                        
                        
                        let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                        
                        let currentBalance = deposit!.currentBalance! + depositedAmount
                        
                        let totalDepositAmount = deposit!.totalDepositAmount! + depositedAmount
                        deposit?.totalDepositAmount = totalDepositAmount
                        deposit?.currentBalance = currentBalance
                        deposit?.lastDepositedAmount = depositedAmount
                        deposit?.lastTransactionHistory = transactionObj
                        var depositHistory = [Any]()
                        
                        
                        
                        depositHistory.append(contentsOf: (deposit!.depositHistory!))
                        depositHistory.append(tranObj)
                        
                        deposit?.depositHistory = depositHistory
                        
                        sendDepositAmount(deposit: deposit!, companyUser: Auth.auth().currentUser!.uid) { (modifiedDeposit, status) in
//                            self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                            accountBalance = (deposit!.currentBalance!)
                            for value in deposit!.depositHistory! {
                            
                            if let valueDetails = value as? NSDictionary {
                                
                                var amount = 0.0
                                
                                if let amt = valueDetails["amount"] as? String {
                                    amount = Double(amt)!
                                }else if let amt = valueDetails["amount"] as? Double{
                                   amount = amt
                                }
                            
                                transactionHistory.append(Transaction(description: "", details: valueDetails["cardDetails"] as AnyObject, time: valueDetails["updatedAt"] as! String, amount: amount, type: valueDetails["type"] as! String, status: valueDetails["status"] as? String ?? "", userName: valueDetails["userName"] as? String ?? "", date: DateFormatManager.sharedInstance.getDateFromStringWithAutoMonthFormat(dateString: valueDetails["updatedAt"] as! String), id: valueDetails["id"] as? String ?? ""))
                                
                            }
                                
                            }
                            self.delegate?.RetryDistribution(deposit: deposit!)
                            self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                            DispatchQueue.main.async(execute: {
                                self.dismiss(animated: true, completion: nil)
                            })
                        }
                        
                    }
                    else{
                        
                        
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
	
	@IBAction func distributeWithoutFullBudget(_ sender: Any) {
		UseTapticEngine()
		dismiss(animated: true) {
			self.delegate?.changeCashPowerAndRetry(self.avaliableFunds)
		}
	}
	
	@IBAction func cancelDistribution(_ sender: Any) {
		UseTapticEngine()
		dismiss(animated: true, completion: nil)
	}
	
}
