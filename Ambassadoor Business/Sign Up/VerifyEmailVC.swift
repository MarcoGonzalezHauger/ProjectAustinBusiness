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
            
            if user.isEmailVerified{
                
                UserDefaults.standard.set(self.emailString, forKey: "userEmail")
                UserDefaults.standard.set(self.passwordString, forKey: "userPass")
                UserDefaults.standard.set((Auth.auth().currentUser?.uid)!, forKey: "userid")
                print("userdefaults set.")
                
                getCurrentCompanyUser(userID: (Auth.auth().currentUser?.uid)!) { (companyUser, error) in
                    if companyUser != nil {
                        Singleton.sharedInstance.setCompanyUser(user: companyUser!)
                        
                        
                        if let isRegistered =  Singleton.sharedInstance.getCompanyUser().isCompanyRegistered{
                            
                            if isRegistered{
                                
                                let user = Singleton.sharedInstance.getCompanyUser().companyID!
                                
                                getCompany(companyID: user) { (company, error) in
                                    
                                    Singleton.sharedInstance.setCompanyDetails(company: company!)
                                    YourCompany = company
                                    TimerListener.scheduleUpdateBalanceTimer()
                                    downloadBeforeLoad()
                                    
                                    getAllDistributedOffers { (status, results) in
                                        if status {
                                            if let results = results {
                                                if results.count == 0 {
                                                } else {
                                                    
                                                    var rslts: [OfferStatistic] = []
                                                    for i in results {
                                                        rslts.append(OfferStatistic.init(offer: i))
                                                    }
                                                    global.distributedOffers = rslts
                                                    
                                                }
                                            }
                                            
                                            DispatchQueue.main.async(execute: {
                                                self.instantiateToMainScreen()
                                            })
                                            
                                        }else{
                                            DispatchQueue.main.async(execute: {
                                                self.instantiateToMainScreen()
                                            })
                                        }
                                    }
                                
                                }
                                
                            }else{
                                DispatchQueue.main.async(execute: {
                                    
                                    self.instantiateToMainScreen()
                                })
                            }
                        }else{
                            DispatchQueue.main.async(execute: {
                                self.instantiateToMainScreen()
                            })
                        }
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.instantiateToMainScreen()
                        })
                    }
                    
                }
                
            }else{
                self.showAlertMessage(title: "Alert", message: "You have not verified email yet. Please verify your email") {
                    
                }
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
                        
                        UserDefaults.standard.set(self.emailString, forKey: "userEmail")
                        UserDefaults.standard.set(self.passwordString, forKey: "userPass")
                        UserDefaults.standard.set(user.uid, forKey: "userid")
                        
                        let referralCode = randomString(length: 7)
                        
                        self.companyUser = CompanyUser.init(dictionary: ["userID":user.uid,"token":token!,"email":user.email!,"refreshToken":user.refreshToken!,"isCompanyRegistered":false,"companyID": "", "deviceFIRToken": global.deviceFIRToken, "businessReferral": referralCode])
                        
                        let userDetails = CreateCompanyUser(companyUser: self.companyUser)
                        Singleton.sharedInstance.setCompanyUser(user: userDetails)
                        self.instantiateToMainScreen()
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
        self.navigationController?.popViewController(animated: true)
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
