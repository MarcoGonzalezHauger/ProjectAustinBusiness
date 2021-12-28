//
//  StatisticsHomeVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/25/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class sentOfferCell: UITableViewCell {
	@IBOutlet weak var logoView: ShadowView!
	@IBOutlet weak var logoImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var sentLabel: UILabel!
}


class StatisticsHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, viewAllDelegate {
	
	var tempPosts: [InProgressPost] = []
    
    /// segue to view one post page if selected one post otherwise view all post page.
    /// - Parameter posts: get InProgressPost array referrance
	func viewAllPressed(posts: [InProgressPost]) {
		tempPosts = posts
		if posts.count == 1 {
			performSegue(withIdentifier: "viewOne", sender: self)
		} else {
			performSegue(withIdentifier: "toViewAll", sender: self)
		}
	}
	
	@IBOutlet weak var sentOfferHeight: NSLayoutConstraint!
	
//    MARK: - SentOffers list UITableview Datasource and Delegates
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return MyCompany.sentOffers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "sentCell", for: indexPath) as! sentOfferCell
		
		let thisSentOffer = MyCompany.sentOffers[indexPath.row]
		
		cell.logoImage.clipsToBounds = true
		cell.logoImage.layer.cornerRadius = 20
		
		downloadImage(thisSentOffer.BasicBusiness()!.logoUrl) { image in
			if let image = image {
				cell.logoImage.image = image
			}
		}
		
		cell.titleLabel.text = "\"" +  thisSentOffer.title + "\""
		cell.sentLabel.text = "Sent " + thisSentOffer.timeSent.toString(dateFormat: "MM/dd/YYYY") + ": " + NumberToPrice(Value: thisSentOffer.poolOffer?.originalCashPower ?? 0, enforceCents: true)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		sentOfferHeight.constant = CGFloat((69 * MyCompany.sentOffers.count)) - GetOnePxWidth()
		return 69
	}
	
	var tSO: sentOffer?
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		tSO = MyCompany.sentOffers[indexPath.row]
		performSegue(withIdentifier: "toSentStatistics", sender: self)
	}
	

	var viewRef: PostViewerVC?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		sentTableView.dataSource = self
		sentTableView.delegate = self
		loadData()
    }
	
	@IBOutlet weak var sentOfferBox: ShadowView!
	@IBOutlet weak var sentTableView: UITableView!
	
	
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
			dest.delegate = self
		}
		if let dest = segue.destination as? SentOfferStatsVC {
			dest.thisSentOffer = tSO!
		}
		if let dest = segue.destination as? ViewPostsVC {
			dest.posts = tempPosts
		}
	}
	
    
    /// Refresh statistics action
    /// - Parameter sender: UIButton referrance
	@IBAction func reloadTemp(_ sender: Any) {
		loadData()
	}
	
	@IBOutlet weak var titleLabel: UILabel!
	
    
    /// Filter inprogress post by instagram post. reload inprogress post data. compute total post, total engagements, Follower reached, total budget and set data.
	func refreshTotals() {
		
		if MyCompany.sentOffers.count == 0 {
			titleLabel.text = "No Offers Sent Yet!"
		} else {
			titleLabel.text = "Sent for All Offers"
		}
		
		let allPosts = GetAllInProgressPosts().filter{$0.instagramPost != nil}
		print(">> Loaded with \(allPosts.count) results.")
		
		
		sentTableView.reloadData()
		
		viewRef?.samplePosts = allPosts
		viewRef?.topLabel.text = "All Posts"
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
			if let PO = sent.poolOffer {
				tBudget += PO.originalCashPower
			}
			index += 1
			if index == MyCompany.sentOffers.count {
				self.totalBudget.text = "Total Budget: " + NumberToPrice(Value: tBudget)
			}
		}
		
		
		
		totalLikes.text = "Total Engagements (Likes): " + NumberToStringWithCommas(number: Double(tLikes))
		totalPosts.text = "Total Posts: " + NumberToStringWithCommas(number: Double(allPosts.count))
		totalCollected.text = "Collected by Influencers: " + NumberToPrice(Value: tMoney)
		totalViews.text = "Followers Reached: " + NumberToStringWithCommas(number: tViews)
		
		
		
	}
	
    
    /// Refresh statistics data
	func loadData() {
		print(">> Loading Test Data.")
		RefreshStatistics(withInfluencerRefresh: true) {
			self.refreshTotals()
		}
	}
	
}
