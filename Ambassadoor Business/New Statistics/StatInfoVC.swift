//
//  StatInfoVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class StatInfoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
	@IBAction func dismissNow(_ sender: Any) {
		dismiss(animated: true)
	}
	
}
