//
//  CalculatedValues.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension BasicInfluencer {
	var engagementRate: Double {
		if followerCount == 0 {
			return 0
		}
		return averageLikes / followerCount
	}
	var engagementRateInt: Int {
		return Int((engagementRate * 100).rounded(.down))
	}
	var baselinePricePerPost: Double {
		return averageLikes * cashToLikesCoefficient
	}
	var age: Int {
		return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year!
	}
	var isForTesting: Bool {
		get {
			return checkFlag("isForTesting")
		}
	}
	var resizedProfile: String {
		get {
			let resizedUrl: String = self.profilePicURL.replacingOccurrences(of: "profile%2F", with: "profile%2Fsmall%2F").replacingOccurrences(of: ".jpeg", with: "_256x256.jpeg").replacingOccurrences(of: ".png", with: "_256x256.jpeg")
			return resizedUrl
		}
	}
}

extension Business {
	func GetActiveBasicBusiness() -> BasicBusiness? {
		for b in basics {
			if b.basicId == activeBasicId {
				return b
			}
		}
		return nil
	}
}

extension BasicBusiness {
	var avaliableOffers: [PoolOffer] {
		return getFilteredOfferPool().filter{$0.basicId == basicId}
	}
	var isForTesting: Bool {
		get {
			return checkFlag("isForTesting")
		}
	}
}

extension OfferFilter {
	func DoesInfluencerPassFilter(basicInfluencer: BasicInfluencer) -> Bool {
		if basicInfluencer.age < 18 { //If a influencer is not 18, NOTHING should be acceptable for them
			return false
		}
		if mustBe21 {
			if basicInfluencer.age < 21 {
				return false
			}
		}
		if basicInfluencer.averageLikes == 0 {
			return false
		}
		if basicInfluencer.engagementRate < minimumEngagementRate {
			return false
		}
		if acceptedZipCodes.count != 0 {
			if !acceptedZipCodes.contains(basicInfluencer.zipCode) {
				return false
			}
		}
		if acceptedGenders.count != 0 {
			if !acceptedGenders.contains(basicInfluencer.gender) {
				return false
			}
		}
		if basicInfluencer.followingBusinesses.contains(basicId) {
			return true
		}
		if acceptedInterests.count != 0 {
			for cat in basicInfluencer.interests {
				if acceptedInterests.contains(cat) {
					return true
				}
			}
		} else {
			return true
		}
		print("Failed finally.")
		return false
	}
}

extension PoolOffer {
	func hasInfluencerAccepted(influencer inf: Influencer) -> Bool {
		if acceptedUserIds.contains(Myself.userId) {
			return true
		}
		for p in inf.inProgressPosts {
			if p.PoolOfferId == self.poolId {
				return true
			}
		}
		return false
	}
	func BasicBusiness() -> BasicBusiness? {
		return GetBasicBusiness(id: basicId)
	}
	func pricePerPost(forInfluencer inf: BasicInfluencer) -> Double {
		return inf.baselinePricePerPost * self.payIncrease
	}
	func totalCost(forInfluencer inf: BasicInfluencer) -> Double {
		return pricePerPost(forInfluencer: inf) * Double(draftPosts.count)
	}
	
	func canAffordInflunecer(forInfluencer inf: BasicInfluencer) -> Bool {
		return cashPower > totalCost(forInfluencer: inf)
	}
	func canBeAccepted(forInfluencer inf: Influencer) -> Bool {
		return filter.DoesInfluencerPassFilter(basicInfluencer: inf.basic) && canAffordInflunecer(forInfluencer: inf.basic) && !hasInfluencerAccepted(influencer: inf)
	}
}

extension InProgressPost {
	func BasicBusiness() -> BasicBusiness? {
		return GetBasicBusiness(id: basicId)
	}
}

extension sentOffer {
	func BasicBusiness() -> BasicBusiness? {
		for b in MyCompany.basics {
			if b.basicId == basicId {
				return b
			}
		}
		return nil
	}
	
	func getPoolOffer(completion: @escaping (PoolOffer) -> ()) {
		let ref = Database.database().reference().child("Pool").child(self.poolId)
		ref.observeSingleEvent(of: .value) { (data) in
			if let dict = data.value as? [String: Any] {
				let poolOffer = PoolOffer.init(dictionary: dict, poolId: self.poolId)
				completion(poolOffer)
			}
		}
	}
	
}
