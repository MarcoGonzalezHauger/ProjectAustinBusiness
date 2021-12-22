//
//  NewWithdrawVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class NewWithdrawVC: BaseVC {
    
    @IBOutlet weak var amt: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.amt.text = NumberToPrice(Value: MyCompany.finance.balance)
        // Do any additional setup after loading the view.
    }
    @IBAction func cancel_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// Get user finance information. Initiate withdraw transaction in stripe server
    /// - Parameter sender: UIButton referrance
    @IBAction func withdrawAction(sender: UIButton){
        
        let ref = Database.database().reference().child("Accounts/Private/Businesses").child(MyCompany.businessId)
        
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
        if let userInfo = snapshot.value as? [String: Any] {
            
            let business = Business.init(dictionary: userInfo, businessId: MyCompany.businessId)
            
            MyCompany = business
            
            if MyCompany.finance.balance == 0 {
                self.showAlertMessage(title: "No Money to Withdraw", message: "Please deposit any amount to Withdraw") {
                    
                }
                return
            }
            
            let subAmount = MyCompany.finance.balance
            MyCompany.finance.balance = 0
            
            MyCompany.UpdateToFirebase { (errorFIB) in
                if !errorFIB{
                    
                    self.withDrawAmoutSendServer(acctID: (MyCompany.finance.stripeAccount!.stripeUserId), amount:subAmount * 100 , mode: "test")
                    
                }
            }
                            
    }
        
        }, withCancel: nil)
        
    }
    
    
    /// Initiate withdraw transaction to stripe server. this function created in firebase function page. update user changes to firebase.
    /// - Parameters:
    ///   - acctID: stripe account ID
    ///   - amount: withdraw amount
    ///   - mode: test or live
    func withDrawAmoutSendServer(acctID: String, amount: Double, mode: String) {
            
            let params = ["accountID":acctID,"amount":amount, "mode": "live"] as [String: AnyObject]
            NetworkManager.sharedInstance.withdrawThroughStripe(params: params) { (status, error, data) in
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                print("dataString=",dataString as Any)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                    
                    _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    if let code = json!["code"] as? Int {
                        
                        if code == 401 {
                            self.hideActivityIndicator()
                            let message = json!["message"] as! [String:Any]
                            
                            MyCompany.finance.balance = (amount/100)
                            
                            MyCompany.UpdateToFirebase { (errorFIB) in
                                if !errorFIB{
                                    self.showAlertMessage(title: "Alert", message:  message["code"] as! String) {
                                        
                                        DispatchQueue.main.async {
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                        
                                    }
                                }
                            }
                            

                        }else{
                            
                            var transID = ""
                            if let withDrawIDObj = json!["result"] as? [String: AnyObject] {
                                if let withDrawID = withDrawIDObj["id"] as? String{
                                    transID = withDrawID
                                }
                            }
                            
                            let logDict = ["time":Date().toUString(),"type": "withdraw", "value":(amount/100)] as [String : Any]
                            
                            let log = BusinessTransactionLogItem.init(dictionary: logDict, businessId: MyCompany.businessId, transactionId: transID)
                            
                            MyCompany.finance.log.append(log)
                            
                            MyCompany.UpdateToFirebase { (errorFIB) in
                                if !errorFIB{
                                    self.performSegue(withIdentifier: "fromNewWithToNote", sender: (amount/100))
                                }
                            }
                            
                        }
                    }
                    
                }catch _ {
                    
                    self.hideActivityIndicator()
                    
                }
                
            }
            
        }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? WithDrawNoteVC{
            view.withDrawAmount = sender as! Double
        }
    }
    

}
