//
//  StripeConnectionMKWebview.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 01/10/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import WebKit
import Stripe
import Firebase


class StripeConnectionMKWebview: BaseVC, WKNavigationDelegate {

    @IBOutlet weak var webView_MKWeb: WKWebView!
    
    var withDrawAmount = 0.00
    

    let url = URL(string: "https://dashboard.stripe.com/express/oauth/authorize?response_type=code&client_id=\(API.Stripeclient_id)&scope=read_write")

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView_MKWeb.navigationDelegate = self
        self.hideActivityIndicator()
        
        guard let url = self.url else {
            self.showAlertMessage(title: "Alert", message: "The URL seems to be Invalid.") {
            }
            return
        }
                
        let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        let timeout: TimeInterval = 6.0
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
        
        request.httpMethod = "GET"
        self.showActivityIndicator()
        webView_MKWeb.load(request)
    }
    
    
    //MARK: WKWebView Delegate method
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showActivityIndicator()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideActivityIndicator()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.showAlertMessage(title: "Alert", message: error.localizedDescription) {
        }
    }
    
    
     func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {

        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")

        if let url = navigationAction.request.url {
                print(url.absoluteString)
            
            if url.absoluteString.hasPrefix("https://connect.stripe.com/connect/default_new/oauth/test?") || url.absoluteString.hasPrefix("https://connect.stripe.com/connect/default/oauth/test?"){
             
                    
            
                /*
                if url.absoluteString.hasPrefix("https://www.ambassadoor.co/paid?") || url.absoluteString.hasPrefix("https://www.ambassadoor.co/paid?code="){
                
                    */
                    print("SUCCESS")
                    
                    if let range = url.absoluteString.range(of: "code=") {
                        let code = url.absoluteString[range.upperBound...]
                        print(code) // prints "123.456.7891"
                        self.getAccountID(code: String(code))
                    }

             }
        }

        decisionHandler(.allow)
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    
    func getAccountID(code: String) {

        let params = ["client_secret": API.Stripeclient_secret,"code":code,"grant_type":"authorization_code"] as [String: AnyObject]
        self.showActivityIndicator()
        NetworkManager.sharedInstance.getAccountID(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

            print("dataString=",dataString as Any)
            do {
                _ = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]

                _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

                if let accDetail = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                    if (accDetail["stripe_user_id"] as? String) != nil {
                        
                        let stripe = StripeAccountInformation.init(dictionary: accDetail, userOrBusinessId: MyCompany.businessId)
                        MyCompany.finance.stripeAccount = stripe
                        
                        MyCompany.UpdateToFirebase { (errorFIB) in
                            if !errorFIB{
                                DispatchQueue.main.async {
                                    NotificationCenter.default.post(name: Notification.Name("reloadbanklist"), object: nil, userInfo: ["userinfo":"1"])
                                        
                                }
                            }else{
                                self.showAlertMessage(title: "Alert", message: "Something Wrong!!") {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                        
                        
                    }else{
                        self.hideActivityIndicator()
                        self.showAlertMessage(title: "Alert", message: "Something Wrong!!") {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    //createStripeAccToFIR(AccDetail:accDetail)
                    

                }

            }catch _ {
                
                self.hideActivityIndicator()

            }
        }
        
    }
    

    
    func withDrawAmoutSendServer(acctID: String, amount: Double) {
        
        let params = ["accountID":acctID,"amount":amount] as [String: AnyObject]
        NetworkManager.sharedInstance.withdrawThroughStripe(params: params) { (status, error, data) in
            
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString as Any)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let code = json!["code"] as? Int {
                    
                    if code == 401 {
                        self.hideActivityIndicator()
                        let message = json!["message"] as! [String:Any]
                        self.showAlertMessage(title: "Alert", message:  message["code"] as! String) {
                            
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                            
                        }
                    }else{
                        self.getDepositDetailValue(amount: amount, stripeID: acctID, cardDetails: json!)
//                        DispatchQueue.main.async {
//                            self.dismiss(animated: true, completion: nil)
//                        }
//
                        
                        
                        
                    }
                }
                
            }catch _ {
                
                self.hideActivityIndicator()
                
            }
            
        }
        
    }
    
    func getDepositDetailValue(amount: Double,stripeID: String, cardDetails: [String : Any]) {
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
            
            
            
            let depositedAmount = (amount/100)
            
            //let cardDetails = ["last4":stripeID,"expireMonth":"00","expireYear":"00","country":"US"] as [String : Any]
            
            let transactionDict = ["id":stripeID,"status":"success","type":"withdraw","currencyIsoCode":"usd","amount":String(depositedAmount),"createdAt":DateFormatManager.sharedInstance.getCurrentDateString(),"updatedAt":DateFormatManager.sharedInstance.getCurrentDateString(),"transactionType":"card","cardDetails":cardDetails,"commission":0.0] as [String : Any]
            
            
            if status == "new" {
                
                
                let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                
                let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                
                var depositHistory = [Any]()
                depositHistory.append(tranObj)
                
                let deposit = Deposit.init(dictionary: ["userID":Auth.auth().currentUser!.uid ,"currentBalance":depositedAmount,"totalDepositAmount":depositedAmount,"totalDeductedAmount":0.00,"lastDeductedAmount":0.00,"lastDepositedAmount":depositedAmount,"lastTransactionHistory":tranObj,"depositHistory":depositHistory])
                
                sendDepositAmount(deposit: deposit, companyUser: Auth.auth().currentUser!.uid) { (deposit, status) in
                    self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                    DispatchQueue.main.async(execute: {

                        self.dismiss(animated: true, completion: nil)
                    })
                }
                
                
            }else if status == "success" {
                
                let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                
                let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                
                let currentBalance = deposit!.currentBalance! - depositedAmount
                let totalDepositAmount = deposit!.totalDepositAmount!
                deposit?.totalDepositAmount = totalDepositAmount
                deposit?.currentBalance = currentBalance
                deposit?.lastDeductedAmount = depositedAmount
                deposit?.lastTransactionHistory = transactionObj
                var depositHistory = [Any]()
                
                
                
                depositHistory.append(contentsOf: (deposit!.depositHistory!))
                depositHistory.append(tranObj)
                
                deposit?.depositHistory = depositHistory
                
                sendDepositAmount(deposit: deposit!, companyUser: Auth.auth().currentUser!.uid) { (modifiedDeposit, status) in
                    self.hideActivityIndicator()
                    self.createLocalNotification(notificationName: "reloadDeposit", userInfo: [:])
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }
                
            }
            else{
                
                self.hideActivityIndicator()
                
            }
            
        }

    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
