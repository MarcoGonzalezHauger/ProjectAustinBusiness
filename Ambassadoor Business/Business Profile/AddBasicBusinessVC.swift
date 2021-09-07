//
//  AddBasicBusinessVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Photos

protocol LocationretriveDelegate {
    func sendLocationObjects(locations: [String])
}

class AddBasicBusinessVC: BaseVC, ImagePickerDelegate, UITextFieldDelegate, UITextViewDelegate, TypePickerDelegate, LocationretriveDelegate, NCDelegate {
	
	func shouldAllowBack() -> Bool {
		saveBasicBusiness()
		return true
	}
	
    func sendLocationObjects(locations: [String]) {
        self.locations = locations
        if self.locations.count == 0 {
            self.locationText.text = "No Location"
        }else{
            self.locationText.text = self.locations.count == 1 ? "\(self.locations.count) location" : "\(self.locations.count) locations"
        }
        //self.setBusinessData()
    }
    
    
    
    func pickedBusinessType(type: BusinessType) {
        businessTypeText.text = type.rawValue
        //basicBusiness?.type = type
        self.type = type
    }
    
    func imagePicked(image: UIImage?, imageUrl: String?) {
        if image != nil {
            //        self.urlString = uploadImageToFIR(image: image!, path: (Auth.auth().currentUser?.uid)!)
            //w33OBske4KYNVNFk60NiKoSXw6v1
            //(Auth.auth().currentUser?.uid)!
            //"w33OBske4KYNVNFk60NiKoSXw6v1"
            self.activity.isHidden = false
            self.activity.startAnimating()
            self.isImageLoading = true
            self.logo.image = image!
            self.imageShadow.bringSubviewToFront(self.activity)
            self.urlString = ""
            let path = "\(MyCompany.businessId)_\(MyCompany.basics.count)"
            uploadImageToFIR(image: image!,childName: "companylogo", path: path) { (url, error) in
                self.activity.isHidden = true
                self.activity.stopAnimating()
                self.isImageLoading = false
                if error == false{
                    self.urlString = url
                    print("URL=",url)
                }else{
                    self.urlString = ""
                }
            }
            
        }else{
            self.isImageLoading = false
            self.activity.isHidden = true
        }
        
    }
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var logo: UIImageView!
    var isImageLoading = false
    var urlString = ""
    
    @IBOutlet weak var businessName: UITextField!
    
    @IBOutlet weak var companyMission: UITextView!
    
    @IBOutlet weak var website: UITextField!
    
    var reloadDelegate: reloadMyCompanyDelegate?
    
    @IBOutlet weak var scroll: UIScrollView!
    
    var basicBusiness: BasicBusiness? = nil
    
    var isProfileSegue = false
    
    var type: BusinessType? = nil
    
    @IBOutlet weak var imageShadow: ShadowView!
    
    @IBOutlet weak var businessTypeText: UITextField!
    
    @IBOutlet weak var locationText: UILabel!
    
