//
//  SentOfferStatsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SentOfferStatsVC: UIViewController {

	@IBOutlet weak var companyLogo: UIImageView!
	var thisSentOffer: sentOffer!
	
	func loadInfo() {
		
		let allPosts = GetAllInProgressPosts().filter{$0.PoolOfferId == thisSentOffer.poolId}.filter{$0.instagramPost != nil}
		
		refView?.topLabel.text = "Posts"
		refView?.samplePosts = allPosts
		refView?.collectionView.reloadData()
		 
		offerNameLabel.text = "\"" + thisSentOffer.title + "\""
		
		var tLikes = 0.0
		var tCollected = 0.0
		var tReached = 0.0
		
		for p in allPosts {
			tLikes += Double(p.instagramPost?.like_count ?? 0)
			if p.status == "Paid" {
				tCollected += p.cashValue
			}
			tReached += InfluencerDatabase.filter{$0.userId == p.userId}.first!.basic.followerCount
		}
		
		totalLikes.text = "Total Engagements (Likes): " + NumberToStringWithCommas(number: tLikes)
		totalPosts.text = "Total Posts: " + NumberToStringWithCommas(number: Double(allPosts.count))
		totalCollected.text = "Collected by Influencers: " + NumberToPrice(Value: tCollected, enforceCents: true)
		totalReached.text = "Followers Reached: " + NumberToStringWithCommas(number: tReached)
		totalBudget.text = "Total Budget: " + NumberToPrice(Value: thisSentOffer.poolOffer?.originalCashPower ?? 0.0)
		
		downloadImage(thisSentOffer.BasicBusiness()!.logoUrl) { image in
			if let image = image {
				self.companyLogo.image = image
			}
		}
		
	}
	
	@IBOutlet weak var offerNameLabel: UILabel!
	
	
	@IBOutlet weak var totalLikes: UILabel!
	@IBOutlet weak var totalPosts: UILabel!
	@IBOutlet weak var totalCollected: UILabel!
	@IBOutlet weak var totalReached: UILabel!
	@IBOutlet weak var totalBudget: UILabel!
	
	
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var backButton: UIButton!
	
	@IBAction func dismissNow(_ sender: Any) {
		if backButton.title(for: .normal) == "Back" {
			navigationController?.popViewController(animated: true)
		} else {
			dismiss(animated: true, completion: nil)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		loadInfo()
    }
	
	func doneButton(isDone: Bool) {
		if isDone {
			backButton.setTitle("Done", for: .normal)
			topConstraint.constant = 55
		} else {
			backButton.setTitle("Back", for: .normal)
			topConstraint.constant = 70
		}
	}
	
	var refView: PostViewerVC?
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? PostViewerVC {
			refView = dest
		}
	}
	
}

