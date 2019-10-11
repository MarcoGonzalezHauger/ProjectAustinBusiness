//
//  WithdrawVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/30/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
// 	Exclusive Property of Tesseract Freelance, LLC.
//

import UIKit
import Firebase

class WithdrawVC: PlaidLinkEnabledVC,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var bankTableView: UITableView!
    @IBOutlet weak var depositBalance: UITextField!
    
    @IBOutlet weak var moneyText: UITextField!
    
    var dwollaFSList = [DwollaCustomerFSList]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.getDeepositDetails()
        
        getDwollaFundingSource { (object, status, error) in
        if error == nil {
            if object != nil {
                self.dwollaFSList = object!
                self.bankTableView.reloadData()
            }
        }
        }
    }
    
    @IBAction func normalWithDrawAction(sender: UIButton){
        
        if moneyText.text?.count != 0 {
            let doubleAmt = Double(moneyText.text!.dropFirst())
            let amountVal = doubleAmt! * 100
        
            self.performSegue(withIdentifier: "stripeconnect", sender: amountVal)
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please Enter Some Amount") {
                
            }
        }
    }
    
    @objc func getDeepositDetails() {
        let user = Singleton.sharedInstance.getCompanyUser()
        getDepositDetails(companyUser: user.userID!) { (deposit, status, error) in
            
            if status == "success" {
                
                self.depositBalance.text = NumberToPrice(Value: deposit!.currentBalance!, enforceCents: true)
                

            
        }
    }
        
    }
    
    @IBAction func presentPlaid(sender: UIButton){
        
        self.presentPlaid()
        
//        DispatchQueue.main.async(execute: {
//            let segueData = ["dpToken":"","dAccessToken":""]
//
//            self.performSegue(withIdentifier: "toDwollaUserInfo", sender: segueData)
//        })
        
    }
    
    override func handleSuccessWithToken(_ publicToken:String, institutionName:String, institutionID:String, acctID:String, acctName:String, metadata:[String:Any]?){
        
        NSLog("metadata: \(metadata ?? [:])")
        let current = ["publictoken":publicToken,"accountid":acctID] as! [String: AnyObject]
        if let accountArray = metadata!["accounts"] as? NSArray{
            if let accountDictionary = accountArray[0] as? NSDictionary{
                global.dwollaCustomerInformation.mask = accountDictionary["mask"] as! String
            }
            
        }
        global.dwollaCustomerInformation.acctID = acctID
        global.dwollaCustomerInformation.name = acctName
        self.getProcessorToken(params: current)
        //let current = ["publicToken":publicToken,"institutionName":institutionName,"institutionID":institutionID,"acctID":acctID,"acctName":acctName] as! [String: Any]
        
        //        let ref = Database.database().reference().child("InfluencerBanks")
        //        let userReference = ref.child(Yourself.id)
        //        let userData = API.serializeUser(user: userfinal!, id: userfinal!.id)
        //        userReference.updateChildValues(userData)
        
        
        
        
    }
    
    func getProcessorToken(params: [String: AnyObject]) {
        
        NetworkManager.sharedInstance.getDwollaProcessorToken(params: params) { (status, error, data) in
            
//            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//
//            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
//                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let statusCode = json!["code"] as? Int {
                    
                    if statusCode == 200 {
                        
                        if let processorToken = json!["result"] as? String {
                            
                            self.createDwollaAccessToken(token: processorToken)
                            
                        }
                    }
                }
                
            }catch _ {
                
            }
            
        }
        
    }
    
    func createDwollaAccessToken(token: String) {
        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
        NetworkManager.sharedInstance.getDwollaAccessToken(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                 if let accessToken = json!["access_token"] as? String {
                    
                    DispatchQueue.main.async(execute: {
                    let segueData = ["dpToken":token,"dAccessToken":accessToken]
                    
                    self.performSegue(withIdentifier: "toDwollaUserInfo", sender: segueData)
                    })
                    
//                    self.createFundingSourceForCustomer(dpToken: token, dAccessToken: accessToken)
                    
                }
                
            }catch _ {
                
            }
        }
        
    }
    
