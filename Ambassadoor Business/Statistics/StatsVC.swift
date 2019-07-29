//
//  StatsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class StatsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Temporary measure
		
        YourCompany = Company.init(dictionary: ["name": "KRILL GROUP", "logo": "", "mission": "Turn a profit.", "website": "https://www.google.com/", "account_ID": "0", "instagram_name": "marcogonzalezhauger", "description": "No description to see here!", "accountBalance": 1000.0])
		accountBalance = 610.78
		transactionHistory = [Transaction(description: "Despotied $620.77 into Ambassadoor", details: "Order processed.", time: Date.init(timeIntervalSinceNow: -10000), amount: 620.77),Transaction(description: "You paid $9.99", details: "Processed.", time: Date.init(timeIntervalSinceNow: 0), amount: -9.99)]
        if Singleton.sharedInstance.getCompanyUser().isCompanyRegistered == false {
            self.performSegue(withIdentifier: "toCompanyRegister", sender: self)
        }
            
		
		
	}
	
//	override func awakeFromNib() {
//		if Auth.auth().currentUser == nil {
//			debugPrint("User not signed in!")
//			self.performSegue(withIdentifier: "toSignUp", sender: self)
//		}
//	}
}
