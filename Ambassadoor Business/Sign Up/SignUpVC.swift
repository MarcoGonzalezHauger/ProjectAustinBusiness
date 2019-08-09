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



class SignUpVC: BaseVC,UITextFieldDelegate {

	@IBOutlet weak var registerButton: UIButton!
	@IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    var keyboardHeight: CGFloat = 0.00
    var companyUser: CompanyUser!
    
    var assainedTextField: UITextField? = nil
    
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
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
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.assainedTextField = textField
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{

        textField.resignFirstResponder()

        return true
    }
    
    @IBAction func signinAction(sender: UIButton){
        
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
                                self.companyUser = CompanyUser.init(dictionary: ["userID":user.uid,"token":token!,"email":user.email!,"refreshToken":user.refreshToken!,"isCompanyRegistered":false,"companyID": ""])
                            
                            let userDetails = CreateCompanyUser(companyUser: self.companyUser)
                            Singleton.sharedInstance.setCompanyUser(user: userDetails)
                            self.instantiateToMainScreen()
                            }
                            
                        })
                        
                        print("You have successfully signed up")
                        
                        
                    }else{
                        
                        print("error",error?.localizedDescription)
                        self.showAlertMessage(title: "Alert", message: (error?.localizedDescription)!) {
                            
                        }
                        
                    }
                    
                }
                
            }else{
                
                self.showAlertMessage(title: "Alert", message: "Please enter your password") {
                    
                }
                
            }
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter the valid email") {
                
            }
        }
        }else {
            
            self.showAlertMessage(title: "Alert", message: "Please enter your email address") {
                
            }
            
        }
        
    }

}
