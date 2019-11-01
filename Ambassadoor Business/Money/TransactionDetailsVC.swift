//
//  TransactionDetailsVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 14/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TransactionDetailsVC: BaseVC {
    
    var transactionObject:TransactionInfo?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var transactionID: UILabel!
    @IBOutlet weak var acctID: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var status: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
//yyyy-MM-dd'T'HH:mm:ssZ
        // Do any additional setup after loading the view.
        self.getTransactionDetails()
        
    }
    
    func getTransactionDetails() {
        
        
        let params = ["grant_type=":"client_credentials"] as [String: AnyObject]
        NetworkManager.sharedInstance.getDwollaAccessToken(params: params) { (status, error, data) in
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            print("dataString=",dataString)
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                
                let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                
                if let accessToken = json!["access_token"] as? String {
                    
                    NetworkManager.sharedInstance.getTransactionDetails(accessToken: accessToken, url: self.transactionObject!.transactionURL) { (status, error, data, response) in
                        
                        do {
                            let jsonTransaction = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                            
                            
                            if let idVal = jsonTransaction!["id"] as? String {
                                
                                if let statusVal = jsonTransaction!["status"] as? String {
                                    
                                    if let amountDict = jsonTransaction!["amount"] as? NSDictionary {
                                        //  created
                                        if let createdString = jsonTransaction!["created"] as? String {
                                            DispatchQueue.main.async {
                                                self.transactionID.text = idVal
                                                self.status.text = statusVal
                                                self.amountText.text = amountDict["value"] as! String + " " + (amountDict["currency"] as! String)
                                                self.dateText.text = DateFormatManager.sharedInstance.getDateFromString(dateString: createdString)
                                                self.name.text = self.transactionObject!.firstName + " " + self.transactionObject!.lastName
                                                self.acctID.text = "****" + self.transactionObject!.mask
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        
                    }catch _ {
                        
                    }
                        
                    }
                    
                }
                
            }catch _ {
                
            }
        }

        
        
    }
    
    @IBAction func dismissAction(sender: UIButton){
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
