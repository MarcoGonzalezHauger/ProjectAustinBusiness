//
//  Statistics Algo.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/25/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension sentOffer {
	
    
    /// Get all pool offers from firebase. filter pool offers based on sentout offer. Get offer current status from influencer inprogress post. sort inprogress post by accepted date.
    /// - Parameter completion: send empty call back.
	func getDataForOffer(completion: @escaping () -> Void) {
		self.getPoolOffer { PoolOffer in
			if let PoolOffer = PoolOffer {
				
				print("\(self.title) >> \(PoolOffer.acceptedUserIds.count)")
				self.inProgressPosts.removeAll()
				
				for uid: String in PoolOffer.acceptedUserIds {
					let inf: Influencer = getInfluencer(id: uid)
					self.inProgressPosts.append(contentsOf: inf.inProgressPosts.filter{$0.PoolOfferId == self.poolId})
				}
				self.inProgressPosts.sort{$0.dateAccepted < $1.dateAccepted}
				
				self.poolOffer = PoolOffer
			}
			completion()
		}
	}
}

/// Get all influencers from firebase and pass to gtSt function.
/// - Parameters:
///   - withInfluencerRefresh: pass bool tag if refresh influencers too.
///   - completion: Pass empty callback
func RefreshStatistics(withInfluencerRefresh: Bool, completion: @escaping () -> Void) {
	if withInfluencerRefresh {
		getInfluencers {
			print(">> GOT INF")
			gtSt(completion: completion)
		}
	} else {
		gtSt(completion: completion)
	}
}

func GetAllInProgressPosts() -> [InProgressPost] {
	var totalList: [InProgressPost] = []
	for sentOffer in MyCompany.sentOffers {
		totalList.append(contentsOf: sentOffer.inProgressPosts)
	}
	totalList.sort{ $0.dateAccepted < $1.dateAccepted }
	
	print(">>: \(totalList.count)")
	
	return totalList
}

/// Get information about sentout offers from pool offer table.
/// - Parameter completion: pass empty closure
func gtSt(completion: @escaping () -> Void) { // "GET STAT", should only be used through the function "RefreshStatistics"
	print(">> GET STAT ORDER SIZE: \(MyCompany.sentOffers.count)")
	if MyCompany.sentOffers.count == 0 {
		completion()
	}
	var index = 0
	for sentOffer in MyCompany.sentOffers {
		sentOffer.getDataForOffer {
			index += 1
			//print(">> \(index)")
			if index == MyCompany.sentOffers.count {
				completion()
			}
		}
	}
}

var InfluencerDatabase: [Influencer] = []

/// Get influencers from firebase
/// - Parameter completion: pass empty call back.
func getInfluencers(completion: @escaping () -> Void) {
	let database = Database.database().reference().child("Accounts/Private/Influencers")
	database.observeSingleEvent(of: .value) { snap in
		if let snap = snap.value as? [String: Any] {
			InfluencerDatabase.removeAll()
			for ky: String in snap.keys {
				InfluencerDatabase.append(Influencer.init(dictionary: snap[ky] as! [String : Any], userId: ky))
			}
			completion()
		}
	}
}

func getInfluencer(id: String) -> Influencer {
	return InfluencerDatabase.filter{ return $0.userId == id }.first!
}


var BusinessDatabase: [Business] = []

func getBusinesses(completion: @escaping () -> Void) {
    let database = Database.database().reference().child("Accounts/Private/Businesses")
    database.observeSingleEvent(of: .value) { snap in
        if let snap = snap.value as? [String: Any] {
            BusinessDatabase.removeAll()
            for ky: String in snap.keys {
                BusinessDatabase.append(Business.init(dictionary: snap[ky] as! [String: Any], businessId: ky))
            }
            completion()
        }
    }
}
