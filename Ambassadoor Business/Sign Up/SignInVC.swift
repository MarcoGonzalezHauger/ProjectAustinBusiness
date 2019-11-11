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

class SignInVC: BaseVC,UITextFieldDelegate {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
	@IBOutlet weak var bioAuthButton: UIButton!
	
    var keyboardHeight: CGFloat = 0.00
    var assainedTextField: UITextField? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()
        print("roundup",(1.056756 * 100).rounded()/100)
		
		registerButton.layer.cornerRadius = 10
		
        // Do any additional setup after loading the view.
		
		if userInfoExists() {
			switch GetBiometricType() {
			case .touch:
				bioAuthButton.setImage(UIImage(named: "touchid"), for: .normal)
			case .face:
				bioAuthButton.setImage(UIImage(named: "faceid"), for: .normal)
			default:
				bioAuthButton.isHidden = true
			}
		} else {
			bioAuthButton.isHidden = true
		}
		
    }
	
	func userInfoExists() -> Bool {
		return UserDefaults.standard.string(forKey: "userEmail") != nil && UserDefaults.standard.string(forKey: "userPass") != nil
	}
	
	enum BiometricType {
		case none
		case touch
		case face
	}
	
	@IBAction func doBioAuth(_ sender: Any) {
		bioAuth()
	}
	
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
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		if textField == emailText && string.contains(" ") {
			return false
		}
		return true
	}
    
    @IBAction func createAccountAction(sender: UIButton){
        DispatchQueue.main.async(execute: {
            
            self.performSegue(withIdentifier: "toSignUp", sender: self)
            
        })
    }
	
	@IBAction func tapped(_ sender: Any) {
		view.endEditing(true)
	}
	
    @objc func timerAction(sender: AnyObject){
        self.showActivityIndicator()
    }
    
	@IBOutlet weak var usernameLine: UILabel!
	@IBOutlet weak var passwordline: UILabel!
	
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

							UserDefaults.standard.set(self.emailText.text, forKey: "userEmail")
							UserDefaults.standard.set(self.passwordText.text, forKey: "userPass")
							print("userdefaults set.")
							
							getCurrentCompanyUser(userID: (Auth.auth().currentUser?.uid)!) { (companyUser, error) in
								if companyUser != nil {
									Singleton.sharedInstance.setCompanyUser(user: companyUser!)
									DispatchQueue.main.async(execute: {
										timer.invalidate()
										self.hideActivityIndicator()
										self.instantiateToMainScreen()
									})
								}
								
							}
                            
                        }else{
                            timer.invalidate()
                            self.hideActivityIndicator()
                            self.signInButton.setTitle("Sign In", for: .normal)
                            print("error=",error!)
							MakeShake(viewToShake: self.signInButton)
							self.passwordline.backgroundColor = .red
							self.usernameLine.backgroundColor = .red
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
	
	@IBAction func forgetPasswordAction(sender: UIButton){
        
        DispatchQueue.main.async(execute: {
            
            self.performSegue(withIdentifier: "toForgetPassword", sender: self)
            
        })
        
    }

}
