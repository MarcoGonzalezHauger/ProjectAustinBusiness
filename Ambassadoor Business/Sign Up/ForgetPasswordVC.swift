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
    
    var keyboardHeight: CGFloat = 0.00
    var assainedTextField: UITextField? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        if (emailText != nil){
            emailText.resignFirstResponder()
        }
        return true
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

    
    @IBAction func sendEmailAction(sender: UIButton) {
        if emailText.text?.count != 0 {
            
            if Validation.sharedInstance.isValidEmail(emailStr: emailText.text!){
                
                Auth.auth().sendPasswordReset(withEmail: emailText.text!) { (error) in
                    self.emailText.resignFirstResponder()
                    if error == nil {
                        self.showAlertMessage(title: "Alert", message: "we have been sent reset password link to your email address.") {
                            
                            self.navigationController?.popViewController(animated: true)
                            
                        }
                    }else{
                        self.showAlertMessage(title: "Alert", message: (error?.localizedDescription)!) {
                            
                        }
                    }
                    
                }
                
            }else{
                
                self.showAlertMessage(title: "Alert", message: "Please enter the valid email address") {
                    
                }
                
            }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter your email address") {
                
            }
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