//    func createFundingSourceForCustomer(dpToken: String,dAccessToken: String) {
//
//        let params = ["plaidToken":dpToken,"name":Auth.auth().currentUser!.uid] as [String: AnyObject]
//
//        NetworkManager.sharedInstance.createFundingSourceForCustomer(params: params, accessToken: dAccessToken) { (status, error, data) in
//
//            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//
//            print("dataString=",dataString)
//
//        }
//
//    }
    
    //MARK: UITableview Delegates & Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dwollaFSList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "plaid", for: indexPath) as! PlaidTVCell
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "bankconnectedplaid", for: indexPath) as! ConnectedPlaidTVCell
            let obj = self.dwollaFSList[indexPath.row - 1]
            cell.nameText.text = obj.name
            cell.acctIDText.text = "****" + obj.mask
            cell.withdrawButton.tag = indexPath.row - 1
            cell.withdrawButton.addTarget(self, action: #selector(self.withDrawAction(sender:)), for: .touchUpInside)
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
        return 65.0
        }else{
        return 138.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if indexPath.row == 0 {
            
            self.presentPlaid()
            
        }else {
            
        }
    }
    
    @IBAction func withDrawAction(sender: UIButton){
        
        let index = sender.tag
        
        let object = self.dwollaFSList[index]
        self.createDwollaAccessTokenForFundTransfer(fundSource: object.customerFSURL, acctID: object.acctID, object: object)
    }
    
    func createDwollaAccessTokenForFundTransfer(fundSource: String, acctID: String, object: DwollaCustomerFSList) {
        
        let links = ["_links":["source":["href":API.superBankFundingSource],"destination":["href":fundSource]],"amount":["currency":"USD","value":"100"]] as [String: AnyObject]
        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
        NetworkManager.sharedInstance.getDwollaAccessToken(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let accessToken = json!["access_token"] as? String {
                    
                    NetworkManager.sharedInstance.createFundTransfer(params: links, accessToken: accessToken) { (status, error, data, response) in
                        if error == nil {
                            
                            if let header = response as? HTTPURLResponse {
                                
                                if header.statusCode == 201 {
                                    
                                    let tranferDetail = header.allHeaderFields["Location"]! as! String
                                    
                                    let tranferID = tranferDetail.components(separatedBy: "/")
                                    
                                    fundTransferAccount(transferURL: tranferDetail, accountID: tranferID.last!, Obj: object, currency:"USD", amount: "100")
                                    
                                    
                                    DispatchQueue.main.async(execute: {
                                    self.showAlertMessage(title: "Alert", message: "Successfully Fund Transfered. It takes more than 3 days to credit your account. please check the fund transfer status in withdraw details") {
                                        
                                    }
                                    })
                                    
                                }
                                
                            }
                        }
                    }
                }
                
            }catch _ {
                
            }
        }

        
    }
    
    @IBAction func proceedAction(sender: UIButton){
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toTransactionDetails", sender: self)
        }
    }
    
    //MARK: -Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if textField == self.moneyText {
            if string == "" {
                if self.moneyText.text!.count == 2 {
                    self.moneyText.text = ""
                }
                
            }else{
                if (self.moneyText.text?.first == "$"){
                    //self.offerRate.text = self.offerRate.text!
                }else{
                    self.moneyText.text = "$" + self.moneyText.text!
                }
                
            }
            return true
            
        }else{
            return true
        }
    }

    
	
	@IBAction func dismiss(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDwollaUserInfo" {
            
            let destination = segue.destination as! DwollaUserInformationVC
            destination.dwollaTokens = sender as! [String: AnyObject]
        }else if segue.identifier == "toTransactionDetails" {
            
        }else if segue.identifier == "stripeconnect"{
            
            let destination = segue.destination as! StripeConnectionMKWebview
            destination.withDrawAmount = sender as! Double
        }
    }
	
}
