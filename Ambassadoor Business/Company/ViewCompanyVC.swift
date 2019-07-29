//
//  ViewCompanyVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

class ViewCompanyVC: UIViewController, editDelegate {

	@IBOutlet weak var companyLogo: UIImageView!
	@IBOutlet weak var companyName: UILabel!
	@IBOutlet weak var companyMission: UILabel!
	@IBOutlet weak var companyDescription: UITextView!
	@IBOutlet weak var viewWebsiteShadowView: ShadowView!
	
	var website: String?
	
	func editsMade(newCompany: Company) {
		YourCompany = newCompany
		updateCompanyInfo()
		UpdateYourCompanyInFirebase()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		companyLogo.layer.cornerRadius = 5
		updateCompanyInfo()
    }
	
	@IBAction func GoToWebsite(_ sender: Any) {
		if isGoodUrl(url: YourCompany.website) {
			if let url = URL(string: YourCompany.website) {
				UIApplication.shared.open(url, options: [:])
			}
		} else {
			MakeShake(viewToShake: viewWebsiteShadowView)
		}
	}
	
	func updateCompanyInfo() {
		
		companyName.text = YourCompany.name
		companyMission.text = YourCompany.mission
		companyDescription.text = YourCompany.companyDescription
		
		companyLogo.image = UIImage.init(named: "defaultCompany")
		
		if YourCompany.logo != nil && YourCompany.logo != "" {
			if let logoid = YourCompany.logo {
				getImage(id: logoid) { (image) in
					self.companyLogo.image = image
				}
			}
		}
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? EditCompanyTVC {
			destination.ThisCompany = YourCompany
			destination.delegate = self
		}
    }

}
