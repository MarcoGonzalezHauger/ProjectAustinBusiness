//
//  postsFromInfluencers.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/16/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class SentOfferCell: UITableViewCell {
	@IBOutlet weak var coImage: UIImageView!
	@IBOutlet weak var offerNameLabel: UILabel!
	@IBOutlet weak var coNameLabel: UILabel!
	@IBOutlet weak var moneyLeftLabel: UILabel!
}

class postsFromInfluencersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var sentTableView: UITableView!
	var sentOffers: [sentOffer] = []
	var PoolOffers: [String: PoolOffer] = [:]
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sentOffers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let thisSentOffer = sentOffers[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "SentOfferCell") as! SentOfferCell
		
		if let thisBusiness = thisSentOffer.BasicBusiness() {
			cell.coImage.downloadAndSetImage(thisBusiness.logoUrl)
			cell.coNameLabel.text = "A " + thisBusiness.name + " Offer"
		}
		
		cell.offerNameLabel.text = thisSentOffer.title
		
		if let thisPO = PoolOffers[thisSentOffer.sentOfferId] {
			cell.moneyLeftLabel.text = NumberToPrice(Value: thisPO.cashPower) + "/" + NumberToPrice(Value: thisPO.originalCashPower) + " left"

		}
		return cell
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		refreshSentOffers()
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		sentOffers = MyCompany.sentOffers
		refreshSentOffers()
		sentTableView.delegate = self
		sentTableView.dataSource = self
    }
	
	var sentOfferToPass: sentOffer!
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		sentOfferToPass = sentOffers[indexPath.row]
		performSegue(withIdentifier: "toViewSentOffer", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? viewSentOfferVC {
			view.sentOffer = sentOfferToPass
			view.poolOffer = PoolOffers[sentOfferToPass.sentOfferId]!
		}
	}
	
	func refreshSentOffers() {
		for so in MyCompany.sentOffers {
			let soid = so.sentOfferId
			so.getPoolOffer { (PO) in
				self.PoolOffers[soid] = PO
				self.sentTableView.reloadData()
			}
		}
	}
}
