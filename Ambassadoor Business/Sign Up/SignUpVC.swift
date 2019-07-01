//
//  SignUpVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/3/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class signupbutton: UIButton {
	override func awakeFromNib() {
		self.layer.cornerRadius = 10
		self.layer.borderWidth = 2
		self.layer.borderColor = UIColor.gray.cgColor
	}
}

class SignUpVC: UIViewController {

	@IBOutlet weak var registerButton: UIButton!
	@IBOutlet weak var signinButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
    }

}
