//
//  StatisticsHomeVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/25/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase


class StatisticsHomeVC: UIViewController {

	var viewRef: PostViewerVC?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	
	
	@IBOutlet weak var totalLikes: UILabel!
	@IBOutlet weak var totalPosts: UILabel!
	@IBOutlet weak var totalCollected: UILabel!
	@IBOutlet weak var totalViews: UILabel!
	@IBOutlet weak var totalBudget: UILabel!
	
	
	override func viewDidAppear(_ animated: Bool) {
		
		loadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? PostViewerVC {
			viewRef = dest
		}
	}
	
	@IBAction func reloadTemp(_ sender: Any) {
		loadData()
	}
	
	func refreshTotals() {
		
		let allPosts = GetAllInProgressPosts().filter{$0.instagramPost != nil}
		print(">> Loaded with \(allPosts.count) results.")
		
		
		viewRef?.samplePosts = allPosts
		viewRef?.collectionView.reloadData()
		
		var tLikes = 0
		var tMoney = 0.0
		var tViews = 0.0
		for p in allPosts {
			tLikes += p.instagramPost?.like_count ?? 0
			if p.status == "Paid" {
				tMoney += p.cashValue
			}
			tViews += InfluencerDatabase.filter{$0.userId == p.userId}.first!.basic.followerCount
		}
		
		var tBudget = 0.0
		var index = 0
		for sent in MyCompany.sentOffers {
			sent.getPoolOffer { PO in
				if let PO = PO {
					tBudget += PO.originalCashPower
				}
				index += 1
				if index == MyCompany.sentOffers.count {
					self.totalBudget.text = "Total Budget: " + NumberToPrice(Value: tBudget)
				}
			}
		}
		
		
		
		totalLikes.text = "Total Engagements (Likes): " + NumberToStringWithCommas(number: Double(tLikes))
		totalPosts.text = "Total Posts: " + NumberToStringWithCommas(number: Double(allPosts.count))
		totalCollected.text = "Collected by Influencers: " + NumberToPrice(Value: tMoney)
		totalViews.text = "Followers Reached: " + NumberToStringWithCommas(number: tViews)
		
		
		
	}
	
	func loadData() {
		print(">> Loading Test Data.")
		RefreshStatistics(withInfluencerRefresh: true) {
			self.refreshTotals()
		}
	}
	
}
