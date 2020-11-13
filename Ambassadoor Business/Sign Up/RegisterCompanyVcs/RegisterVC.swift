//
//  RegisterVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class RegisterVC: BaseVC {
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var registerShadow: ShadowView!
    var pageIdentifyIndexDelegate: PageIndexDelegate?
    var dismissDelegate: DismissDelegate?
    
    @IBOutlet weak var termsConditionText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //By pressing "REGISTER" you agree to the terms of service, found at //https://www.ambassadoor.co/terms-of-service
        //Also, you must have permission to use the company name, logo, and website before registering.
        // Do any additional setup after loading the view.
        
        let firstNormalText = "By pressing \"REGISTER\" you agree to the terms of service, found at "
        let attributedString = NSMutableAttributedString(string:firstNormalText)
        
        let linkedText = "https://www.ambassadoor.co/terms-of-service"
        let attrs = [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue", size: 21.0)!,NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue, NSAttributedString.Key.foregroundColor : UIColor.systemBlue] as [NSAttributedString.Key : Any]
        let boldString = NSMutableAttributedString(string: linkedText, attributes:attrs)
        
        let secondNormalText = " Also, you must have permission to use the company name, logo, and website before registering."
        let secondAttribute = NSMutableAttributedString(string:secondNormalText)
        
        attributedString.append(boldString)
        attributedString.append(secondAttribute)
        
        self.termsConditionText.attributedText = attributedString
        
        self.termsConditionText.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openTermsCondition(sender:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        self.termsConditionText.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func openTermsCondition(sender: UITapGestureRecognizer){
        
        if let url = URL(string: "https://www.ambassadoor.co/terms-of-service") {
            UIApplication.shared.open(url)
        }
        
    }
    
    @IBAction func RegisterCompany(sender: UIButton) {
        
        if CanRegisterCompany(alertUser: true) {
            showTutorialVideoOnShow = true
            let companyValue = Company.init(dictionary: ["account_ID":"","name":global.registerCompanyDetails.companyName,"logo":global.registerCompanyDetails.imageUrl,"mission":global.registerCompanyDetails.companyMission,"website":global.registerCompanyDetails.companyWebsite,"owner":global.registerCompanyDetails.referralCode,"description":"","accountBalance":0.0,"referralcode": global.registerCompanyDetails.referralCode])
            CreateCompany(company: companyValue) { (company) in
                let companyUser = Singleton.sharedInstance.getCompanyUser()
                companyUser.companyID = company.account_ID
                Singleton.sharedInstance.setCompanyUser(user: companyUser)
                Singleton.sharedInstance.setCompanyDetails(company: company)
                YourCompany = company
                
                if company.referralcode?.count == 6 {
                    
                    sentReferralAmountToInfluencer(referralID: company.referralcode!) { (user) in
                        
                        let params = ["token":user?.tokenFIR] as [String : AnyObject]
                        NetworkManager.sharedInstance.sendNotificationReferralConvey(params: params)
                        
                    }
                    
                }else if company.referralcode?.count == 7 {
                    
                    sentReferralAmountToBusiness(referralID: company.referralcode!) { (companyUser) in
                        
                        let params = ["token":companyUser!.deviceFIRToken] as [String : AnyObject]
                        NetworkManager.sharedInstance.sendNotificationReferralConvey(params: params)
                        
                    }
                    
                }
                TimerListener.scheduleUpdateBalanceTimer()
                self.dismissDelegate!.dismisRegisterPage()
            }
        } else {
            YouShallNotPass(SaveButtonView: registerShadow)
        }
        
        // self.dismissDelegate!.dismisRegisterPage()
    }
    
    func CanRegisterCompany(alertUser: Bool) -> Bool {
        if !alertUser {
            return global.registerCompanyDetails.imageUrl != ""  && global.registerCompanyDetails.companyName.count != 0 && isGoodUrl(url: global.registerCompanyDetails.companyWebsite) && global.registerCompanyDetails.companyMission.count > 0
        }
        
        if global.registerCompanyDetails.imageUrl != "" {
            if global.registerCompanyDetails.companyName.count > 0 {
                if isGoodUrl(url: global.registerCompanyDetails.companyWebsite) {
                    if global.registerCompanyDetails.companyMission.count != 0 {
                        return true
                    } else {
                        self.showAlertMessage(title: "Alert", message: "Please describe about your company in few lines") {}
                    }
                } else {
                    self.showAlertMessage(title: "Alert", message: "Please enter a valid website") {}
                }
            } else {
                self.showAlertMessage(title: "Alert", message: "Please enter your company name") {}
            }
        } else {
            self.showAlertMessage(title: "Alert", message: "Please add your company logo") {}
        }
        
        return false
    }
    
    @IBAction func backAction(sender: UIButton){
        self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag - 1), viewController: self)
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
