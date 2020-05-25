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

class ViewCompanyVC: BaseVC, ImagePickerDelegate, webChangedDelegate {
	
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
			
			switch result.split(separator: ".").count {
			case 1: result = "www.\(result).com"
			case 2: result = "www.\(result)"
			default: break
			}
			

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
	
	func updateIsEditing() {
		companyMission.isEditable = isCurrentlyEditing
		companyName.isEnabled = isCurrentlyEditing
		changeWebsite.isHidden = !isCurrentlyEditing
		missionView.borderWidth = isCurrentlyEditing ? 1 : 0
		companyName.borderStyle = isCurrentlyEditing ? .roundedRect : .none
		
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
		companyLogo.layer.cornerRadius = companyLogo.bounds.height / 2
        self.showActivityIndicator()
		updateCompanyInfo()
		updateIsEditing()
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
		downloadImage(YourCompany.logo!) { (image) in
			
			
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
				self.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
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
