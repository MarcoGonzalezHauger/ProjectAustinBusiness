//
//  ReferralViewController.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 03/09/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ReferralViewController: BaseVC, UITextFieldDelegate {
    
    var basicBusiness: BasicBusiness? = nil
    
    var isProfileSegue = false
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var referralText: UITextField!
    @IBOutlet weak var referralShadow: ShadowView!
    
    
    /// Resign referralText textfield
    /// - Parameter textField: UITextField referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.checkIfReferralApplied()
        return true
    }
	
	@IBOutlet weak var codeFoundImage: UIImageView!
	
    
    /// Checks if referralText is not empty. Checks if referral code is available or not. if available, add referred user Id to Business user's  referredByUserId or referredByBusinessId. Update business user changes to Firebase.
    func checkIfReferralApplied() {
        
        if self.referralText.text?.count == 0 {
            //MakeShake(viewToShake: self.referralShadow)
            return
        }
        
        let referralByUser = InfluencerDatabase.filter { $0.basic.referralCode.lowercased() == self.referralText.text!.lowercased()}
        let referralByBusiness = globalBasicBusinesses.filter { $0.referralCode.lowercased() == self.referralText.text!.lowercased()
        }
        
        if referralByUser.count == 0 && referralByBusiness.count == 0 {
            MakeShake(viewToShake: self.referralShadow)
            return
        }
        
        MyCompany.referredByUserId = referralByUser.count != 0 ? referralByUser.first!.userId : ""
        MyCompany.referredByBusinessId = referralByBusiness.count != 0 ? referralByBusiness.first!.businessId : ""
		
		codeFoundImage.isHidden = false
		
        MyCompany.UpdateToFirebase { error in
            if !error{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toAddBusinessPresent", sender: self)
                }
                
            }
        }
        
    }
    
    /// Clicks if noone referred the user. it redirects to Create Company Page
    /// - Parameter sender: UIButton reference
    @IBAction func skipAction(sender: UIButton){
        self.performSegue(withIdentifier: "toAddBusinessPresent", sender: self)
    }
    
    /// Override Custom Done Button Action of UITextfield
    override func doneButtonAction() {
        referralText.resignFirstResponder()
        self.checkIfReferralApplied()
    }
    /// UIViewController Life Cycle
	override func viewDidAppear(_ animated: Bool) {
		codeFoundImage.isHidden = true
	}
	
	@IBOutlet weak var scrollView: UIScrollView!
    /// UIViewController Life Cycle
	override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textField: self.referralText)
		scrollView.alwaysBounceVertical = false
        // Do any additional setup after loading the view.
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
    }
    /// send isProfileSegue and basicBusiness tag to Create Business Page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddBusinessPresent" {
            let view = segue.destination as! AddBasicBusinessVC
            view.isProfileSegue = self.isProfileSegue
            view.basicBusiness = self.basicBusiness
        }
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
