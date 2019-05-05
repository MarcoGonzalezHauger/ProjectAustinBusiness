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
	
	var website: String?
	
	func editsMade(newCompany: Company) {
		YourCompany = newCompany
		updateCompanyInfo()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		companyLogo.layer.cornerRadius = 5
		updateCompanyInfo()
    }
	
	@IBAction func GoToWebsite(_ sender: Any) {
		if let url = URL(string: YourCompany.website) {
			UIApplication.shared.open(url, options: [:])
		}
	}
	
	func updateCompanyInfo() {
		
		companyName.text = YourCompany.name
		companyMission.text = YourCompany.mission
		companyDescription.text = YourCompany.description
		
		if YourCompany.logo != nil && YourCompany.logo != "" {
			if let thisUrl = URL(string: YourCompany.logo!) {
				companyLogo.downloadedFrom(url: thisUrl)
			} else {
				companyLogo.image = UIImage.init(named: "defaultCompany")
			}
		} else {
			companyLogo.image = UIImage.init(named: "defaultCompany")
		}
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? EditCompanyTVC {
			destination.ThisCompany = YourCompany
			destination.delegate = self
		}
    }

}
