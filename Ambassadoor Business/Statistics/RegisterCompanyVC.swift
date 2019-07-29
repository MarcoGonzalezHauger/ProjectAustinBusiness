//
//  RegisterCompanyVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 24/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterCompanyVC: BaseVC,ImagePickerDelegate,UITextFieldDelegate,UITextViewDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var picLogo: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var companyEmail: UITextField!
    @IBOutlet weak var companySite: UITextField!
    @IBOutlet weak var companyDescription: UITextView!
    @IBOutlet weak var companyMission: UITextField!
    
    var urlString = ""
    var keyboardHeight: CGFloat = 0.00
    var assainedTextField: AnyObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scroll.delegate = self
        // Do any additional setup after loading the view.
        self.addDoneButtonOnKeyboard(textView: companyDescription)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        print("contentOFset",scrollView.contentOffset.y)
        let ok = scrollView.contentSize.height - scrollView.frame.size.height
        print("contentOFset1",scrollView.contentSize.height)
        print("contentOFset2",ok)
    }
    
    @IBAction func logoControlAction(sender: UIButton){
        self.performSegue(withIdentifier: "toGetPictureVC", sender: self)
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePicked(image: UIImage?, imageUrl: String?) {
        if image != nil {
        self.picLogo.setTitle("", for: .normal)
        self.picLogo.setBackgroundImage(image, for: .normal)
        self.showActivityIndicator()
//        self.urlString = uploadImageToFIR(image: image!, path: (Auth.auth().currentUser?.uid)!)
            uploadImageToFIR(image: image!, path: (Auth.auth().currentUser?.uid)!) { (url, error) in
                self.hideActivityIndicator()
                if error == false{
                self.urlString = url
                print("URL=",url)
                }else{
                self.urlString = ""
                }
            }
        
        }
        
    }
    
    // MARK: -Override Action
    
    override func doneButtonAction(){
        
        self.companyDescription.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? GetPictureVC {
            destination.delegate = self
        }
    }
    
    // MARK: -Text Field Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let info : NSDictionary = notification.userInfo! as NSDictionary
        keyboardHeight = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.1, animations: {

            if let _ = self.assainedTextField as? UITextField {
            let textY = self.assainedTextField!.frame.origin.y + (self.assainedTextField!.frame?.size.height)!
                
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.1) {
            let scrollPoint = CGPoint(x: 0, y: 0)
            self.scroll .setContentOffset(scrollPoint, animated: true)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        let textY = textView.superview!.frame.origin.y + (textView.superview!.frame.size.height)
        
        var conOFFSet:CGFloat = 0.0
        
        
        if textY < self.scroll.frame.size.height {
            
            conOFFSet = ((self.scroll.contentSize.height - self.scroll.frame.size.height) - (self.scroll.bounds.size.height - textY))
            
        }else {
            //                conOFFSet = (self.scroll.contentSize.height - self.scroll.frame.size.height) + self.keyboardHeight
            conOFFSet = ((self.scroll.contentSize.height - self.scroll.frame.size.height) - (self.scroll.bounds.size.height - textY))
        }
        
        
        let keyboardY = self.view.frame.size.height - self.keyboardHeight
        
        
        if textY >= keyboardY {
            UIView.animate(withDuration: 0.1) {
                let scrollPoint = CGPoint(x: 0, y: conOFFSet)
                self.scroll .setContentOffset(scrollPoint, animated: true)
            }
            
        }
            
        
    }
    
    @IBAction func registerAction(sender: UIButton){
        if self.urlString != ""{
            
           if self.companyName.text?.count != 0 {
            
            if self.companyEmail.text?.count != 0 {
                
                if Validation.sharedInstance.isValidEmail(emailStr: self.companyEmail.text!){
                    
                    if self.companySite.text?.count != 0 {
                        
                        if (URL.init(string: self.companySite.text!) != nil){
                            
                            if self.companyDescription.text.count != 0 {
                                
                                let companyValue = Company.init(dictionary: ["account_ID":"","name":self.companyName.text!,"logo":self.urlString,"mission":self.companyMission.text!,"website":self.companySite.text!,"owner":self.companyEmail.text!,"description":self.companyDescription.text!,"accountBalance":0.0])
                                
                                
                                CreateCompany(company: companyValue) { (company) in
                                    
                                    self.dismiss(animated: true, completion: nil)
                                    
                                }
                                
                            }else {
                                
                                self.showAlertMessage(title: "Alert", message: "Please describe about your company in few lines") {
                                    
                                }
                                
                            }
                            
                        }else{
                            
                            self.showAlertMessage(title: "Alert", message: "Please enter valid website") {
                                
                            }
                            
                        }
                        
                    }else {
                        self.showAlertMessage(title: "Alert", message: "Please enter your company site") {
                            
                        }
                    }
                    
                }else {
                    self.showAlertMessage(title: "Alert", message: "Please enter valid email address") {
                        
                    }
                }
                
            }else {
                
                self.showAlertMessage(title: "Alert", message: "Please enter your company email address") {
                    
                }
                
            }
                
           }else{
            
            self.showAlertMessage(title: "Alert", message: "Please enter your company name") {
                
            }
            
            }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please add your company logo") {
                
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
