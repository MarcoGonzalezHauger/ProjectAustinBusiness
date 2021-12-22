//
//  DepositVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
//import BraintreeDropIn
//import Braintree
import Stripe
import Firebase

enum EditingMode {
	case slider, manual
}
//BTViewControllerPresentingDelegate, BTAppSwitchDelegate,
class DepositVC: BaseVC, changedDelegate, STPAddCardViewControllerDelegate, STPAuthenticationContext, STPPaymentContextDelegate {
    
    
    
    //MARK:- Stripe Connection Delegate
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        
        // Getting payment Method Stripe ID and convert Amount Dollor to Cents(Stripe access cents only) and send to firebase server.
        //MARK: Test Mode
        //let params = ["stripeID":paymentMethod.stripeId,"amount":(self.creditAmount * 100.00),"mode":"test"] as [String : Any]
        //MARK: LIVE Stripe
        let params = ["stripeID":paymentMethod.stripeId,"amount":(self.creditAmount * 100.00), "mode": API.isForTesting == true ? "test" : "live"] as [String : Any]
        self.depositAmountToWalletThroughStripe(params: params, paymentMethodParams: paymentMethod)
        

    }
	
	@IBOutlet weak var moneySlider: UISlider!
    @IBOutlet weak var ExpectedReturns: UILabel!
    @IBOutlet weak var ExpectedPROFIT: UILabel!
	@IBOutlet weak var proceedView: ShadowView!
	
    //var braintreeClient: BTAPIClient!
	
	var amountOfMoneyInCents: Int = 10000
    
    var creditAmount = 0.00
    
    var addCardViewController = STPAddCardViewController()
	
	func changed() {
		editMode = .manual
		amountOfMoneyInCents = money.moneyValue
		moneyChanged()
	}
	
	var editMode: EditingMode = .manual
	@IBOutlet weak var money: MoneyField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		money.changedDelegate = self
		money.moneyValue = amountOfMoneyInCents
		moneyChanged()
        self.addDoneButtonOnKeyboard(textField: self.money)
	}
    
    override func doneButtonAction() {
        self.money.removeTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
        self.money.resignFirstResponder()
        self.money.addTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
    }
	
    
    /// Show expected returns and profit based on their deposit amount
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
	
    
    /// show local currency of the amount
    /// - Parameter Value: send amount in Int
    /// - Returns: return local currency of the amount
	func LocalPriceGetter(Value: Int) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
		let amount = Double(Value/100) + Double(Value % 100)/100
		
		return formatter.string(from: NSNumber(value: amount))!
	}
	
    
    /// Cnage amount based on UISlider
    /// - Parameter sender: UISlider referrance
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
	
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
	@IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
	}
    
    /// Check if user entered valid amount. As per ambassadoor standard, we add service charge with user deposit amount. Show alert for confirmation to add total amount.
    /// - Parameter sender: UIButton referrance
	@IBAction func proceedAction(sender: UIButton){
		
		if amountOfMoneyInCents != 0 {
						
			let depositAmount: Double =  Double(amountOfMoneyInCents) / 100
			
			let totalAmount = (((depositAmount * 1.029 + 0.3) * 100).rounded()) / 100
			
			self.creditAmount = totalAmount
			
			let DepositString = NumberToPrice(Value: depositAmount, enforceCents: true)
			let TotalString = NumberToPrice(Value: totalAmount, enforceCents: true)
			
			self.showAlertMessageForDestruction(title: "Alert", message: "You will deposit \(DepositString) into your Ambassadoor Money Account.\n Total Amount (including fees) that will be charged is \(TotalString).", cancelTitle: "OK", destructionTitle: "Cancel", completion: {
                self.addCardViewController = STPAddCardViewController()
				self.addCardViewController.delegate = self
				let navigationController = UINavigationController(rootViewController: self.addCardViewController)
				self.present(navigationController, animated: true)
				
			}) {
				
				
				
			}
			
		} else{
			
			MakeShake(viewToShake: money)
			
		}
		
	}
    
    func getDropInUI(token: String) {
        
//        let request =  BTDropInRequest()
//
//        let dropIn = BTDropInController(authorization: token, request: request)
//        { (controller, result, error) in
//            if (error != nil) {
//                print("ERROR")
//            } else if (result?.isCancelled == true) {
//                print("CANCELLED")
//            } else if let result = result {
//                // Use the BTDropInResult properties to update your UI
//                // result.paymentOptionType
//                // result.paymentMethod
//                // result.paymentIcon
//                // result.paymentDescription
//                print("nonce=",result.paymentMethod!.nonce)
//                let companyUser = Singleton.sharedInstance.getCompanyUser()
//                let params = ["nonce":result.paymentMethod!.nonce,"userID":companyUser.userID!,"amount":String(self.money.text!.dropFirst())]
//                self.depositAmountToWallet(params: params as [String : AnyObject])
//
//            }
//            controller.dismiss(animated: true, completion: nil)
//        }
//
//        self.present(dropIn!, animated: true, completion: nil)
//        //})
        
    }
    
    
    /// Check if stripe id and payments are valid to stripe server and make further authentication process. this function works in firebase single application.
    /// - Parameters:
    ///   - params: stripeID, amount, mode
    ///   - paymentMethodParams: STPPaymentMethod referrance
    func depositAmountToWalletThroughStripe(params: [String: Any],paymentMethodParams: STPPaymentMethod) {
        
        //if params["amount"] as! String != "" && params["amount"] as! String != "0.00" {
        
        //self.stripePaymentMethod(clientSecret: clientSecret, paymentMethodParams: paymentMethodParams)
           
            NetworkManager.sharedInstance.postAmountToServerThroughStripe(params: params) { (status, error, data) in
                
                
                
                if error == nil {
                    
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    print("dataString=",dataString ?? "nil")
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                        
                        
                        
                        if let statusCode = json!["code"] as? Int {
                            
                            if statusCode == 200 {
                                
                                if let transactionDetails = json!["result"] as? NSDictionary {
                                    
                                    if let clientSecret = transactionDetails["client_secret"] as? String {
                                        self.stripePaymentMethod(clientSecret: clientSecret, paymentMethodParams: paymentMethodParams)
                                        
                                    }
                                    
                                }else{
                                    
                                }
                                
                              
                                
                            }
                            
                        }
                        
                        
                    } catch _ {
                        
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
    
    /// Pass stripe server client secret ID and stripe id to stripe for further process to get amount from card. if amount deducted from card successfully, add amount to user account and update changes to firebase.
    /// - Parameters:
    ///   - clientSecret: stripe server clent secret ID
    ///   - paymentMethodParams: STPPaymentMethod referrance
    func stripePaymentMethod(clientSecret: String, paymentMethodParams: STPPaymentMethod) {
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        let paymentManager = STPPaymentHandler.shared()
        paymentIntentParams.paymentMethodId = paymentMethodParams.stripeId
		paymentManager.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
            
            switch (status) {
            case .failed:
            // Handle error
            self.dismissStripeController()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showAlertMessage(title: "Alert", message: "Payment Failed. Try Again Later") {
                }
            }
            
            case .canceled:
            // Handle cancel
                self.dismissStripeController()
            case .succeeded:
                // Payment Intent is confirmed
                self.dismissStripeController()
                let transId = Database.database().reference().childByAutoId().key
                
                let transDict = ["type":"creditCardDeposit","value":Double(self.amountOfMoneyInCents) / 100,"time": Date().toUString()] as [String : Any]
                
                let log = BusinessTransactionLogItem.init(dictionary: transDict, businessId: MyCompany.businessId, transactionId: transId!)
                
                MyCompany.finance.log.append(log)
                
                MyCompany.finance.balance = MyCompany.finance.balance + Double(self.amountOfMoneyInCents) / 100
                
                MyCompany.UpdateToFirebase { (errorFIB) in
                    
                    if !errorFIB{
                        self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                        DispatchQueue.main.async(execute: {

                            self.navigationController?.popViewController(animated: true)
                        })
                    }else{
                        self.showAlertMessage(title: "Error", message: "Something Went Wrong") {
                            
                        }
                    }
                    
                }
                                
                
            }
            
        }
        
    }
    
    /// Re- Initialise stripe controller
    func dismissStripeController() {
        DispatchQueue.main.async {
            self.addCardViewController.dismiss(animated: true, completion: nil)
            self.addCardViewController = STPAddCardViewController()
        }
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
    
    @IBAction func paypalAction(sender: UIButton){
        
//        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
//        payPalDriver.viewControllerPresentingDelegate = self
//        payPalDriver.appSwitchDelegate = self
//
////        payPalDriver.authorizeAccount() { (tokenizedPayPalAccount, error) -> Void in
////        }
//
//        // ...start the Checkout flow
//        let payPalRequest = BTPayPalRequest(amount: "1.00")
//        payPalDriver.requestOneTimePayment(payPalRequest) { (tokenizedPayPalAccount, error) -> Void in
//        }
        
    }
    
//    func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
//
//    }
//
//    func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
//
//    }
//
//    func appSwitcherWillPerformAppSwitch(_ appSwitcher: Any) {
//
//    }
    
//    func appSwitcher(_ appSwitcher: Any, didPerformSwitchTo target: BTAppSwitchTarget) {
//
//    }
    
//    func appSwitcherWillProcessPaymentInfo(_ appSwitcher: Any) {
//
//    }
	
}
