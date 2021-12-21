//
//  SignInVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import LocalAuthentication

class SignInVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var bioAuthButton: UIButton!
    
    var keyboardHeight: CGFloat = 0.00
    var assainedTextField: UITextField? = nil
    
    var emailString = ""
    var passwordString = ""
    var companyUser: CompanyUser!
    
    var stringOne: String? = nil
    
    
    /// UIViewController Life Cycle: Check if user already signed in. If signed in, enable biametric features.
    override func viewDidLoad() {
        super.viewDidLoad()
        print("roundup",(1.056756 * 100).rounded()/100)
        //It is used to identify app went back from app setting Options
        registerButton.layer.cornerRadius = 10
        
        
        
        addDoneButtonOnKeyboard(textField: emailText)
        addDoneButtonOnKeyboard(textField: passwordText)
        
        // Do any additional setup after loading the view.
        
        if userInfoExists() {
            switch GetBiometricType() {
            case .touch:
                bioAuthButton.setImage(UIImage(named: "touchid"), for: .normal)
				bioAuth()
            case .face:
                bioAuthButton.setImage(UIImage(named: "faceid"), for: .normal)
				bioAuth()
            default:
                bioAuthButton.isHidden = true
            }
        } else {
            bioAuthButton.isHidden = true
        }
        
    }
    /// UIViewController Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.signInButton.setTitle("Sign In", for: .normal)
    }
    
    /// resign the first responder of the UITextfield
    override func doneButtonAction() {
        view.endEditing(true)
    }
    
    /// Checks if user already signed in or not
    /// - Returns: returns true or false
    func userInfoExists() -> Bool {
        return UserDefaults.standard.string(forKey: "userEmail") != nil && UserDefaults.standard.string(forKey: "userPass") != nil
    }
    
    /// Group of Biomatric enable options
    enum BiometricType {
        case none
        case touch
        case face
    }
    
    /// If user already signed in, he can login via bio metrics
    /// - Parameter sender: UIButton referrance
    @IBAction func doBioAuth(_ sender: Any) {
        bioAuth()
    }
    
    /// Get biomatric type which one user has enabled
    /// - Returns: return BiometricType
    func GetBiometricType() -> BiometricType {
        let authContext = LAContext()
        if #available(iOS 11, *) {
            let _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch(authContext.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
            }
        } else {
            return authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touch : .none
        }
    }
    
    /// If biometric authentication success, user allow to sign in by stored credentials
    func bioAuth() {
        print("Bio Auth started")
        let lac = LAContext()
        var authError: NSError?
        let reasonString = "Log into Ambassadoor Business"
        if lac.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            print("Can Evaluate.")
            lac.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        if let newEmail = UserDefaults.standard.string(forKey: "userEmail") {
                            if let pass = UserDefaults.standard.string(forKey: "userPass") {
                                self.emailText.text = newEmail
                                self.passwordText.text = pass
                                self.signInAction(sender: self.signInButton)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //UserDefaults.standard.set(name, forKey: "name")
    //let name = NSUserDefaults.standard.string(forKey: "name")
    
    var firstTime = false
    /// UIViewController Life Cycle: Check if user first time entered or not. if user is not first time, allow bioAuth.
    override func viewDidAppear(_ animated: Bool) {
        print("appeared.")
        if firstTime {
            return
        }
        print("checking defaults.")
        if userInfoExists() {
            bioAuth()
        }
        firstTime = true
    }
    
    /// Adjust scroll view as per Keyboard Height if the keyboard hides textfiled.
    /// - Parameter notification: keyboardWillShowNotification reference
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let info : NSDictionary = notification.userInfo! as NSDictionary
        keyboardHeight = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.1, animations: {
            
            if self.assainedTextField != nil {
                let textY = self.assainedTextField!.frame.origin.y + (self.assainedTextField!.frame.size.height)
                
                var conOFFSet:CGFloat = 0.0
                
                
                if textY < self.scroll.frame.size.height {
                    
                    conOFFSet = ((self.scroll.contentSize.height - self.scroll.frame.size.height) - (self.scroll.frame.size.height - textY))
                    
                }else {
                    //                conOFFSet = (self.scroll.contentSize.height - self.scroll.frame.size.height) + self.keyboardHeight
                    conOFFSet = ((self.scroll.contentSize.height - self.scroll.frame.size.height) - (self.scroll.frame.size.height - textY))
                }
                
                
                let keyboardY = self.view.frame.size.height - self.keyboardHeight
                
                
                if textY >= keyboardY {
                    UIView.animate(withDuration: 0.1) {
                        let scrollPoint = CGPoint(x: 0, y: conOFFSet)
                        self.scroll .setContentOffset(scrollPoint, animated: true)
                    }
                    
                }
            }
            
        }) { (value) in
            
        }
        
    }
    
    /// Resign textfield, if it is passwordText textfield, call signInAction.
    /// - Parameter textField: UITextfield referrance
    /// - Returns: returns true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField == emailText {
            passwordText.becomeFirstResponder()
        } else {
            signInAction(sender: signInButton)
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.assainedTextField = textField
    }
    
    /// Disallow spaces in emailText textfield
    /// - Parameters:
    ///   - textField: emailText textfield referrance
    ///   - range: range of the entered text
    ///   - string: entered string
    /// - Returns: returns true or false
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == emailText && string.contains(" ") {
            return false
        }
        return true
    }
    
    /// redirects to create new user page
    /// - Parameter sender: UIButton referrance
    @IBAction func createAccountAction(sender: UIButton){
        DispatchQueue.main.async(execute: {
            
            self.performSegue(withIdentifier: "toSignUp", sender: self)
            
        })
    }
    
    
    /// resign UITextfields
    /// - Parameter sender: UITextfield referrance
    @IBAction func tapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    /// If sign in action takes more than 4 seconds, cancel the sign in action and call again.
    /// - Parameter sender: UItimer referrance
    @objc func timerAction(sender: AnyObject){
        Database.database().reference().cancelDisconnectOperations()
        self.showActivityIndicator()
    }
    
    @IBOutlet weak var usernameLine: UILabel!
    @IBOutlet weak var passwordline: UILabel!
    
    
    
    /// Checks If email and password are valid or not. Sign in through firebase auth. If user exist, get user details. Checks if email verified or not if email is not verified, call send email verification method. Checks if user created any company. If not redirects to create company page. update company details to firebase.
    /// - Parameter sender: UIButton reference
    @IBAction func signInAction(sender: UIButton){
                
        
        if emailText.text?.count != 0 {
            
            if Validation.sharedInstance.isValidEmail(emailStr: emailText.text!){
                
                if passwordText.text?.count != 0 {
                    //self.showActivityIndicator()
                    let timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.timerAction(sender:)), userInfo: nil, repeats: false)
                    signInButton.setTitle("Signing In..", for: .normal)
                    
                    Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
                        self.emailText.resignFirstResponder()
                        self.passwordText.resignFirstResponder()
                        if error == nil {
                            
                            let userVal = Auth.auth().currentUser!
                            
                            self.emailString = self.emailText.text!
                            self.passwordString = self.passwordText.text!
                            
                            if userVal.isEmailVerified {
                                
                                getNewBusiness(email: self.emailText.text!.lowercased()) { (status, business) in
                                    if status{
                                        MyCompany = business
                                        MyCompany.deviceFIRToken = global.deviceFIRToken
                                        MyCompany.UpdateToFirebase { error in
                                            
                                        }
                                        UserDefaults.standard.set(self.emailText.text, forKey: "userEmail")
                                        UserDefaults.standard.set(self.passwordText.text, forKey: "userPass")
                                        UserDefaults.standard.set(MyCompany.businessId, forKey: "userid")
                                        
                                        self.instantiateToMainScreen()
                                        
                                    }else{
                                        self.CreateNewUser()
                                    }
                                }

                                
                            }else{
                                
                                Auth.auth().currentUser?.sendEmailVerification { (error) in
                                    
                                    if error == nil{
                                        DispatchQueue.main.async {
                                            
                                            self.performSegue(withIdentifier: "fromSignin", sender: self)
                                            
                                        }
                                    }else{
                                        self.signInButton.setTitle("Sign In", for: .normal)
                                        self.showAlertMessage(title: "Alert", message: (error?.localizedDescription)!) {
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }else{
                            
                            timer.invalidate()
                            self.hideActivityIndicator()
                            self.signInButton.setTitle("Sign In", for: .normal)
                            print("error=",error!)
                            MakeShake(viewToShake: self.signInButton)
                            
                            let err = error! as NSError
                            print(err.domain)
                            
                            if err.code == 17011{
                                
                                self.usernameLine.backgroundColor = .red
                                self.passwordline.backgroundColor = .red
                                
                                self.showAlertMessage(title: "Alert", message: "No user found. The user may have been deleted") {
                                    
                                }
                                
                            }else if err.code == 17020{
                                self.showAlertMessage(title: "Alert", message: "The Internet connection appears to be offline") {
                                    
                                }
                            }else if err.code == 17009{
                                self.usernameLine.backgroundColor = UIColor(named: "AmbPurple")
                                self.passwordline.backgroundColor = .red
                                
                                self.showAlertMessage(title: "Alert", message: "password is incorrect") {
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    
                    
                } else {
                    MakeShake(viewToShake: signInButton)
                    passwordline.backgroundColor = .red
                    
                }
            } else {
                MakeShake(viewToShake: signInButton)
                usernameLine.backgroundColor = .red
            }
        } else {
            MakeShake(viewToShake: signInButton)
            usernameLine.backgroundColor = .red
        }
        
    }
    
    /// Create one unique Id by makeFirebaseUrl and 15 randam string. Using Unique ID, create new business user in Firebase.
    func CreateNewUser() {
        
        let user = Auth.auth().currentUser!
        user.getIDToken(completion: { (token, error) in
            
            if error == nil {
                
                let coName: String = makeFirebaseUrl( "NewCo" + ", " + GetNewID())
                let NewBusinessID: String = makeFirebaseUrl(coName + ", " + randomString(length: 15))
                
                UserDefaults.standard.set(self.emailString, forKey: "userEmail")
                UserDefaults.standard.set(self.passwordString, forKey: "userPass")
                UserDefaults.standard.set(NewBusinessID, forKey: "userid")
                
                let finance = ["balance":0.0]
                
                let businessObject =  ["businessId":NewBusinessID,"token":token!,"email":user.email!,"refreshToken":user.refreshToken!,"isCompanyRegistered":false, "deviceFIRToken": global.deviceFIRToken, "activeBasicId": NewBusinessID, "finance": finance] as [String : Any]
                
               let businessUser = Business.init(dictionary: businessObject, businessId: NewBusinessID)
                
                CreateNewCompanyUser(user: businessUser) { (status) in
                    if !status{
                        MyCompany = businessUser
                       self.instantiateToMainScreen()
                    }
                }
                
            }
            
        })

    }
    
    func updateCompanyUserData(timer: Timer) {
        
        let user = Auth.auth().currentUser!
        user.getIDToken(completion: { (token, error) in
            
            var tokenVal = ""
            
            if error == nil {
                if token != nil{
                    tokenVal = token!
                }
            }
            
            UserDefaults.standard.set(self.emailString, forKey: "userEmail")
            UserDefaults.standard.set(self.passwordString, forKey: "userPass")
            UserDefaults.standard.set(user.uid, forKey: "userid")
            
            let referralCode = randomString(length: 7)
            
            self.companyUser = CompanyUser.init(dictionary: ["userID":user.uid,"token":tokenVal,"email":user.email!,"refreshToken":user.refreshToken!,"isCompanyRegistered":false,"companyID": "", "deviceFIRToken": global.deviceFIRToken, "businessReferral": referralCode])
            
            let userDetails = CreateCompanyUser(companyUser: self.companyUser)
            Singleton.sharedInstance.setCompanyUser(user: userDetails)
            DispatchQueue.main.async(execute: {
                timer.invalidate()
                self.hideActivityIndicator()
                self.instantiateToMainScreen()
            })
            
            
        })
        
    }
    
    @IBAction func forgetPasswordAction(sender: UIButton){
        
        DispatchQueue.main.async(execute: {
            
            self.performSegue(withIdentifier: "toForgetPassword", sender: self)
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromSignin" {
            let view = segue.destination as! VerifyEmailVC
            view.emailString = self.emailString
            view.passwordString = self.passwordString
            view.identifySegue = "fromSignin"
        }
    }
    
}
