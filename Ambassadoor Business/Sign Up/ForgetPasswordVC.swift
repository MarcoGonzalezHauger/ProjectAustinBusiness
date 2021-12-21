//
//  ForgetPasswordVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgetPasswordVC: BaseVC,UITextFieldDelegate {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
	@IBOutlet weak var sendEmailButton: UIButton!
	@IBOutlet weak var line: UILabel!
	
    var keyboardHeight: CGFloat = 0.00
    var assainedTextField: UITextField? = nil

    /// UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
		addDoneButtonOnKeyboard(textField: emailText)
		sendEmailButton.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    /// resign the first responder of the UITextfield
	override func doneButtonAction() {
		emailText.resignFirstResponder()
	}
    
    /// Dismiss view controller
    /// - Parameter sender: UIButton referrance
    @IBAction func Cancelled(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
    
    /// resign email field
    /// - Parameter textField: textField param
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
		emailText.resignFirstResponder()
        return true
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

    
    /// Check if entered email is valid or not. Call firebase reset method it sends password reset link to registered email address.
    /// - Parameter sender: UIButton referrence
    @IBAction func sendEmailAction(sender: UIButton) {
        if emailText.text?.count != 0 {
            
            if Validation.sharedInstance.isValidEmail(emailStr: emailText.text!){
                
                Auth.auth().sendPasswordReset(withEmail: emailText.text!) { (error) in
                    self.emailText.resignFirstResponder()
                    if error == nil {
						self.sendEmailButton.setTitle("Sent", for: .normal)
                        self.showAlertMessage(title: "Sent", message: "The reset link has been sent to your email.") {
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    }else{
                        self.showAlertMessage(title: "Alert", message: (error?.localizedDescription)!) {
                            
                        }
                    }
                    
                }
                
            }else{
                //invalid email
				
				MakeShake(viewToShake: sendEmailButton)
				line.backgroundColor = .red
                
            }
            
        }else{
            
			MakeShake(viewToShake: sendEmailButton)
			line.backgroundColor = .red
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
