//
//  ReferralInfoVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/22/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ReferralInfoVC: UIViewController {

	@IBOutlet weak var referralLabel: UILabel!
	override func viewDidLoad() {
        super.viewDidLoad()

		referralLabel.text = Singleton.sharedInstance.getCompanyUser().businessReferral ?? ""
    }
	
	@IBAction func doneButtonPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}
