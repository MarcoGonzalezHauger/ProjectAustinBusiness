//
//  Social Interactions ext.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension BasicInfluencer {
	
	func Follow(as myInf: Influencer) {
		if !self.isFollowing(as: myInf) {
			self.followedBy.append(myInf.userId)
			self.UpdateToFirebase(completed: nil)
			myInf.basic.followingInfluencers.append(self.userId)
			myInf.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
		}
	}
	
	func Unfollow(as myInf: Influencer) {
		self.followedBy.removeAll{$0 == myInf.userId}
		self.UpdateToFirebase(completed: nil)
		myInf.basic.followingInfluencers.removeAll{$0 == self.userId}
		myInf.basic.UpdateToFirebase(completed: nil)
	}
	
	func isFollowing(as myInf: Influencer) -> Bool {
		return followedBy.contains(myInf.userId)
	}
}

extension BasicBusiness {
	
	func Follow(as myInf: Influencer) {
		if !self.isFollowing(as: myInf) {
			self.followedBy.append(myInf.userId)
			self.UpdateToFirebase(completed: nil)
			myInf.basic.followingBusinesses.append(self.basicId)
			myInf.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
		}
		
	}
	
	func Unfollow(as myInf: Influencer) {
		self.followedBy.removeAll{$0 == myInf.userId}
		self.UpdateToFirebase(completed: nil)
		myInf.basic.followingBusinesses.removeAll{$0 == self.basicId}
		myInf.basic.UpdateToFirebase(completed: nil)
	}
	
	func isFollowing(as myInf: Influencer) -> Bool {
		return followedBy.contains(myInf.userId)
	}
	
	func GetAvaliableOffersFromBusiness() -> [PoolOffer] {
		return getFilteredOfferPool().filter{$0.basicId == basicId}
	}
}
