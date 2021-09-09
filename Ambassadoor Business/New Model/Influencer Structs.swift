//
//  User2.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/21/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase


//MARK: Main Class

class Influencer {
	
	//Subclasses
	var basic: BasicInfluencer
	var inbox: [Message]
	var finance: InfluencerFinance
	
	var inProgressPosts: [InProgressPost]
	
	//Authentication and Tokens
	var email: String
	var password: String
	var instagramAuthToken: String
	var instagramAccountId: String
	var tokenFIR: String
	
	var userId: String
		
	init(basic: BasicInfluencer, finance: InfluencerFinance, email: String, password: String, instagramAuthToken: String, instagramAccountId: String, tokenFIR: String, userId: String) {
		self.basic = basic
		self.finance = finance
		self.email = email
		self.password = password
		self.instagramAuthToken =  instagramAuthToken
		self.instagramAccountId = instagramAccountId
		self.tokenFIR = tokenFIR
		self.userId = userId
		self.inProgressPosts = []
		self.inbox = []
	}
	
	init(dictionary d: [String: Any], userId id: String) {
		userId = id
		
		basic = BasicInfluencer(dictionary: d["basic"] as! [String: Any], userId: id)
		finance = InfluencerFinance(dictionary: d["finance"] as! [String: Any], userID: id)
		
		inbox = []
		if let thisInbox = d["inbox"] as? [String: Any] {
			for messageId in thisInbox.keys {
				let thisMessage = thisInbox[messageId] as! [String : Any]
				inbox.append(Message(dictionary: thisMessage, userId: id, messageId: messageId))
			}
		}
		
		email = d["email"] as! String
		password = d["password"] as! String
		instagramAuthToken = d["instagramAuthToken"] as! String
		instagramAccountId = d["instagramAccountId"] as! String
		tokenFIR = d["tokenFIR"] as! String
	
		let instaPosts = d["instagramPost"] as? [String: Any] ?? [:]
		
		inProgressPosts = []
		if let inProgressDictionary = d["inProgressPosts"] as? [String: Any] {
			for inProgressPostId in inProgressDictionary.keys {
				var thisInProgressPost = inProgressDictionary[inProgressPostId] as! [String: Any]
				if var instaPostDict = instaPosts[inProgressPostId] as? [String: Any] {
					instaPostDict["postID"] = inProgressPostId
					instaPostDict["offerID"] = thisInProgressPost["PoolOfferId"]
					thisInProgressPost["instagramPost"] = instaPostDict
				}
				let newInProgressPost = InProgressPost.init(dictionary: thisInProgressPost, inProgressPostId: inProgressPostId, userId: id)
				inProgressPosts.append(newInProgressPost)
			}
		}
		
	}
	
	// To Diciontary Function
		
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		//Subclasses
		d["basic"] = basic.toDictionary()
		d["finance"] = finance.toDictionary()
		
		//Regular Variables
		d["password"] = password
		d["email"] = email
		d["instagramAuthToken"] = instagramAuthToken
		d["instagramAccountId"] = instagramAccountId
		d["tokenFIR"] = tokenFIR
		
		if inbox.count != 0 {
			var inboxDictionary: [String: Any] = [:]
			for msg in inbox {
				inboxDictionary[msg.messageId] = msg.toDictionary()
			}
			d["inbox"] = inboxDictionary
		}
		
		if inProgressPosts.count != 0 {
			var ippDictionary: [String: Any] = [:]
			for p in inProgressPosts {
				ippDictionary[p.inProgressPostId] = p.toDictionary()
			}
			d["inProgressPosts"] = ippDictionary
		}
		
		return d
	}
	
	
}

//MARK: Subclasses

class BasicInfluencer { //All public information goes here.
	var name: String
	var username: String
	var followerCount: Double
	var averageLikes: Double
	var profilePicURL: String
	var zipCode: String
	var gender: String
	var joinedDate: Date
	var interests: [String] //Formally "categories"
	var referralCode: String
	var userId: String
	var flags: [String]
	var followingInfluencers: [String]
	var followingBusinesses: [String]
	var followedBy: [String]
	var birthday: Date
	var resizedUrl: URL?
	
	
	func checkFlag(_ flag: String) -> Bool {
		return flags.contains(flag)
	}
	
