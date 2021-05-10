//
//  postsFromInfluencers.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/16/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase

class instaPostCell: UITableViewCell {
	@IBOutlet weak var postImage: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var offerLabel: UILabel!
	@IBOutlet weak var likesLabel: UILabel!
}

class postsFromInfluencers: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var posts: [InstagramPost] = []
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let thisPost = posts[indexPath.row]
		let newCell = tableView.dequeueReusableCell(withIdentifier: "instaCell") as! instaPostCell
		newCell.postImage.downloadAndSetImage(thisPost.images)
		return newCell
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let url = URL(string: "https://www.instagram.com/p/\(posts[indexPath.row].instagramPostId)") {
			UIApplication.shared.open(url)
		}
	}
	
	func refreshPosts() {
		Database.database().reference().child("Accounts/Public")
		for sentOffer in MyCompany.sentOffers {
			
		}
	}
}
