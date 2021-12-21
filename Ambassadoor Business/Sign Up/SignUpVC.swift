//
//  SignUpVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/3/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class signupbutton: UIButton {
	override func awakeFromNib() {
		self.layer.cornerRadius = 10
		self.layer.borderWidth = 2
		self.layer.borderColor = UIColor.gray.cgColor
	}
}



class SignUpVC: BaseVC, UITextFieldDelegate {

	@IBOutlet weak var passwordLine: UILabel!
	@IBOutlet weak var usernameLine: UILabel!
	@IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    var keyboardHeight: CGFloat = 0.00
    var companyUser: CompanyUser!
    
    var assainedTextField: UITextField? = nil
    
    var emailString: String = ""
    var passwordString: String = ""

    
    /// UIViewController Life Cycle
	override func viewDidLoad() {
        super.viewDidLoad()
		
		registerButton.layer.cornerRadius = 10
		
		addDoneButtonOnKeyboard(textField: emailText)
		addDoneButtonOnKeyboard(textField: passwordText)
		
    }
    
    /// UIViewController Life Cycle
    /// - Parameter animated: Default Param
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.registerButton.isUserInteractionEnabled = true
    }
    
    /// It is Action Event of emailText(TextField) and Connected this action event to emailText Primary Action. This action triggered when textfield return or done. Purpose of this action is to make passwordText become first responder.
    /// - Parameter sender: Uitextfiled reference
	@IBAction func nextButtonClicked(_ sender: Any) {
		passwordText.becomeFirstResponder()
	}
    
    /// Force resign the first responder and Create account function called
    /// - Parameter sender: UITextfield reference
	@IBAction func joinButtonPressed(_ sender: Any) {
		doneButtonAction()
		CreateAccount()
	}
    
	@IBAction func stopEditing(_ sender: Any) {
		doneButtonAction()
	}
    
    /// resign the first responder of the UITextfield
	override func doneButtonAction() {
		view.endEditing(true)
	}
    
    /// Dismiss current UIViewcontroller
    /// - Parameter sender: UIButton referrance
	@IBAction func Cancelled(_ sender: Any) {
		//self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
                    
                } else {
                    //conOFFSet = (self.scroll.contentSize.height - self.scroll.frame.size.height) + self.keyboardHeight
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
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.assainedTextField = textField
        
    }
    
    
    /// Called if user clicks registerButton and it calls CreateAccount method
    /// - Parameter sender: UIButton reference
    @IBAction func signinAction(sender: UIButton){
        CreateAccount()
    }
	
    
    /// Checks if user entered valid email and password. Checks if user is new one. Create a new business user and send email verification to verify the email. if all done without any error, it redirects to email verification controller
	func CreateAccount() {
        
        //self.instantiateToMainScreen()
        
        
		if emailText.text?.count != 0 {
        
        if Validation.sharedInstance.isValidEmail(emailStr: emailText.text!){
            
            if passwordText.text?.count != 0 {
                self.showActivityIndicator()
                self.registerButton.isUserInteractionEnabled = false
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
                    self.hideActivityIndicator()
					self.emailText.resignFirstResponder()
					self.passwordText.resignFirstResponder()
                    
                    self.emailString = self.emailText.text!
                    self.passwordString = self.passwordText.text!
                    
					if error == nil {
						//let user = Auth.auth().currentUser!
                        
                        Auth.auth().currentUser?.sendEmailVerification { (error) in
                            self.registerButton.isUserInteractionEnabled = true
                            if error == nil{
                                DispatchQueue.main.async {
                                
                                self.performSegue(withIdentifier: "fromSignup", sender: self)
                                    
                                }
                            }else{
                                
                                self.showAlertMessage(title: "Alert", message: (error?.localizedDescription)!) {
                                    
                                }
                                
                            }
                          
                        }
                        
                        /*
						user.getIDToken(completion: { (token, error) in
							
							if error == nil {

								UserDefaults.standard.set(self.emailText.text, forKey: "userEmail")
								UserDefaults.standard.set(self.passwordText.text, forKey: "userPass")
                                UserDefaults.standard.set(user.uid, forKey: "userid")
                                
                                let referralCode = randomString(length: 7)
								
                                self.companyUser = CompanyUser.init(dictionary: ["userID":user.uid,"token":token!,"email":user.email!,"refreshToken":user.refreshToken!,"isCompanyRegistered":false,"companyID": "", "deviceFIRToken": global.deviceFIRToken, "businessReferral": referralCode])
								
								let userDetails = CreateCompanyUser(companyUser: self.companyUser)
								Singleton.sharedInstance.setCompanyUser(user: userDetails)
								self.instantiateToMainScreen()
							}
							
						})
						*/
						print("You have successfully signed up")
						
						
                    }else{
                        self.registerButton.isUserInteractionEnabled = true
						print("SIGN UP error")
                        self.showAlertMessage(title: "Alert", message: (error?.localizedDescription)!) {
                            
                        }
                        
                    }
                    
                }
                
            }else{
				
				//no password
                
				passwordLine.backgroundColor = .red
                
            }
        }else{
			
			//invalid email
			
			MakeShake(viewToShake: emailText)
			usernameLine.backgroundColor = .red
        }
        } else {
			
			//no username
			
			usernameLine.backgroundColor = .red
        }
        
        
	}
    
    /// Pass email, password and identifySegue to email verification controller
    /// - Parameters:
    ///   - segue: Current segue of the UIViewcontroller
    ///   - sender: Optional Any
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromSignup" {
            let view = segue.destination as! VerifyEmailVC
            view.emailString = self.emailString
            view.passwordString = self.passwordString
            view.identifySegue = "fromSignup"
        }
    }

}
