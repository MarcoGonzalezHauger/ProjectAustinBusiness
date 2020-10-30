//
//  RegisterCompanyVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 24/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Photos

var showTutorialVideoOnShow = false

protocol RegisterCompanySegmentDelegate {
    func registerStepSegmentIndex(index: Int)
}

protocol DismissDelegate {
    func dismisRegisterPage()
}

protocol DebugDelegate {
    func somethingMissing()
}

class RegisterCompanyVC: BaseVC, ImagePickerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, PageViewDelegate, DismissDelegate {
    func pageViewIndexDidChangedelegate(index: Int) {
        self.stepSegmentControl.selectedSegmentIndex = index
    }
    
    func dismisRegisterPage(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var picLogo: UIButton!
    @IBOutlet weak var registerButton: UIButton!
	@IBOutlet weak var registerButtonView: ShadowView!
	
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var companyEmail: UITextField!
    @IBOutlet weak var companySite: UITextField!
    @IBOutlet weak var missionTextView: UITextView!
    
    @IBOutlet weak var stepSegmentControl: UISegmentedControl!
    
    var urlString = ""
    var assainedTextField: AnyObject? = nil
    var registerCompanyPVCDelegate: RegisterCompanySegmentDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scroll.delegate = self
		self.picLogo.layer.cornerRadius = 75
        // Do any additional setup after loading the view.
        self.addDoneButtonOnKeyboard(textView: missionTextView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
//        print("contentOFset",scrollView.contentOffset.y)
//        let ok = scrollView.contentSize.height - scrollView.frame.size.height
//        print("contentOFset1",scrollView.contentSize.height)
//        print("contentOFset2",ok)
    }
    
    @IBAction func logoControlAction(sender: UIButton){
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
           DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toGetPictureVC", sender: self)
            }
            debugPrint("It is not determined until now")
        case .restricted:
            self.showNotificationForAuthorization()
        case .denied:
            self.showNotificationForAuthorization()
        default:
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toGetPictureVC", sender: self)
            }
        }
        
        //self.performSegue(withIdentifier: "toGetPictureVC", sender: self)
    }
    
    func showNotificationForAuthorization() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    openAppSettings(index: 0)
                } else {
                    openAppSettings(index: 0)
                    self.photoLibrarySettingsNotification()
                }
            }
        }
        
    }
    
    func photoLibrarySettingsNotification() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = "Ambassadoor Settings"
        content.body = "You must enable Photo Access to upload a logo. Allow access here."
        content.sound = nil
        content.badge = nil
        
    
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        let identifier = "photolibrarysettings"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
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
        
        self.missionTextView.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? GetPictureVC {
            destination.delegate = self
        }else if segue.identifier == "PageView"{
            let view = segue.destination as! RegisterCompanyPVC
            view.pageViewDidChange = self
            //view.parentReference = self
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
			let companyValue = Company.init(dictionary: ["account_ID":"","name":self.companyName.text!,"logo":self.urlString,"mission":self.missionTextView.text,"website":self.companySite.text!,"owner":self.companyEmail.text!,"description":"","accountBalance":0.0,"referralcode": self.companyEmail.text!])
			CreateCompany(company: companyValue) { (company) in
				let companyUser = Singleton.sharedInstance.getCompanyUser()
				companyUser.companyID = company.account_ID
				Singleton.sharedInstance.setCompanyUser(user: companyUser)
				Singleton.sharedInstance.setCompanyDetails(company: company)
                YourCompany = company
                
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
                TimerListener.scheduleUpdateBalanceTimer()
				self.dismiss(animated: true, completion: nil)
			}
		} else {
			YouShallNotPass(SaveButtonView: registerButtonView)
		}
	}
	
	func CanRegisterCompany(alertUser: Bool) -> Bool {
		if !alertUser {
			return self.urlString != ""  && self.companyName.text?.count != 0 && isGoodUrl(url: self.companySite.text ?? "") && self.missionTextView.text.count > 0
		}
		
		if self.urlString != "" {
			if self.companyName.text?.count ?? 0 > 0 {
				if isGoodUrl(url: self.companySite.text ?? "") {
					if self.missionTextView.text.count != 0 {
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