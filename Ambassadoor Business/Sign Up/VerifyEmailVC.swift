//
//  VerifyEmailVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 29/10/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class VerifyEmailVC: BaseVC {
    
    @IBOutlet weak var scroll: UIScrollView!
    
    var emailString: String = ""
    var passwordString: String = ""
    var companyUser: CompanyUser!
    
    var identifySegue = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func verifyEmailAction(sender: UIButton){
        
        
        if identifySegue == "fromSignup"{
            
            self.fromSignUp()
            
        }else{
            self.fromSignIn()
        }
        
    }
    
    func fromSignIn() {
        
        Auth.auth().signIn(withEmail: emailString, password: passwordString) { (user, error) in
            
            if error == nil{
            
            let user = Auth.auth().currentUser!
            
            if user.isEmailVerified {
                
                print("userdefaults set.")
                
                getNewBusiness(email: self.emailString) { (status, business) in
                    if status{
                        MyCompany = business
                        
                        UserDefaults.standard.set(self.emailString, forKey: "userEmail")
                        UserDefaults.standard.set(self.passwordString, forKey: "userPass")
                        UserDefaults.standard.set(MyCompany.businessId, forKey: "userid")
                        
                        self.instantiateToMainScreen()
                        
                    }else{
                        
                    }
                }
                
                    
                }
                
            }else{
                self.showAlertMessage(title: "Alert", message: "You have not verified email yet. Please verify your email") {
                    
                }
            }
            
        }
            
        }

    
    func fromSignUp() {
        
        
        Auth.auth().signIn(withEmail: emailString, password: passwordString) { (user, error) in
            
            if error == nil{
            
            let user = Auth.auth().currentUser!
            
            if user.isEmailVerified{
                
                user.getIDToken(completion: { (token, error) in
                    
                    if error == nil {
                        
                        let coName: String = makeFirebaseUrl( "NewCo" + ", " + GetNewID())
                        let NewBusinessID: String = makeFirebaseUrl(coName + ", " + randomString(length: 15))
                        
                        UserDefaults.standard.set(self.emailString, forKey: "userEmail")
                        UserDefaults.standard.set(self.passwordString, forKey: "userPass")
                        UserDefaults.standard.set(NewBusinessID, forKey: "userid")
                        
                        let finance = ["balance":0.0]
                        
                        
                        
                        let businessObject =  ["businessId":user.uid,"token":token!,"email":user.email!,"refreshToken":user.refreshToken!,"isCompanyRegistered":false, "deviceFIRToken": global.deviceFIRToken, "activeBasicId": NewBusinessID, "finance": finance] as [String : Any]
                        
                       let businessUser = Business.init(dictionary: businessObject, businessId: NewBusinessID)
                        
                        CreateNewCompanyUser(user: businessUser) { (status) in
                            if !status{
                                MyCompany = businessUser
                               self.instantiateToMainScreen()
                            }
                        }
                        
                    }
                    
                })
                
            }else{
                self.showAlertMessage(title: "Alert", message: "You have not verified email yet. Please verify your email") {
                    
                }
            }
        }
            print("You have successfully signed up")
            
        }
        
    }
    
    @IBAction func popToprevious(sender: UIButton){
        
        if let navCon = self.navigationController{
                navCon.popViewController(animated: true)
        }else{
                self.dismiss(animated: true, completion: nil)
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
