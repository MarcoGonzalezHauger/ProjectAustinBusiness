//
//  SentOfferStatsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class SentOfferStatsVC: UIViewController, viewAllDelegate {
	
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
	

	@IBOutlet weak var companyLogo: UIImageView!
	var thisSentOffer: sentOffer!
    var offerPool: PoolOffer?
    
    /// Filter inprogress post by instagram post. reload inprogress post data. compute total post, total engagements, Follower reached, total budget and set data.
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
		if tLikes == 0 {
			pricePerLike.isHidden = true
		} else {
			pricePerLike.isHidden = false
			pricePerLike.text = "Cost per Engagement: " + NumberToPrice(Value: tCollected / tLikes)
		}
		
		downloadImage(thisSentOffer.BasicBusiness()!.logoUrl) { image in
			if let image = image {
				self.companyLogo.image = image
			}
		}
        getOfferPool(poolId: thisSentOffer.poolId) { status, pooloffer in
            if status{
                self.offerPool = pooloffer
            }
        }
	}
	
	@IBOutlet weak var offerNameLabel: UILabel!
	
	
	@IBOutlet weak var totalLikes: UILabel!
	@IBOutlet weak var totalPosts: UILabel!
	@IBOutlet weak var totalCollected: UILabel!
	@IBOutlet weak var totalReached: UILabel!
	@IBOutlet weak var totalBudget: UILabel!
	@IBOutlet weak var pricePerLike: UILabel!
	
	
	@IBOutlet weak var topConstraint: NSLayoutConstraint!
	@IBOutlet weak var backButton: UIButton!
	
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
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
	
    
    /// Change back button text as per isDone status
    /// - Parameter isDone: true or false
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
    
    
    
    /// Check if user can edit the filter. segue to edit filter page
    /// - Parameter sender: UIButton referrance
    @IBAction func toEditFilterAction(sender: UIButton){
        if self.offerPool == nil{
            self.showStandardAlertDialog(title: "Alert", msg: "No Filter Found. Try another Offer") { alert in
                
            }
            return
        }else{
            self.performSegue(withIdentifier: "toEditFilterSegue", sender: self)
        }
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? PostViewerVC {
			refView = dest
			dest.delegate = self
		}
		if let dest = segue.destination as? ViewPostsVC {
			dest.posts = tempPosts
		}
        if let dest = segue.destination as? OfferFilterVC {
            dest.offerPool = self.offerPool
        }
	}
	
}

