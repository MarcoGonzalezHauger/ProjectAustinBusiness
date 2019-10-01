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

class StatsVC: BaseVC {
    
    @IBOutlet weak var pieView: ShadowView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Temporary measure
        
        //self.sentOutReferralCommision(referral: "NJ200919HWE6")
        
        let pieChartView = StaticsPie()
        pieChartView.frame = CGRect(x: 0, y: 0, width: pieView.frame.size.width, height: pieView.frame.size.height)
        pieChartView.segments = [
            OfferStatusSegment(color: .red, value: 57),
            OfferStatusSegment(color: .blue, value: 30),
            OfferStatusSegment(color: .green, value: 25),
            OfferStatusSegment(color: .yellow, value: 40)
        ]
        pieView.addSubview(pieChartView)
        
		
        YourCompany = Company.init(dictionary: ["name": "KRILL GROUP", "logo": "", "mission": "Turn a profit.", "website": "https://www.google.com/", "account_ID": "0", "instagram_name": "marcogonzalezhauger", "description": "No description to see here!", "accountBalance": 1000.0])
		accountBalance = 610.78
//		transactionHistory = [Transaction(description: "Despotied $620.77 into Ambassadoor", details: "Order processed.", time: Date.init(timeIntervalSinceNow: -10000), amount: 620.77),Transaction(description: "You paid $9.99", details: "Processed.", time: Date.init(timeIntervalSinceNow: 0), amount: -9.99)]
        if Singleton.sharedInstance.getCompanyUser().isCompanyRegistered == false {
            self.performSegue(withIdentifier: "toCompanyRegister", sender: self)
        }else{
            
            let user = Singleton.sharedInstance.getCompanyUser().companyID!
            
            getCompany(companyID: user) { (company, error) in
                
                Singleton.sharedInstance.setCompanyDetails(company: company!)
            }
            
        }
            
		
		
	}
    
//    func sentOutReferralCommision(referral: String?) {
//
//        if referral != "" && referral != nil {
//
//          getUserByReferralCode(referralcode: referral!) { (user) in
//
//        }
//
//        }
//
//    }
	
//	override func awakeFromNib() {
//		if Auth.auth().currentUser == nil {
//			debugPrint("User not signed in!")
//			self.performSegue(withIdentifier: "toSignUp", sender: self)
//		}
//	}
}