	func AddFlag(_ flag: String) {
		if !flags.contains(flag) {
			flags.append(flag)
		}
	}
	
	func RemoveFlag(_ flag: String) {
		if flags.contains(flag) {
			flags.removeAll{$0 == flag}
		}
	}
	
	init(dictionary d: [String: Any], userId id: String) {
		userId = id
				
		username = d["username"] as! String
		name = d["name"] as! String
		if name == "" {
			name = username
		}
		followerCount = d["followerCount"] as! Double
		averageLikes = d["averageLikes"] as! Double
		profilePicURL = d["profilePicURL"] as! String
		zipCode = d["zipCode"] as! String
		gender = d["gender"] as! String
		joinedDate = (d["joinedDate"] as! String).toUDate()
		interests = d["interests"] as? [String] ?? []
		referralCode = d["referralCode"] as! String
		flags = d["flags"] as? [String] ?? []
		followingInfluencers = d["followingInfluencers"] as? [String] ?? []
		followingBusinesses = d["followingBusinesses"] as? [String] ?? []
		followedBy = d["followedBy"] as? [String] ?? []
		birthday = (d["birthday"] as! String).toUDate()
		
	}
	
	init(name: String,	username: String, followerCount: Double, averageLikes: Double, profilePicURL: String, zipCode: String, gender: String, joinedDate: Date, interests: [String], referralCode: String, flags: [String], followingInfluencers: [String], followingBusinesses: [String], followedBy: [String], birthday: Date, userId: String) {
		self.name = name
		if name == "" {
			self.name = username
		}
		self.username = username
		self.followerCount = followerCount
		self.averageLikes = averageLikes
		self.profilePicURL = profilePicURL
		self.zipCode = zipCode
		self.gender = gender
		self.joinedDate = joinedDate
		self.interests = interests
		self.referralCode = referralCode
		self.flags = flags
		self.followingInfluencers = followingInfluencers
		self.followingBusinesses = followingBusinesses
		self.followedBy = followedBy
		self.birthday = birthday
		self.userId = userId
	}
		 
		 
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["name"] = name
		d["username"] = username
		d["followerCount"] = followerCount
		d["averageLikes"] = averageLikes
		d["profilePicURL"] = profilePicURL
		d["zipCode"] = zipCode
		d["gender"] = gender
		d["joinedDate"] = joinedDate.toUString()
		d["interests"] = interests
		d["referralCode"] = referralCode
		d["flags"] = flags
		d["followingInfluencers"] = followingInfluencers
		d["followingBusinesses"] = followingBusinesses
		d["followedBy"] = followedBy
		d["birthday"] = birthday.toUString()
		
		return d
	}
}

class InstagramPost {
	
	var caption: String
	var instagramPostId: String
    var mediaId: String
	var images: String
	var like_count: Int
	var status: String
	var timestamp: Date
	var type: String
	var username: String
	var userId: String
	var postID: String
	var offerID: String
	
	
	init(dictionary d: [String: Any], userId id: String) {
		userId = id
		
		caption = d["caption"] as! String
		instagramPostId = d["shortcode"] as? String ?? ""
        mediaId = d["id"] as! String
		images = d["images"] as! String
		like_count = d["like_count"] as! Int
		status = d["status"] as! String
		type = d["type"] as! String
		username = d["username"] as! String
		postID = d["postID"] as? String ?? ""
		offerID = d["offerID"] as? String ?? ""
		let ts = d["timestamp"] as! String
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" //date format that instagram uses
		timestamp = dateFormatter.date(from: ts) ?? Date(timeIntervalSince1970: 0)
		
		
		print(d)
		
	}
	
//    func toDictionary() -> [String: Any] {
//        var d: [String: Any] = [:]
//
//        d["caption"] = caption
//        d["id"] = instagramPostId
//        d["images"] = images
//        d["like_count"] = like_count
//        d["status"] = status
//        d["type"] = type
//        d["username"] = username
//        d["postID"] = postID
//        d["offerID"] = offerID
//		d["timestamp"] = timestamp.toUString()
//
//        return d
//    }
	
}