    var locations = [String]()
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var websiteUrl: String? {
        didSet {
            guard var websiteString = websiteUrl else {return}
            var result = ""
            while(websiteString.contains("///")) {
                websiteString = websiteString.replacingOccurrences(of: "///", with: "//")
            }
            if websiteString.starts(with: "https://"){

                let removedString = websiteString.replacingOccurrences(of: "https://", with: "")

                let stringPool = removedString.components(separatedBy: "/")

                result = stringPool.first!
            }else if websiteString.starts(with: "http://"){

                let removedString = websiteString.replacingOccurrences(of: "http://", with: "")

                let stringPool = removedString.components(separatedBy: "/")
                
                result = stringPool.first!
            } else if websiteString == "" {
                self.website.text = ""
                return
            }else{
                print(websiteString)
                let stringPool = websiteString.components(separatedBy: "/")
                result = stringPool.first!
            }
            
            print("before: \(result)")
            
           let checkContained = result.range(of: "\\b\("www.")\\b", options: .regularExpression) != nil
            
            if result.hasPrefix("www.") {
                
               //result = result.replacingOccurrences(of: "www.", with: "")
              result = String(result.dropFirst("www.".count))
                
            }
            
            if !result.hasPrefix("www."){
                result = "www." + result
            }
            self.website.text = " " + result
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.isHidden = true
        self.addDoneButtonOnKeyboard(textView: companyMission)
        setBusinessData()
//		(self.navigationController as! StandardNC).tempDelegate = self
        if let navigation = self.navigationController as? StandardNC{
            navigation.tempDelegate = self
        }
        //let zips = basicBusiness!.GetLocationZips()
        // Do any additional setup after loading the view.
    }
    
    func setBusinessData() {
        if let basic = basicBusiness{
            
            if let url = URL.init(string: basic.logoUrl){
            self.urlString = basic.logoUrl
            self.logo.downloadedFrom(url: url, contentMode: .scaleAspectFill, makeImageCircular: true)
            }
            
            self.businessName.text = basic.name
            self.companyMission.text = basic.mission
            //self.website.text = basic.website
            self.websiteUrl = basic.website
            self.businessTypeText.text = basic.type.rawValue
            self.type = basic.type
            locations.append(contentsOf: basic.locations)
            if basic.locations.count == 0 {
                self.locationText.text = "No Location"
            }else{
                self.locationText.text = basic.locations.count == 1 ? "\(basic.locations.count) location" : "\(basic.locations.count) locations"
            }
        }else{
            self.locationText.text = self.locations.count == 0 ? "No Location" : self.locations.count == 1 ? "\(1) Location" : "\(self.locations.count) Locations"
        }
    }
    
    override func doneButtonAction() {
        self.companyMission.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        if self.companyMission.text == "Company Mission Here"{
            self.companyMission.text = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scroll.contentInset = contentInset
        
    }
    
    @IBAction func dismiss(sender: UIButton){
        if basicBusiness != nil{
            saveBasicBusiness()
        }else{
            performDismiss()
            //self.navigationController?.popViewController(animated: true)
        }
        //
    }
    
    @IBAction func logoControlAction(sender: UIButton){
        
        if !self.isImageLoading {
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
                
                switch photoAuthorizationStatus {
                case .authorized:
                   DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "oneMoreGetPictureVC", sender: self)
                    }
                    debugPrint("It is not determined until now")
                case .restricted:
                    self.showNotificationForAuthorization()
                case .denied:
                    self.showNotificationForAuthorization()
                default:
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "oneMoreGetPictureVC", sender: self)
                    }
                }
        }else{
            self.showAlertMessage(title: "Alert", message: "Please wait!. Image is uploading") {
                
            }
        }
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
    
        func checkIfWebsiteEntered() -> String? {
            
            if GetURL() != nil{
                
                if !isGoodUrl(url: GetURL()!.absoluteString) || GetURL()!.absoluteString == "http://www.com" || GetURL()!.absoluteString == "https://www.com" || GetURL()!.absoluteString == "http://.com" || GetURL()!.absoluteString == "https://.com" || GetURL()!.absoluteString == "http://www..com" || GetURL()!.absoluteString == "https://www..com"{
                    
                   self.showAlertMessage(title: "Alert", message: "Please enter valid website") {
                                  
                   }
                    
                   return nil
                    
                }else{
                    
                    if isGoodUrl(url: GetURL()?.absoluteString ?? "") && website.text?.count != 0{
                    
                       return GetURL()!.absoluteString
                        
                    }else{
                        
                        MakeShake(viewToShake: self.website)
                        return nil
                    }
                    
                }
                
            }else{
                MakeShake(viewToShake: self.website)
                return nil
            }
            
        }
    
    func GetURL() -> URL? {
        var returnValue = website.text!.trimmingCharacters(in: .whitespaces)
        if !returnValue.lowercased().hasPrefix("http") {
            if !returnValue.lowercased().hasPrefix("www.") {
                returnValue = "http://www." + returnValue
            } else {
                returnValue = "http://" + returnValue
            }
        }else{
            if !returnValue.lowercased().hasPrefix("www.") {
                returnValue = "http://www." + returnValue
            }
        }
        return URL.init(string: returnValue)
    }
    
    @IBAction func saveAction(sender: UIButton){
        saveBtn.isUserInteractionEnabled = false
        saveBasicBusiness()
    }
	
	func saveBasicBusiness() {
		if checkBasicBusiness() == nil {
            DispatchQueue.main.async {
                self.saveBtn.isUserInteractionEnabled = true
            }
			return
		}
		
		let basic = checkBasicBusiness()!
		
		if self.basicBusiness == nil {
			MyCompany.basics.append(basic)
		}else{
			
			let index = MyCompany.basics.lastIndex { (basicData) -> Bool in
				return basic.basicId == basicData.basicId
			}
			
			print("p==",index!)
			
			if index == nil {
			   return
			}
			MyCompany.basics[index!] = basic
            
		}
        
        if MyCompany.basics.count == 1 {
            MyCompany.activeBasicId = MyCompany.basics.first!.basicId
        }
		
		MyCompany.UpdateToFirebase { (error) in
			DispatchQueue.main.async {
				self.reloadDelegate?.reloadMyCompany()
                self.saveBtn.isUserInteractionEnabled = true
                RefreshPublicData {
                }
                if self.isProfileSegue{
				self.navigationController?.popViewController(animated: true)
                }else{
                    self.instantiateToMainScreen()
                }
			}
		}
	}

    func checkBasicBusiness() -> BasicBusiness? {
        
        if self.urlString == "" {
            self.showAlertMessage(title: "Alert", message: "Please choose the image") {
            }
            return nil
        }
        if self.businessName.text?.count == 0 {
            self.showAlertMessage(title: "Alert", message: "Please enter the business name") {
            }
            return nil
        }
        if self.companyMission.text == "" || self.companyMission.text.count == 0 {
            self.showAlertMessage(title: "Alert", message: "Please enter company mission") {
            }
            return nil
        }
        
        if checkIfWebsiteEntered() == nil {
            return nil
        }
        
        if self.type == nil{
            self.showAlertMessage(title: "Alert", message: "Please choose any Business Type") {
            }
            return nil
        }
        
        if self.locations.count == 0 {
            self.showAlertMessage(title: "Alert", message: "Please add any location") {
            }
            return nil
        }
        
        let NewBasicID: String = self.basicBusiness == nil ? makeFirebaseUrl(self.businessName.text! + ", " + GetNewID()) : self.basicBusiness!.basicId
        let referral = self.basicBusiness == nil ? randomString(length: 6) : self.basicBusiness!.referralCode
        let flags = self.basicBusiness == nil ? [] : self.basicBusiness!.flags
        let followedBy = self.basicBusiness == nil ? [] : self.basicBusiness!.followedBy
        let locations = self.locations
        
        let basicDict = ["businessId": MyCompany.businessId, "name": self.businessName.text!, "logoUrl": self.urlString, "mission": self.companyMission.text!, "joinedDate": Date().toUString(), "referralCode": referral, "flags": flags, "followedBy": followedBy, "website": checkIfWebsiteEntered() as Any, "locations": locations as Any, "type": self.type!.rawValue as Any] as [String : Any]
        
        let basic = BasicBusiness.init(dictionary: basicDict, basicId: NewBasicID)
        
        return basic
        
    }
    
    @IBAction func previewBasicData(sender: UIButton){
        if checkBasicBusiness() == nil {
            return
        }
        
        let basic = checkBasicBusiness()!
        self.performSegue(withIdentifier: "toContractBusiness", sender: basic)
    }
    
    @IBAction func businessTapped(geture: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "toBusinessTypePicker", sender: self)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? GetPictureVC {
            destination.delegate = self
        }
        
        if let destination = segue.destination as? ContractBusinessVC {
            destination.businessData = (sender as! BasicBusiness)
        }
        
        if let destination = segue.destination as? BusinessTypePicker{
            destination.typePicker = self
        }
        
        if let destination = segue.destination as? LocationSelectorVC{
            destination.locationRetrive = self
            if self.locations.count == 0{
               destination.locations = [""]
            }else{
               destination.locations = self.locations
            }
            
        }
    }
    

}
