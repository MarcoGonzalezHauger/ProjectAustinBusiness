//
//  Social Sort Algorithms.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

protocol publicDataRefreshDelegate {
	func publicDataRefreshed(userOrBusinessId: String)
}

var publicDataListeners: [publicDataRefreshDelegate] = []


/// Fetch the influencers public data from Firebase and add a listener to refresh the users
func StartListeningToPublicData() {
	let ref = Database.database().reference().child("Accounts/Public/Influencers")
	ref.observe(.childChanged) { (snap) in
		
		print(snap.key + ": \(snap.value as! [String: Any])")
		
		if let snapValue = snap.value as? [String: Any] {
			
			let newInf = BasicInfluencer.init(dictionary: snapValue, userId: snap.key)
			
//			if newInf.userId == Myself.userId {
//				Myself.basic = newInf
//				Myself.UpdateToFirebase(alsoUpdateToPublic: false, completed: nil)
//			}
			
			for i in 0...(globalBasicInfluencers.count - 1) {
				if globalBasicInfluencers[i].userId == newInf.userId {
					globalBasicInfluencers[i] = newInf
					break
				}
			}
			
			for i in 0...(globalBasicBoth.count - 1) {
				if let thisInf = globalBasicBoth[i] as? BasicInfluencer {
					if thisInf.userId == newInf.userId {
						globalBasicBoth[i] = newInf
						break
					}
				}
			}
			
			for l in publicDataListeners {
				l.publicDataRefreshed(userOrBusinessId: newInf.userId)
			}
		}
	}
	
	let refBusinesses = Database.database().reference().child("Accounts/Public/Businesses")
	refBusinesses.observe(.childChanged) { (snap) in
		if let snapValue = snap.value as? [String: Any] {
			
			let newBus = BasicBusiness.init(dictionary: snapValue, basicId: snap.key)
			
			for i in 0...(globalBasicBusinesses.count - 1) {
				if globalBasicBusinesses[i].businessId == newBus.businessId {
					globalBasicBusinesses[i] = newBus
					break
				}
			}
			
			for i in 0...(globalBasicBoth.count - 1) {
				if let thisBus = globalBasicBoth[i] as? BasicBusiness {
					if thisBus.businessId == newBus.businessId {
						globalBasicBoth[i] = newBus
						break
					}
				}
			}
			
			for l in publicDataListeners {
				l.publicDataRefreshed(userOrBusinessId: newBus.businessId)
			}
		}
	}
}

func logOut() {
    myselfRefreshListeners.removeAll()
    publicDataListeners.removeAll()
    UserDefaults.standard.removeObject(forKey: "email")
    UserDefaults.standard.removeObject(forKey: "password")
    DispatchQueue.main.async {
        let signInStoryBoard = UIStoryboard(name: "LoginSetup", bundle: nil)
        let loginVC = signInStoryBoard.instantiateInitialViewController()
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.window?.rootViewController = loginVC
    }
}
/// Fetch all public data from Firebase. To enhance the loading user data.
/// - Parameter finished: Send Completion handler optional. Incase in any situation we want to know if Refresh public data finished.
/// - Returns: Returns empty Callback. But we serialize all public data and save the data seperately to global collections.
func RefreshPublicData(finished: (() -> ())?) {
	let ref = Database.database().reference().child("Accounts/Public")
	ref.observeSingleEvent(of: .value) { (snapshot) in
		//Download and serialize the public accounts.
		let dictionary = snapshot.value as! [String: Any]
		SerializePublicData(dictionary: dictionary, finished: finished)
		
	}
}

