//
//  ViewPostsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 9/8/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class singlePostCell: UITableViewCell { //reuseId: singlePostCell
	
	@IBOutlet weak var postImage: UIImageView!
	
	@IBOutlet weak var captionLabel: UILabel!
	@IBOutlet weak var datePostedLabel: UILabel!
	@IBOutlet weak var costForPostLabel: UILabel!
	@IBOutlet weak var likesLabel: UILabel!
	@IBOutlet weak var averageLikesLabel: UILabel!
	@IBOutlet weak var followersLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var viewOnInstaView: ShadowView!
	
	var thisPost: InProgressPost!
	
	@objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
		UseTapticEngine()
		
		UIApplication.shared.open(URL(string: "https://www.instagram.com/p/\(thisPost.instagramPost!.instagramPostId)")!)
			
		
		
	}
	
	func getLabelTextForStatus(_ status: String) -> String {
		switch status {
		case "Posted":
			return "Status: Influencer Posted"
		case "Rejected":
			return "Status: Rejected by Ambassadoor"
		case "Verified":
			return "Stauts: Verified, Will be Paid"
		case "Cancelled":
			return "Stauts: Cancelled by Influencer"
		case "Paid":
			return "Status: Verified and Paid"
		default: return ""
		}
	}
	
	func getLabelColorForStatus(_ status: String) -> UIColor {
		switch status {
		case "Posted":
			return .systemBlue
		case "Rejected":
			return .systemRed
		case "Verified":
			return .systemGreen
		case "Cancelled":
			return .systemRed
		case "Paid":
			return .systemYellow
		default: return GetForeColor()
		}
	}
	
	func getPriceSuffixForStatus(_ status: String) -> String {
		switch status {
		case "Posted":
			return "(not paid yet)"
		case "Rejected":
			return "(rejected, will not be paid)"
		case "Verified":
			return "(will be paid)"
		case "Cancelled":
			return "(cancelled by influencer)"
		case "Paid":
			return "(paid)"
		default: return ""
		}
	}
	
	var addedTap = false
	
	func updatePostInformation() {
		if !addedTap {
			let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
			viewOnInstaView.addGestureRecognizer(tap)
			addedTap = true
		}
		
		statusLabel.text = getLabelTextForStatus(thisPost.status)
		statusLabel.textColor = getLabelColorForStatus(thisPost.status)
		
		if let inf = GetBasicInfluencer(id: thisPost.userId) {
			username = inf.username
			usernameButton.titleLabel?.text = "@" + username
			usernameButton.setTitle("@" + username, for: .normal)
			averageLikesLabel.text = "Average Likes for this Influencer: " + CompressNumber(number: inf.averageLikes)
			followersLabel.text = "Followers: " + CompressNumber(number: inf.averageLikes)
		}
		
		likesLabel.text = "Likes so far: \(thisPost.instagramPost!.like_count)"
		
		captionLabel.text = "Caption:\n" + thisPost.instagramPost!.caption
		
		datePostedLabel.text = "Posted " + thisPost.instagramPost!.timestamp.toString(dateFormat: "M/dd/YYYY") + " at " + thisPost.instagramPost!.timestamp.toString(dateFormat: "HH:mm a")
		
		costForPostLabel.text = NumberToPrice(Value: thisPost.cashValue, enforceCents: true) + " " + getPriceSuffixForStatus(thisPost.status)
		
		postImage.downloadAndSetImage(thisPost.instagramPost!.images)
			
		}
	
	var username: String = ""
	@IBOutlet weak var usernameButton: UIButton!
	@IBAction func usernameButonPressed(_ sender: Any) {
		UseTapticEngine()
		
		if let inf = GetBasicInfluencer(id: thisPost.userId) {
			UIApplication.shared.open(URL(string: "instagram://user?username=\(inf.username)")!)
		}
	}
}

class ViewPostsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let postCell = tableView.dequeueReusableCell(withIdentifier: "singlePostCell") as! singlePostCell
		
		postCell.thisPost = posts[indexPath.row]
		postCell.updatePostInformation()
		
		return postCell
	}
	
	@IBAction func donePressed(_ sender: Any) {
		if let nav = self.navigationController {
			nav.popViewController(animated: true)
			return
		}
		dismiss(animated: true, completion: nil)
	}
	
	var posts: [InProgressPost] = []
	@IBOutlet weak var postLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var doneButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.alwaysBounceVertical = false
		
		if self.navigationController != nil {
			doneButton.setTitle("Back", for: .normal)
		}
		
		tableView.delegate = self
		tableView.dataSource = self
		
		postLabel.isHidden = posts.count == 1
		if posts.count == 1 {
			view.backgroundColor = GetBackColor()
		} else {
			view.backgroundColor = UIColor.init(named: "newSubtleBackground")!
		}
		
		
    }

}
