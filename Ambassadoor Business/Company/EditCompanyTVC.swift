//
//  EditCompanyTVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC.
//

import UIKit

protocol editDelegate {
	func editsMade(newCompany: Company)
}

class EditCompanyTVC: UITableViewController, ImagePickerDelegate {
	
	
	func imagePicked(image: UIImage?, imageUrl: String?) {
		if let image = image {
			companyLogo.image = image
		}
		if let imageUrl = imageUrl {
			logo = imageUrl
		}
	}
	

	@IBOutlet weak var nameView: UIView!
	@IBOutlet weak var webView: UIView!
	@IBOutlet weak var nameTextBox: UITextField!
	@IBOutlet weak var missionTextBox: UITextView!
	@IBOutlet weak var descTextBox: UITextView!
	@IBOutlet weak var webTextBox: UITextView!
	@IBOutlet weak var companyLogo: UIImageView!
	
	var logo: String?
	var AccountID: String?
	var InstagramName: String?
	var delegate: editDelegate?
	
	var ThisCompany: Company!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? GetPictureVC {
			destination.delegate = self
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		companyLogo.layer.cornerRadius = 5
		nameTextBox.text = ThisCompany.name
		missionTextBox.text = ThisCompany.mission
		descTextBox.text = ThisCompany.description
		webTextBox.text = ThisCompany.website
		logo = ThisCompany.logo
		if ThisCompany.logo != nil && ThisCompany.logo != "" {
			if let thisUrl = URL(string: logo!) {
				companyLogo.downloadedFrom(url: thisUrl)
			}
		}
		AccountID = ThisCompany.account_ID
		InstagramName = ThisCompany.instagram_name
    }
	
	@IBAction func save(_ sender: Any) {
		var problem = false
		if nameTextBox.text == "" {
			problem = true
			MakeShake(viewToShake: nameView)
		}
		if isGoodUrl(url: webTextBox.text) {
			MakeShake(viewToShake: webView)
		} else {
			if webTextBox.text != "" {
				problem = true
				MakeShake(viewToShake: webView)
			}
		}
		if !problem {
			delegate?.editsMade(newCompany: Company(name: nameTextBox.text!, logo: logo, mission: missionTextBox.text, website: webTextBox.text, account_ID: AccountID ?? "", instagram_name: InstagramName ?? "", description: descTextBox.text))
			dismiss(animated: true, completion: nil)
		}
	}
	
	@IBAction func cancel(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func changeImage(_ sender: Any) {
	}
	

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
	
}