func SerializePublicData(dictionary: [String: Any], finished: (() -> ())?) {
	
	var infs: [BasicInfluencer] = []
	var basicbu: [BasicBusiness] = []
	let influencers = dictionary["Influencers"] as! [String: Any]
	for i in influencers.keys {
		let inf = BasicInfluencer.init(dictionary: influencers[i] as! [String: Any], userId: i)
		infs.append(inf)
	}
	let businesses = dictionary["Businesses"] as! [String: Any]
	for b in businesses.keys {
		let bus = BasicBusiness.init(dictionary: businesses[b] as! [String: Any], basicId: b)
		basicbu.append(bus)
	}
	
	//sort both influencer and business accounts.
	
	infs = sortInfluencers(basicInfluencers: infs)
	basicbu = sortBusinesses(basicBusinesses: basicbu)
	
	//create list of both.
	
	globalBasicInfluencers = infs
	globalBasicBusinesses = basicbu
	globalBasicBoth = combineListsToBoth(basicBusinesses: basicbu, basicInfluencers: infs, withSort: false)
	finished?()
}

func sortInfluencers(basicInfluencers: [BasicInfluencer]) -> [BasicInfluencer] {
	return basicInfluencers.sorted(by: sortCompareInfluencers(influencer1:influencer2:))
}

func sortBusinesses(basicBusinesses: [BasicBusiness]) -> [BasicBusiness] {
	return basicBusinesses.sorted(by: sortCompareBusiness(business1:business2:))
	
}

func sortCompareBusiness(business1 bus1: BasicBusiness, business2 bus2: BasicBusiness) -> Bool {
	if bus1.followedBy.count == bus2.followedBy.count {
		return bus1.name > bus2.name
	} else {
		return bus1.followedBy.count > bus2.followedBy.count
	}
}
/// Sort Influencers based on their name, engagement rate, average likes.
/// - Parameters:
///   - inf1: First Influencer
///   - inf2: Second Influencer
/// - Returns: true if two influencers alreay sorted
func sortCompareInfluencers(influencer1 inf1: BasicInfluencer, influencer2 inf2: BasicInfluencer) -> Bool {
	if inf1.engagementRate == inf2.engagementRate {
		if inf1.averageLikes == inf2.averageLikes {
			return inf1.username > inf2.username
		} else {
			return inf1.averageLikes > inf2.averageLikes
		}
	} else {
		if inf1.averageLikes < 30 || inf2.averageLikes < 30 {
			if inf1.averageLikes == inf2.averageLikes {
				if inf1.engagementRate == inf2.engagementRate {
					return inf1.username > inf2.username
				} else {
					return inf1.engagementRate > inf2.engagementRate
				}
			} else {
				return inf1.averageLikes > inf2.averageLikes
			}
		} else {
			return inf1.engagementRate > inf2.engagementRate
		}
	}
}

func combineListsToBoth(basicBusinesses: [BasicBusiness], basicInfluencers: [BasicInfluencer], withSort: Bool) -> [Any] {
	var finallist: [Any] = []
	var tempinf = basicInfluencers
	var tempbus = basicBusinesses
	if withSort {
		tempinf	 = sortInfluencers(basicInfluencers: tempinf)
		tempbus	 = sortBusinesses(basicBusinesses: tempbus)
	}
	let totalCount = tempinf.count + tempbus.count
	while finallist.count < totalCount {
		for _ in 1...3 {
			if tempinf.count > 0 {
				finallist.append(tempinf[0])
				tempinf.remove(at: 0)
			}
		}
		if tempbus.count > 0 {
			finallist.append(tempbus[0])
			tempbus.remove(at: 0)
		}
	}
	return finallist
}

enum SearchFor: String {
	case influencers, businesses, both
}

