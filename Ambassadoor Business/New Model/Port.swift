//
//  Port.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

/*
So this function will take everything in the current database and port it all to Ambassadoor 3.0 Update database.
No Loss.
*/

func ConvertEntireDatabase(iUnderstandWhatThisFunctionDoes ok: Bool) {
	if ok {
		let poolref = Database.database().reference().child("Pool")
		poolref.removeValue { (err, ref) in
			print("OFFERPOOL DATA HAS BEEN REMOVED ====================================")
			let delAccounts = Database.database().reference().child("Accounts")
			delAccounts.removeValue { (err, ref) in
				print("ACCOUNT DATA HAS BEEN REMOVED ====================================")
				let ref = Database.database().reference().child("/")
				ref.observeSingleEvent(of: .value) { (snap) in
					let od = snap.value as! [String: Any]
					print("DATABASE HAS BEEN DOWNLOADED\n====================================")
					//ConvertDatabaseToNewDatabaseFormat(od: od)
				}
			}
		}
		
	}
}

//func ConvertDatabaseToNewDatabaseFormat(od: [String: Any]) {
//	let usersdb = od["users"] as! [String: Any]
//	var users: [User] = []
//	for u in usersdb.keys {
//		do {
//			try users.append(User.init(dictionary: usersdb[u] as! [String: Any]))
//		} catch {
//			
//		}
//	}
//	var convertedInfluencer: [Influencer] = []
//	for u in users {
//		if u.version != "0.0.0" {
//						
//			let NewUserID = makeFirebaseUrl(u.username + ", " + randomString(length: 15))
//			
//			print("Updating User: \(u.username) (\(u.id)) --> \"\(NewUserID)\"")
//			var flags: [String] = []
//			if u.isForTesting {
//				flags.append("isForTesting")
//			}
//			if u.isDefaultOfferVerify {
//				flags.append("isVerified")
//			}
//			if u.username == "marcogonzalezhauger" || u.username == "brunogonzalezhauger" {
//				flags.append("isAmbassadoorExecutive")
//			}
//			
//			let authDict: [String: Any] = (od["InfluencerAuthentication"] as! [String: Any])[u.id] as! [String: Any]
//			
//			
//			var stripeAcc: StripeAccountInformation? = nil
//			
//			let infStripeAccounts: [String: Any] = od["InfluencerStripeAccount"] as! [String: Any]
//			if let thisInfStripeAccount: [String: Any] = infStripeAccounts[u.id] as? [String: Any] {
//				let thisDict: [String: Any] = thisInfStripeAccount["AccountDetail"] as! [String: Any]
//				
//				stripeAcc = StripeAccountInformation.init(dictionary: thisDict, userOrBusinessId: NewUserID)
//				
//			}
//			
//			
//			let tgender = u.gender?.rawValue ?? "Other"
//			
//			let tbday = Date.init(timeIntervalSince1970: 123)
//			
//			var joinedDate = Date()
//			if let jDate = u.joinedDate { //JoinedDate was serialized with a NON UNIVERSAL FORAMT.
//				let dateFormatter = DateFormatter()
//				dateFormatter.timeZone = TimeZone(abbreviation: "EST")
//				dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
//				
//				joinedDate = dateFormatter.date(from: jDate) ?? Date()
//				
//			}
//			
//			var newReferral: String = u.referralcode
//			if newReferral == "" {
//				newReferral = randomString(length: 6)
//			}
//			if u.username == "marcogonzalezhauger" {
//				newReferral = "CTO"
//			}
//			
//			var interests = u.categories!
//			
//			if u.username == "brunogonzalezhauger" {
//				interests = []
//				for _ in 0...9 {
//					var this: String = AllInterests.randomElement()!
//					
//					while interests.contains(this) {
//						this = AllInterests.randomElement()!
//					}
//				
//					interests.append(this)
//				}
//			}
//			
//			interests = interests.filter{AllInterests.contains($0)}
//			if interests.count == 0 {
//				interests.append("Student")
//			}
//				
//			
//			let basic = BasicInfluencer.init(name: u.name!, username: u.username, followerCount: u.followerCount, averageLikes: u.averageLikes ?? 0, profilePicURL: u.profilePicURL ?? "", zipCode: u.zipCode ?? "0", gender: tgender, joinedDate: joinedDate, interests: interests, referralCode: newReferral, flags: flags, followingInfluencers: [], followingBusinesses: [], followedBy: [], birthday: tbday, userId: NewUserID)
//			
//			let inffin = InfluencerFinance.init(balance: u.yourMoney, userId: NewUserID, stripeAccount: stripeAcc)
//			
//			let newInfluencer = Influencer.init(basic: basic, finance: inffin, email: authDict["email"] as! String, password: authDict["password"] as! String, instagramAuthToken: u.authenticationToken, instagramAccountId: u.id, tokenFIR: u.tokenFIR ?? "", userId: NewUserID)
//			
//			newInfluencer.UpdateToFirebase(alsoUpdateToPublic: true, completed: nil)
//			convertedInfluencer.append(newInfluencer)
//		}
//	}
//	print("========[INFLUENCERS FINSIHED, STARTING BUSINESS CONVERSION]=========")
//	
//	Myself = convertedInfluencer.filter{$0.basic.username == "brunogonzalezhauger"}[0]
//	print("Set Myself to \(Myself.basic.name)")
//	
//	var convertedBusinesses: [Business] = []
//	let businessDb = od["companies"] as! [String: Any]
//	let coUserDb = od["CompanyUser"] as! [String: Any]
//	let coDeposits = od["BusinessDeposit"] as! [String: Any]
//	let templateOffers = od["TemplateOffers"] as! [String: Any]
//	var coUsers: [CompanyUser] = []
//	for cu in coUserDb.keys {
//		coUsers.append(CompanyUser.init(dictionary: coUserDb[cu] as! [String: Any]))
//	}
//	
//	for coUser in coUsers {
//		print("Updating Company: \(coUser.email!) (userID: \(coUser.userID!), coUserId: \(coUser.companyID!)) --> New")
//		
//		var co: Company? = nil
//		
//		if let coDict = (businessDb[coUser.userID!] as? [String: Any])?[coUser.companyID!] as? [String: Any] {
//			co = Company.init(dictionary: coDict)
//		}
//		
//		var coDeposit: businessDeposit?
//		if let depositDict = coDeposits[coUser.companyID!] as? [String: Any] {
//			coDeposit = businessDeposit.init(dictionary: depositDict)
//		}
//		
//		let coName: String = makeFirebaseUrl(co?.name ?? "NewCo" + ", " + GetNewID())
//		
//		let testName: String = co?.name ?? ""
//		
//		let NewBusinessID: String = makeFirebaseUrl(coName + ", " + randomString(length: 15))
//		
//		var flags: [String] = []
//		
//		if co?.isForTesting ?? false {
//			flags = ["isForTesting"]
//		}
//		if testName.lowercased().contains("test") {
//			flags = ["isForTesting"]
//		}
//		if testName.lowercased().contains("private limited") {
//			flags = ["isForTesting"]
//		}
//		if testName == "abc" {
//			flags = ["isForTesting"]
//		}
//		if co?.mission == "" {
//			flags.append("isInvisible")
//		}
//		if coUser.email	== "themagiccube.marco@gmail.com" {
//			flags.append("isOfficialAmbassadoor")
//		}
//		
//		let businessFinance = BusinessFinance.init(stripeAccount: nil, log: [], balance: coDeposit?.currentBalance ?? 0, businessId: NewBusinessID)
//		
//		var basicBusiness: [BasicBusiness] = []
//		var active: String = ""
//		if let co = co {
//			basicBusiness = [BasicBusiness.init(name: co.name, logoUrl: co.logo ?? "", mission: co.mission, website: co.website, joinedDate: Date(), referralCode: co.referralcode ?? randomString(length: 6), flags: flags, followedBy: [], businessId: NewBusinessID)]
//			active = basicBusiness[0].basicId
//		}
//		
//		var drafts: [DraftOffer] = []
//		
//		if let theseTemplates = templateOffers[coUser.userID!] as? [String: Any] {
//			
//			for t in theseTemplates.keys {
//				
//				let newDraftId = GetNewID()
//				
//				var templ: TemplateOffer? = nil
//				do {
//					templ = try TemplateOffer.init(dictionary: theseTemplates[t] as! [String: AnyObject])
//				} catch {
//					print(error.localizedDescription)
//				}
//				if let templ = templ {
//					var ps: [DraftPost] = []
//					for p in templ.posts {
//						ps.append(DraftPost.init(businessId: NewBusinessID, draftId: newDraftId, poolId: nil, hash: p.hashtags, keywords: p.keywords, ins: p.instructions))
//					}
//					
//					let newDraftOffer = DraftOffer.init(draftId: newDraftId, businessId: NewBusinessID, mustBeOver21: templ.mustBe21, payIncrease: 1, draftPosts: ps, title: templ.title, lastEdited: templ.lastEdited)
//					drafts.append(newDraftOffer)
//				}
//			}
//		}
//		
//		
//		let newBusiness = Business.init(businessId: NewBusinessID, token: coUser.token ?? "", email: coUser.email ?? "", refreshToken: coUser.refreshToken ?? "", deviceFIRToken: coUser.deviceFIRToken ?? "", referredByUserId: "", referredByBusinessId: "", drafts: drafts, finance: businessFinance, sentOffers: [], basic: basicBusiness, activeBasicId: active)
//		if newBusiness.basics.count != 0 {
//			if newBusiness.basics[0].referralCode == "" {
//				newBusiness.basics[0].referralCode = randomString(length: 6)
//			}
//		}
//		newBusiness.UpdateToFirebase(completed: nil)
//		convertedBusinesses.append(newBusiness)
//	}
//	
//	print("========[BUSINESSES FINSIHED, STARTING OFFERPOOL CONVERSION]=========")
//	
//	var oldPool: [Offer] = []
//	let poolDict = od["OfferPool"] as! [String: Any]
//	for id in poolDict.keys {
//		let coPoolDict = poolDict[id] as! [String : Any]
//		for id2 in coPoolDict.keys {
//			do {
//				oldPool.append(try Offer.init(dictionary: coPoolDict[id2] as! [String : AnyObject]))
//		 } catch {
//			 print("offer creation error here....(x0293)\n\(id)")
//		 }
//		}
//	}
//	for o in oldPool {
//		print("Updating Offer: \"\(o.title)\" --> PoolOffer")
//		var foundIt = false
//		for b in convertedBusinesses {
//			for draft in b.drafts {
//				if !foundIt {
//					if o.posts.count > 0 && draft.draftPosts.count > 0 {
//						if o.posts[0].instructions == draft.draftPosts[0].instructions {
//							var coPoolDict = (poolDict[o.businessAccountID] as! [String : Any])[o.offer_ID] as! [String: Any]
//							
//							var list = o.influencerFilter!["zipCode"] as? [String] ?? []
//							
//							if b.basics[0].name == "Ambassadoor" {
//								o.category.append(Myself.basic.interests.randomElement()!)
//								o.genders.append("Male")
//								list.append("13210")
//							}
//							
//							coPoolDict["acceptedZipCodes"] = list
//							coPoolDict["acceptedInterests"] = o.category
//							coPoolDict["acceptedGenders"] = o.genders
//							coPoolDict["mustBe21"] = o.mustBe21
//							coPoolDict["minimumEngagementRate"] = 0
//							
//							foundIt = true
//							
//							draft.distributeToPool(asBusiness: b, asBasic: b.GetActiveBasicBusiness()!, filter: OfferFilter.init(dictionary: coPoolDict as [String: AnyObject], businessId: b.businessId, basicId: b.GetActiveBasicBusiness()!.basicId), withMoney: o.cashPower!, withDrawFundsFalseForTestingOnly: false) { (success, bizObj) in
//								if let bizObj = bizObj {
//									bizObj.UpdateToFirebase(completed: nil)
//								}
//							}
//						}
//					}
//				}
//			}
//		}
//		
//	}
//	print("========[DOWNLOADING GLOBALS]=========")
//	
//	RefreshPublicData {
//		print("Public data downloaded.")
//	}	
//	
//	//Myself = convertedInfluencer.randomElement()
//	
//	print("Myself variable has been set to \(Myself.basic.name)")
//	
//	print("Done Porting. Database is now up to date with old database.")
//	
//	startListeningToMyself(userId: Myself.userId)
//	
//	StartListeningToPublicData()
//	
//	startListeningToOfferPool()
//	
//	let interestRef = Database.database().reference().child("ReadOnly")
//	interestRef.updateChildValues(["Interests": AllInterests])
//	
//}


