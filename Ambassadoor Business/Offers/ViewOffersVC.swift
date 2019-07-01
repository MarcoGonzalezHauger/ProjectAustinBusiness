//
//  ViewOffersVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 6/29/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class composeButtonCell: UITableViewCell {
	@IBOutlet weak var composebuttonOutline: UIView!
}

class viewOfferCell: UITableViewCell {
	@IBOutlet weak var offerviewoutline: UIView!
	@IBOutlet weak var offerName: UILabel!
	@IBOutlet weak var postDetails: UILabel!
	
}

class ViewOffersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	let masterCornerRadius: CGFloat = 5
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.OfferDrafts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let index = indexPath.row
		if index == 0 {
			let cell = shelf.dequeueReusableCell(withIdentifier: "composeButton") as! composeButtonCell
			cell.composebuttonOutline.layer.cornerRadius = masterCornerRadius
			return cell
		} else {
			let thisTemplate: TemplateOffer = global.OfferDrafts[indexPath.row - 1]
			let cell = shelf.dequeueReusableCell(withIdentifier: "offerButton") as! viewOfferCell
			cell.offerName.text = thisTemplate.title
			cell.offerviewoutline.layer.cornerRadius = masterCornerRadius
			return cell
		}
	}
	

	@IBOutlet weak var shelf: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		shelf.dataSource = self
		shelf.delegate = self
    }
}
