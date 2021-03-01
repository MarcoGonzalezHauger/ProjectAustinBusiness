//
//  OfferPool algo.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

protocol OfferPoolRefreshDelegate {
	func OfferPoolRefreshed(poolId: String)
}

protocol myselfRefreshDelegate {
	func myselfRefreshed()
}

var myselfRefreshListeners: [myselfRefreshDelegate] = []
var offerPoolListeners: [OfferPoolRefreshDelegate] = []

//This function only needs to activated ONCE on startup of the app. After that please do not execute it again.



func startListeningToOfferPool() {
	let oneTimeRef = Database.database().reference().child("Pool")
	oneTimeRef.observeSingleEvent(of: .value) { (snap) in
		let d = snap.value as! [String: Any]
		var pool: [PoolOffer] = []
		for id in d.keys {
			let thisOffer = PoolOffer.init(dictionary: d[id] as! [String: Any], poolId: id)
			pool.append(thisOffer)
		}
		print("PV: Original Count is \(pool.count)")
		offerPool = pool
		sortOfferPool()
	}
	let listenerRef = Database.database().reference().child("Pool")
	listenerRef.observe(.childChanged) { (snap) in
		if let d = snap.value as? [String: Any] {
			let thisOffer = PoolOffer.init(dictionary: d, poolId: snap.key)
			for i in 0...(offerPool.count - 1) {
				if offerPool[i].poolId == thisOffer.poolId {
					offerPool[i] = thisOffer
				}
			}
			sortOfferPool()
			for l in offerPoolListeners {
				l.OfferPoolRefreshed(poolId: snap.key)
			}
		}
	}
	let listenerRef2 = Database.database().reference().child("Pool")
	listenerRef2.observe(.childAdded) { (snap) in
		if let d = snap.value as? [String: Any] {
			
			let thisOffer = PoolOffer.init(dictionary: d, poolId: snap.key)
			offerPool.append(thisOffer)
			sortOfferPool()
			for l in offerPoolListeners {
				l.OfferPoolRefreshed(poolId: snap.key)
			}
		}
	}
}

func startListeningToMyself(userId: String) {
	let listenRef = Database.database().reference().child("Accounts/Private/Influencers/\(Myself.userId)")
	
	listenRef.observe(.value) { (snap) in
		Myself = Influencer.init(dictionary: snap.value as! [String: Any], userId: snap.key)
		for l in myselfRefreshListeners {
			l.myselfRefreshed()
		}
	}
	
	let PublicFollowedByRef = Database.database().reference().child("Accounts/Public/Influencers/\(Myself.userId)/followedBy")
	
	PublicFollowedByRef.observe(.value) { (snap) in
		if let followedBy = snap.value as? [String] {
			Myself.basic.followedBy = followedBy
		} else {
			Myself.basic.followedBy = []
		}
		for l in myselfRefreshListeners {
			l.myselfRefreshed()
		}
	}
}

func sortOfferPool() {
	offerPool.sort { (o1, o2) -> Bool in
		if o1.payIncrease == o2.payIncrease {
			return o1.sentDate > o2.sentDate
		} else {
			return o1.payIncrease > o2.payIncrease
		}
	}
}

func getFollowingOfferPool() -> [PoolOffer] {
	return getFilteredOfferPool().filter{Myself.basic.followingBusinesses.contains($0.businessId)}
}

func getFilteredOfferPool() -> [PoolOffer] {
	let filteredPool = offerPool.filter { $0.canBeAccepted(forInfluencer: Myself) }
	print("PV: Filitered Count is \(filteredPool.count)")
	return filteredPool
}

func GetOfferPool() -> [PoolOffer] {
	print("PV: Getting Total count is \(offerPool.count)")
	return offerPool
}

func GetBasicInfluencer(id: String) -> BasicInfluencer? {
	for i in globalBasicInfluencers {
		if i.userId == id {
			return i
		}
	}
	return  nil
}

func GetBasicBusiness(id: String) -> BasicBusiness? {
	for b in globalBasicBusinesses {
		if b.basicId == id {
			return b
		}
	}
	return  nil
}
