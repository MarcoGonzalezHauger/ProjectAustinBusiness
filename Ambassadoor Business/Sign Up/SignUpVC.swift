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

    
    
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		registerButton.layer.cornerRadius = 10
		
		addDoneButtonOnKeyboard(textField: emailText)
		addDoneButtonOnKeyboard(textField: passwordText)
		
    }
	
	@IBAction func nextButtonClicked(_ sender: Any) {
		passwordText.becomeFirstResponder()
	}
	
	@IBAction func joinButtonPressed(_ sender: Any) {
		doneButtonAction()
		CreateAccount()
	}
	
	@IBAction func stopEditing(_ sender: Any) {
		doneButtonAction()
	}
	
	override func doneButtonAction() {
		view.endEditing(true)
	}
    
	@IBAction func Cancelled(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func signinAction(sender: UIButton){
        CreateAccount()
    }
	
	func CreateAccount() {
        
        //self.instantiateToMainScreen()
        
        
		if emailText.text?.count != 0 {
        
        if Validation.sharedInstance.isValidEmail(emailStr: emailText.text!){
            
            if passwordText.text?.count != 0 {
                self.showActivityIndicator()
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (user, error) in
                    self.hideActivityIndicator()
					self.emailText.resignFirstResponder()
					self.passwordText.resignFirstResponder()
					if error == nil {
						let user = Auth.auth().currentUser!
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
						
						print("You have successfully signed up")
						
						
                    }else{
                        
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

}
