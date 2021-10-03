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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.checkIfReferralApplied()
        return true
    }
	
	@IBOutlet weak var codeFoundImage: UIImageView!
	
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
    
    @IBAction func skipAction(sender: UIButton){
        self.performSegue(withIdentifier: "toAddBusinessPresent", sender: self)
    }
    
    override func doneButtonAction() {
        referralText.resignFirstResponder()
        self.checkIfReferralApplied()
    }

	override func viewDidAppear(_ animated: Bool) {
		codeFoundImage.isHidden = true
	}
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textField: self.referralText)
		scrollView.alwaysBounceVertical = false
        // Do any additional setup after loading the view.
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
    }
    
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
