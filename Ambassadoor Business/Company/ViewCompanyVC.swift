//
//  ViewCompanyVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive property of Tesseract Freelance, LLC.
//

import UIKit
import SDWebImage
import Firebase
import Photos

class ViewCompanyVC: BaseVC, ImagePickerDelegate, webChangedDelegate, UITextFieldDelegate {
	
	func websiteChanged(_ newWebsite: String) {
		website = newWebsite
	}
	
	func imagePicked(image: UIImage?, imageUrl: String?) {
		if image != nil {
            self.companyLogo.image = image
            uploadImageToFIR(image: image!,childName: "companylogo", path: (Auth.auth().currentUser?.uid)!) { (url, error) in
                if error == false{
                    self.logo = url
                    print("URL=",url)
                }else{
                    self.logo = ""
                }
            }
            
        }
	}
	
	//TO DO:
	//CHANGE WEBSITE,
	//REFERRAL CODE
	
	@IBOutlet weak var companyLogo: UIImageView!
	@IBOutlet weak var viewWebsiteShadowView: ShadowView!
	@IBOutlet weak var companyName: UITextField!
	@IBOutlet weak var companyMission: UITextView!
	@IBOutlet weak var editButton: UIButton!
	@IBOutlet weak var missionView: ShadowView!
	@IBOutlet weak var changeImageButton: UIButton!
	@IBOutlet weak var changeWebsite: UIButton!
	@IBOutlet weak var companyNameInset: NSLayoutConstraint!
	@IBOutlet weak var visitWebsite: UIButton!
	@IBOutlet weak var referralLabel: UILabel!
	
	var logo: String?
	var website: String? {
		didSet {
			guard var websiteString = website else {return}
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
				visitWebsite.setTitle(" No Website", for: .normal)
				visitWebsite.isEnabled = false
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
            
//            if !result.hasSuffix(".com"){
//               result = result + ".com"
//            }
			
//			switch result.split(separator: ".").count {
//
//			case 1: result = "www.\(result).com"
//			case 2: result = "www.\(result)"
//			default: break
//
//			}
			

			visitWebsite.isEnabled = true
			visitWebsite.setTitle(" " + result, for: .normal)
		}
	}
	var wasPressed = false
	
	@IBAction func stopEditing(_ sender: Any) {
		view.endEditing(true)
	}
	
	@IBAction func editButtonPressed(_ sender: Any) {
		wasPressed = true
		if isCurrentlyEditing {
			EndEdit()
		} else{
			beginEdit()
		}
		updateIsEditing()
	}
    
    @IBAction func changeImageAction(sender: UIButton) {
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
           DispatchQueue.main.async {
                self.performSegue(withIdentifier: "fromCompanytoGetPicture", sender: self)
            }
            debugPrint("It is not determined until now")
        case .restricted:
            self.showNotificationForAuthorization()
        case .denied:
            self.showNotificationForAuthorization()
        default:
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "fromCompanytoGetPicture", sender: self)
            }
        }
        
        //self.performSegue(withIdentifier: "fromCompanytoGetPicture", sender: self)
    }
    
    func showNotificationForAuthorization() {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    openAppSettings(index: 1)
                } else {
                    openAppSettings(index: 1)
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
	
	func updateIsEditing() {
		companyMission.isEditable = isCurrentlyEditing
        companyMission.isUserInteractionEnabled = isCurrentlyEditing
		companyName.isEnabled = isCurrentlyEditing
        companyName.delegate = self
		changeWebsite.isHidden = !isCurrentlyEditing
//		missionView.borderWidth = isCurrentlyEditing ? 1 : 0
		missionView.borderWidth = 1
//		companyName.borderStyle = isCurrentlyEditing ? .roundedRect : .none
		companyName.borderStyle = .roundedRect
		
		if wasPressed {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
				self.changeImageButton.isHidden = false
				self.changeImageButton.alpha = self.isCurrentlyEditing ? 0 : 1
				self.companyNameInset.constant = self.isCurrentlyEditing ? 50 : 16
				UIView.animate(withDuration: 0.5) {
					self.view.layoutIfNeeded()
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + (self.isCurrentlyEditing ? 0.2 : 0.01)) {
					UIView.animate(withDuration: 0.2) {
						self.changeImageButton.alpha = self.isCurrentlyEditing ? 1 : 0
					}
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
						if !self.isCurrentlyEditing {
							self.changeImageButton.isHidden = true
						}
					}
				}
			}
		} else {
			changeImageButton.isHidden = !isCurrentlyEditing
			companyNameInset.constant = isCurrentlyEditing ? 50 : 16
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textView: self.companyMission)
		companyLogo.layer.cornerRadius = companyLogo.bounds.height / 2
        self.showActivityIndicator()
		updateCompanyInfo()
		updateIsEditing()
    }
    
    override func doneButtonAction() {
        self.companyMission.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
	
	@IBAction func GoToWebsite(_ sender: Any) {
		if isGoodUrl(url: YourCompany.website) {
			if let url = URL(string: YourCompany.website) {
				UIApplication.shared.open(url, options: [:])
			} else {
				MakeShake(viewToShake: viewWebsiteShadowView)
			}
		} else {
			MakeShake(viewToShake: viewWebsiteShadowView)
		}
	}
	
	var isCurrentlyEditing = false
	
	func beginEdit() {
		editButton.setTitle("Save", for: .normal)
		isCurrentlyEditing = true
	}
	
	func EndEdit() {
		if canSave() {
			editButton.setTitle("Edit", for: .normal)
			updateCompany()
			isCurrentlyEditing = false
		}
	}
	
	func updateCompanyInfo() {
		
		//referralLabel.text = YourCompany.referralcode
        referralLabel.text = Singleton.sharedInstance.getCompanyUser().businessReferral ?? ""
		website = YourCompany.website
		logo = YourCompany.logo
		companyName.text = YourCompany.name
		companyMission.text = YourCompany.mission
//		companyDescription.text = YourCompany.companyDescription
        self.companyLogo.sd_setImage(with: URL.init(string: YourCompany.logo!), placeholderImage: UIImage(named: "defaultProduct"))
		setCompanyTabBarItem()
	}
	
	func setCompanyTabBarItem() {
		guard let YourCompany = YourCompany else {return}
		guard let logo = YourCompany.logo else {return}
		downloadImage(logo) { (image) in
			DispatchQueue.main.async {
				let size = CGSize.init(width: 32, height: 32)
				
				let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
				
				UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
				image?.draw(in: rect)
				let newImage = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()
				
				if var image = newImage {
					print(image.scale)
					image = makeImageCircular(image: image)
					print(image.scale)
					self.tabBarController?.viewControllers?.first?.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
				}
			}
			
		}
	}
	
	@IBAction func changeWebsite(_ sender: Any) {
		
	}
	
	func canSave() -> Bool {
		var problem = false
		if companyName.text == "" {
			problem = true
			MakeShake(viewToShake: companyName)
		}
		if companyMission.text == "" {
			problem = true
			MakeShake(viewToShake: companyMission)
		}
		if website == nil {
			problem = true
			MakeShake(viewToShake: changeWebsite)
		}
		return !problem
	}
	
	func updateCompany() {
			
		YourCompany.name = companyName.text!
		YourCompany.mission	 = companyMission.text
		YourCompany.website = website!
		YourCompany.logo = logo
		
		
		UpdateCompanyInDatabase(company: YourCompany)
		updateCompanyInfo()
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? GetPictureVC {
			destination.delegate = self
		}
		if let dest = segue.destination as? ChangeWebsiteVC {
			dest.setDefaultUrl(website)
			dest.webChangedDelegate = self
		}
    }

}