enum SocialTabFor: String {
    case following, followedby
}
/// Get following users of the influencer
/// - Parameter influencer: send influencer which one needs to get their following users
/// - Returns: array of users both influencer and business user
func SocialFollowingUsers(influencer: Influencer) -> [Any] {
    
    var totalUsers = [Any]()
        
    let FilteredInfluencers = globalBasicInfluencers.filter { (basicInfluencer) -> Bool in
            return influencer.basic.followingInfluencers.contains(basicInfluencer.userId)
        }
    let FilteredBusiness = globalBasicBusinesses.filter { (basicBusiness) -> Bool in
        return influencer.basic.followingBusinesses.contains(basicBusiness.basicId)
    }
    
    totalUsers.append(contentsOf: sortInfluencers(basicInfluencers: FilteredInfluencers))
    totalUsers.append(contentsOf: sortBusinesses(basicBusinesses: FilteredBusiness))
    
    return totalUsers
}
/// Get users of followed by influencer
/// - Parameter influencer: send influencer which one needs to get users of followed by.
/// - Returns: array of users
func SocialFollowedByUsers(influencer: Influencer) -> [Any] {
    var totalUsers = [Any]()
        
    let FilteredInfluencers = globalBasicInfluencers.filter { (basicInfluencer) -> Bool in
            return influencer.basic.followedBy.contains(basicInfluencer.userId)
        }
    
    totalUsers.append(contentsOf: FilteredInfluencers)
    
    return totalUsers
}
/// Search Influencer or business user or both influencer and busienss user.
/// - Parameters:
///   - searchQuery: Send serch text
///   - searchIn: Send SearchFor enum
/// - Returns: Array of users it might be influencers or business users or both base on searchIn
func SearchSocialData(searchQuery: String, searchIn: SearchFor) -> [Any] {
	
	let query = searchQuery.lowercased()
	
	var listOfUsers: [Any] = []
	if searchIn == .influencers || searchIn == .both {
		listOfUsers.append(contentsOf: globalBasicInfluencers)
	}
	if searchIn == .businesses || searchIn == .both {
		listOfUsers.append(contentsOf: globalBasicBusinesses)
	}
	
	if !Myself.basic.isForTesting {
		listOfUsers = listOfUsers.filter {
			if let inf = $0 as? BasicInfluencer {
				return !inf.isForTesting
			}
			let bus = $0 as! BasicBusiness
			return !bus.isForTesting
		}
	}
	
	listOfUsers = listOfUsers.filter {
		if let inf = $0 as? BasicInfluencer {
			return !inf.checkFlag("isInvisible")
		}
		let bus = $0 as! BasicBusiness
		return !bus.checkFlag("isInvisible")
	}
	
	if query == "" {
		switch searchIn {
		case .both:
			return globalBasicBoth
		case .influencers:
			return globalBasicInfluencers
		default:
			return globalBasicBusinesses
		}
	}
	
	var results: [String: Double] = [:]
	
	for u in listOfUsers {
		if let u = u as? BasicBusiness {
			let businessName = u.name.lowercased()
			if businessName.contains(query) {
				results[u.businessId] = 60
			}
			if businessName.hasPrefix(query) {
				results[u.businessId] = 80
			}
		}
		if let u = u as? BasicInfluencer {
			let infName = u.name.lowercased()
			let infUsername = u.username.lowercased()
			
			if infName.contains(query) {
				results[u.userId] = 40
			}
			if infUsername.contains(query) {
				results[u.userId] = 70
			}
			
			if infName.hasPrefix(query) {
				results[u.userId] = 75
			}
			if infUsername.hasPrefix(query) {
				results[u.userId] = 90
			}
		}
	}
	
	listOfUsers = listOfUsers.filter {
		let id: String = ($0 as? BasicInfluencer)?.userId ?? ($0 as! BasicBusiness).businessId
		return results[id] != nil
	}
	
	listOfUsers.sort { (obj1, obj2) -> Bool in
		let idFor1: String = (obj1 as? BasicInfluencer)?.userId ?? (obj1 as! BasicBusiness).businessId
		let idFor2: String = (obj2 as? BasicInfluencer)?.userId ?? (obj2 as! BasicBusiness).businessId
		if results[idFor1]! == results[idFor2]! { // It is impossible for a business and influencer to be assigned the same Double.
			if let inf1 = obj1 as? BasicInfluencer {
				let inf2 = obj2 as! BasicInfluencer
				return sortCompareInfluencers(influencer1: inf1, influencer2: inf2)
			} else {
				let bus1 = obj1 as! BasicBusiness
				let bus2 = obj2 as! BasicBusiness
				return sortCompareBusiness(business1: bus1, business2: bus2)
			}
		} else {
			return results[idFor1]! > results[idFor2]!
		}
	}
	
	return listOfUsers
}






