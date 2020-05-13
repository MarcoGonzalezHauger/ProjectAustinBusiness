//
//  RegisterCompanyVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 24/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

var showTutorialVideoOnShow = false

class RegisterCompanyVC: BaseVC, ImagePickerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var picLogo: UIButton!
    @IBOutlet weak var registerButton: UIButton!
	@IBOutlet weak var registerButtonView: ShadowView!
	
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var companyEmail: UITextField!
    @IBOutlet weak var companySite: UITextField!
    @IBOutlet weak var companyDescription: UITextView!
    @IBOutlet weak var companyMission: UITextField!
    
    var urlString = ""
    var assainedTextField: AnyObject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scroll.delegate = self
        // Do any additional setup after loading the view.
        self.addDoneButtonOnKeyboard(textView: companyDescription)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
//        print("contentOFset",scrollView.contentOffset.y)
//        let ok = scrollView.contentSize.height - scrollView.frame.size.height
//        print("contentOFset1",scrollView.contentSize.height)
//        print("contentOFset2",ok)
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
            uploadImageToFIR(image: image!,childName: "companylogo", path: (Auth.auth().currentUser?.uid)!) { (url, error) in
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
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scroll.contentInset = contentInset
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    
        
        UIView.animate(withDuration: 0.1) {
            let scrollPoint = CGPoint(x: 0, y: textView.superview!.frame.origin.y)
            self.scroll .setContentOffset(scrollPoint, animated: true)
        }
        
    }
    
	func RegisterCompany() {
		if CanRegisterCompany(alertUser: true) {
			showTutorialVideoOnShow = true
			let companyValue = Company.init(dictionary: ["account_ID":"","name":self.companyName.text!,"logo":self.urlString,"mission":self.companyMission.text!,"website":self.companySite.text!,"owner":self.companyEmail.text!,"description":self.companyDescription.text!,"accountBalance":0.0,"referralcode": self.companyEmail.text!])
			CreateCompany(company: companyValue) { (company) in
				let companyUser = Singleton.sharedInstance.getCompanyUser()
				companyUser.companyID = company.account_ID
				Singleton.sharedInstance.setCompanyUser(user: companyUser)
				Singleton.sharedInstance.setCompanyDetails(company: company)
                
                if company.referralcode?.count == 6 {
                    
                    sentReferralAmountToInfluencer(referralID: company.referralcode!) { (user) in
                        
                        let params = ["token":user?.tokenFIR] as [String : AnyObject]
                        NetworkManager.sharedInstance.sendNotificationReferralConvey(params: params)
                        
                    }
                    
                }else if company.referralcode?.count == 7 {
                    
                    sentReferralAmountToBusiness(referralID: company.referralcode!) { (companyUser) in
                        
                        let params = ["token":companyUser!.deviceFIRToken] as [String : AnyObject]
                        NetworkManager.sharedInstance.sendNotificationReferralConvey(params: params)
                        
                    }
                    
                }
                
				self.dismiss(animated: true, completion: nil)
			}
		} else {
			YouShallNotPass(SaveButtonView: registerButtonView)
		}
	}
	
	func CanRegisterCompany(alertUser: Bool) -> Bool {
		if !alertUser {
			return self.urlString != ""  && self.companyName.text?.count != 0 && isGoodUrl(url: self.companySite.text ?? "") && self.companyDescription.text.count > 0
		}
		
		if self.urlString != "" {
			if self.companyName.text?.count ?? 0 > 0 {
				if isGoodUrl(url: self.companySite.text ?? "") {
					if self.companyDescription.text.count != 0 {
						return true
					} else {
						self.showAlertMessage(title: "Alert", message: "Please describe about your company in few lines") {}
					}
				} else {
					self.showAlertMessage(title: "Alert", message: "Please enter a valid website") {}
				}
			} else {
				self.showAlertMessage(title: "Alert", message: "Please enter your company name") {}
			}
		} else {
			self.showAlertMessage(title: "Alert", message: "Please add your company logo") {}
		}
		
		return false
	}
	
    @IBAction func registerAction(sender: UIButton){
        RegisterCompany()
    }

}
