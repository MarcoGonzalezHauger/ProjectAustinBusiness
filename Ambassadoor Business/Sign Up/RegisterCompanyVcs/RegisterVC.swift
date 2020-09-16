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
    var dismissDelegate: DismissDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
