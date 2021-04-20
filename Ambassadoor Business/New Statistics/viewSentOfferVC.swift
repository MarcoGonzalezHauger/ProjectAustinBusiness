//
//  viewSentOfferVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/19/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class influencerPostCell: UITableViewCell {
	@IBOutlet weak var postImage: UIImageView!
	@IBOutlet weak var infUser: UILabel!
	@IBOutlet weak var timePosted: UILabel!
	@IBOutlet weak var likesLabel: UILabel!
	func setWithInstagramPost(instagramPost: InstagramPost, basicInfluencer: BasicInfluencer) {
		postImage.downloadAndSetImage(instagramPost.images)
		infUser.text = "@" + basicInfluencer.username
		likesLabel.text = CompressNumber(number: Double(instagramPost.like_count))
		timePosted.text = DateToAgo(date: instagramPost.timestamp)
	}
}

class viewSentOfferVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		postTableView.isHidden = posts.count == 0
		infHeader.text = posts.count == 0 ? "No Influencer posted yet." : "Influencer Posts"
		return posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "instaCell") as! influencerPostCell
		let inf = basicInfs[indexPath.row]
		let post = posts[inf.userId]!
		cell.setWithInstagramPost(instagramPost: post, basicInfluencer: inf)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
	
	var posts: [String: InstagramPost] = [:]
	var basicInfs: [BasicInfluencer] = []

	var poolOffer: PoolOffer!
	var sentOffer: sentOffer!
	
	@IBOutlet weak var postTableView: UITableView!
	@IBOutlet weak var offerNameLabel: UILabel!
	@IBOutlet weak var infHeader: UILabel!
	@IBOutlet weak var acceptedCount: UILabel!
	@IBOutlet weak var moneyLabel: UILabel!
	@IBOutlet weak var totalLikes: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		postTableView.delegate = self
		postTableView.dataSource = self
		loadOfferInfo()
	}
	
	@IBAction func closePressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let url = URL(string: "https://www.instagram.com/\(basicInfs[indexPath.row].username)") {
			UIApplication.shared.open(url)
		}
	}
	
	func loadOfferInfo() {
		offerNameLabel.text = sentOffer.title
		let sText = poolOffer.acceptedUserIds.count == 1 ? " has" : "s have"
		acceptedCount.text = "\(poolOffer.acceptedUserIds.count) influencer\(sText) accepted."
		moneyLabel.text = NumberToPrice(Value: poolOffer.cashPower) + "/" + NumberToPrice(Value: poolOffer.originalCashPower) + " left"
		getInfluencers()
	}
	
	func getInfluencers() {
		let ref = Database.database().reference().child("Accounts/Private/Influencers")
		ref.observeSingleEvent(of: .value) { (snap) in
			var infs: [Influencer] = []
			if let dict = snap.value as? [String: Any] {
				for k in dict.keys {
					let newDict = dict[k] as! [String: Any]
					let newInf = Influencer.init(dictionary: newDict, userId: snap.key)
				 infs.append(newInf)
				}
			}
			self.calculatePosts(influencers: infs)
		}
	}
	
	func calculatePosts(influencers: [Influencer]) {
		var totalLikes1 = 0
		for i in influencers {
			let igP = i.inProgressPosts.filter({ (ippost) -> Bool in
				return ippost.PoolOfferId == poolOffer.poolId
			})
			if igP.count > 0 {
				if let post1 = igP.first!.instagramPost {
					basicInfs.append(i.basic)
					totalLikes1 += post1.like_count
					posts[i.userId] = post1
				}
			}
		}
		
		totalLikes.text = CompressNumber(number: Double(totalLikes1))
		
		postTableView.reloadData()
		
	}
	
}