class InfluencerFinance {
	var hasStripeAccount: Bool {
		get {
			return stripeAccount != nil
		}
	}
	var balance: Double
	var stripeAccount: StripeAccountInformation?
	var userId: String
	var log: [InfluencerTransactionLogItem]
	
	init(dictionary d: [String: Any], userID id: String) {
		userId = id
		
		balance = d["balance"] as! Double
		log = []
		if let thisLog = d["log"] as? [String: Any] {
			for logItem in thisLog.keys {
				let thisLogItem = thisLog[logItem] as! [String : Any]
				log.append(InfluencerTransactionLogItem(dictionary: thisLogItem, userID: userId, transactionId: logItem))
			}
		}
		
		if let thisStripeAccount = d["stripeAccount"] as? [String: Any] {
			stripeAccount = StripeAccountInformation(dictionary: thisStripeAccount, userOrBusinessId: id)
		}
	}
	
	init(balance: Double, userId: String, stripeAccount: StripeAccountInformation?) {
		self.balance = balance
		self.userId = userId
		self.stripeAccount = stripeAccount
		self.log = []
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		if log.count != 0 {
			var logDictionary: [String: Any] = [:]
			for logItem in log {
				logDictionary[logItem.transactionId] = logItem.toDictionary()
			}
			d["log"] = logDictionary
		}
		
		if let stripeAccount = stripeAccount {
			d["stripeAccount"] = stripeAccount.toDictionary()
		}
		d["balance"] = balance
		
		return d
	}
}

//MARK: Items

class InfluencerTransactionLogItem {
	var value: Double
	var time: Date
	var transactionId: String
	var type: String //acceptable values: fromOffer, addedToBank, ambverChanged
	var userId: String
	
	init(dictionary d: [String: Any], userID id: String, transactionId tID: String) {
		userId = id
		transactionId = tID
		
		value = d["value"] as! Double
		time = (d["time"] as! String).toUDate()
		type = d["type"] as! String
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		d["value"] = value
		d["time"] = time.toUString()
		d["type"] = type
		return d
	}
}

class StripeAccountInformation {
	var accessToken: String
	var livemode: Bool
	var refreshToken: String
	var tokenType: String
	var stripePublishableKey: String
	var stripeUserId: String
	var scope: String
	var userOrBusinessId: String
	var stripeCode: String?
	
	
	init(dictionary d: [String: Any], userOrBusinessId id: String) {
		
		userOrBusinessId = id //This ID can be either a business or user ID.
		
		accessToken = d["access_token"] as! String
		livemode = d["livemode"] as! Bool
		refreshToken = d["refresh_token"] as! String
		tokenType = d["token_type"] as! String
		stripePublishableKey = d["stripe_publishable_key"] as! String
		stripeUserId = d["stripe_user_id"] as! String
		scope = d["scope"] as! String
		stripeCode = d["stripeCode"] as? String
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["access_token"] = accessToken
		d["livemode"] = livemode
		d["refresh_token"] = refreshToken
		d["token_type"] = tokenType
		d["stripe_publishable_key"] = stripePublishableKey
		d["stripe_user_id"] = stripeUserId
		d["scope"] = scope
		d["stripeCode"] = stripeCode
		
		return d
	}
	
}

class Message {
	var text: String
	var title: String
	var time: Date
	var read: Bool
	var messageId: String
	var userId: String
	init(dictionary d: [String: Any], userId id: String, messageId mId: String) {
		userId = id
		messageId = mId
		
		text = d["text"] as! String
		title = d["title"] as! String
		time = (d["time"] as! String).toUDate()
		read = d["read"] as! Bool
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		d["text"] = text
		d["title"] = title
		d["time"] = time.toUString()
		d["read"] = read
		return d
	}
}
