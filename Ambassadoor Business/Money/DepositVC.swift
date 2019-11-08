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
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        
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
        
//        NetworkManager.sharedInstance.postPaymentMethodThroughStripe(params: [:]) { (status, error, data) in
//
//            if error == nil {
//
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? AnyObject
//
//                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//                    print("dataString=",dataString)
//
//
//
//            } catch _ {
//
//            }
//
//            }
//
//        }
        
        
        
        let params = ["stripeID":paymentMethod.stripeId,"amount":(self.creditAmount * 100.00)] as [String : Any]
        self.depositAmountToWalletThroughStripe(params: params, paymentMethodParams: paymentMethod)
        
        
        
        //cardParams.number = STPPaymentCardTextField?.cardNumber
//        cardParams.expMonth = paymentMethod.card.
//        cardParams.expYear = (paymentCardTextField?.expirationYear)!
//        cardParams.cvc = paymentCardTextField?.cvc
//        STPAPIClient.shared().createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
//            guard let token = token, error == nil else {
//                // Present error to user...
//                return
//            }
//            print(self.dictPayData)
//
//        }
        
        
        
//        cardParams.number = paymentMethod.card?.expMonth
//        cardParams.expMonth = paymentMethod.card?.expMonth
//        cardParams.expYear = paymentMethod.card?.expYear
//        cardParams.cvc = paymentMethod.card?.
//        submitPaymentMethodToBackend(paymentMethod, completion: { (error: Error?) in
//            if let error = error {
//                // Show error in add card view controller
//                completion(error)
//            }
//            else {
//                // Notify add card view controller that PaymentMethod creation was handled successfully
//                completion(nil)
//
//                // Dismiss add card view controller
//                dismiss(animated: true)
//            }
//        })
    }
	
	@IBOutlet weak var moneySlider: UISlider!
    @IBOutlet weak var ExpectedReturns: UILabel!
    @IBOutlet weak var ExpectedPROFIT: UILabel!
    
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
        
		money.changedDelegate = self
		money.moneyValue = amountOfMoneyInCents
		moneyChanged()
        self.addDoneButtonOnKeyboard(textField: self.money)
	}
    
    override func doneButtonAction() {
        self.money .removeTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
        self.money.textFieldShouldReturn(self.money)
        self.money.addTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
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
            
            let moneyDouble = Double(money.text!.dropFirst())
            
            let stripeFeeNotRoundup = ((((moneyDouble! * 1.027 + 0.3) - moneyDouble!) * 100).rounded())
            
            let stripeFeeAmount = stripeFeeNotRoundup/100
            
            let depositAmount = moneyDouble!
            
            let totalAmount = (((moneyDouble! * 1.027 + 0.3) * 100).rounded())/100
            
            self.creditAmount = totalAmount
            
			let DepositString = NumberToPrice(Value: depositAmount, enforceCents: true)
			let TotalString = NumberToPrice(Value: totalAmount, enforceCents: true)
			
            self.showAlertMessageForDestruction(title: "Alert", message: "You will deposit \(DepositString) into your Ambassadoor Money Account.\n Total Amount (including fees) that will be charged is \(TotalString)", cancelTitle: "OK", destructionTitle: "Cancel", completion: {
                self.addCardViewController.delegate = self
                let navigationController = UINavigationController(rootViewController: self.addCardViewController)
                self.present(navigationController, animated: true)
                
            }) {
                
                
                
            }
            
            // Setup add card view controller
            
            //let config = STPPaymentConfiguration()
            //config.requiredBillingAddressFields = .full
            //addCardViewController = STPAddCardViewController.init(configuration: config, theme: STPTheme.default())
            // Present add card view controller
            
        
//        NetworkManager.sharedInstance.getClientTokenFromServer { (result, errorValue, data) in
//
//            if result == "success" {
//
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
//
//                    let clientToken = json!["token"] as! String
////                    DispatchQueue.main.async {
////                    self.braintreeClient = BTAPIClient(authorization: clientToken)
////                        let payPalDriver = BTPayPalDriver(apiClient: self.braintreeClient)
////                        payPalDriver.viewControllerPresentingDelegate = self
////                        payPalDriver.appSwitchDelegate = self
////
////                        //        payPalDriver.authorizeAccount() { (tokenizedPayPalAccount, error) -> Void in
////                        //        }
////
////                        // ...start the Checkout flow
////                        let payPalRequest = BTPayPalRequest(amount: "1.00")
////                        payPalDriver.requestOneTimePayment(payPalRequest) { (tokenizedPayPalAccount, error) -> Void in
////                        }
////                    }
//
//                    DispatchQueue.main.async(execute: {
//                    self.getDropInUI(token: clientToken)
//                    })
//                } catch _ {
//
//                }
//
//            }else{
//
//            }
//
//        }
    }else{
            
            self.showAlertMessage(title: "Alert", message: "Please deposit any amount") {
                
            }
            
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
                                    
                                }
                                
                              
                                
                            }
                            
                        }
                        
                        
                    } catch _ {
                        
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
        paymentManager.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
            DispatchQueue.main.async {
                self.addCardViewController.dismiss(animated: true, completion: nil)
            }
            switch (status) {
            case .failed: break
            // Handle error
            case .canceled: break
            // Handle cancel
            case .succeeded:
                // Payment Intent is confirmed
                
                
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
                    
					let depositedAmount = Double(self.amountOfMoneyInCents) / 100
                    
                    let cardDetails = ["last4":(paymentMethodParams.card?.last4)!,"expireMonth":(paymentMethodParams.card?.expMonth)!,"expireYear":(paymentMethodParams.card?.expYear)!,"country":(paymentMethodParams.card?.country)!] as [String : Any]
                    print(paymentIntent?.created?.toString(dateFormat: "yyyy-MM-dd HH:mm:ss") as Any)
                    
                    
                    
                    let transactionDict = ["id":(paymentIntent?.stripeId)!,"status":String(paymentIntent!.status.rawValue),"type":"sale","currencyIsoCode":paymentIntent!.currency,"amount":String(depositedAmount),"createdAt":(paymentIntent!.created?.toString(dateFormat: "yyyy-MM-dd HH:mm:ss"))!,"updatedAt":(paymentIntent?.created?.toString(dateFormat: "yyyy-MM-dd HH:mm:ss"))!,"transactionType":"card","cardDetails":cardDetails] as [String : Any]

                    
                    if status == "new" {
                        
                        
                        let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                        
                        let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                        
                        var depositHistory = [Any]()
                        depositHistory.append(tranObj)
                        
                        let deposit = Deposit.init(dictionary: ["userID":Auth.auth().currentUser!.uid, "currentBalance":depositedAmount, "totalDepositAmount":depositedAmount, "totalDeductedAmount":0.00, "lastDeductedAmount":0.00, "lastDepositedAmount":depositedAmount, "lastTransactionHistory":tranObj, "depositHistory":depositHistory])
                        
                        sendDepositAmount(deposit: deposit, companyUser: Auth.auth().currentUser!.uid) { (deposit, status) in
                            self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
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
