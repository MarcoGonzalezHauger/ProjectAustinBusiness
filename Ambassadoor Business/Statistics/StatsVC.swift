//
//  StatsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class StatsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        YourCompany = Company.init(dictionary: ["name": "KRILL GROUP", "logo": "", "mission": "Turn a profit.", "website": "https://www.google.com/", "account_ID": "0", "instagram_name": "marcogonzalezhauger", "description": "No description to see here!", "accountBalance": 1000.0])
        let templateOffer = GetTestTemplateOffer()
        sendOffer(offer: templateOffer, money: 500, completion: { (offer) in
            debugPrint(offer)
        })
	}
}

