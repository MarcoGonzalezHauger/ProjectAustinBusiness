//
//  Business Structs.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/24/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

//MARK: Main Class

class Business {
	
	var isCompanyRegistered: Bool {
		get {
			return basics.count != 0
		}
	}
	
	//subclasses
	var drafts: [DraftOffer]
	var finance: BusinessFinance
	var basics: [BasicBusiness]
	var sentOffers: [sentOffer]
	
	//variables
	var businessId: String
	var token: String
	var email: String
	var refreshToken: String
	var deviceFIRToken: String
	var referredByUserId: String?
	var referredByBusinessId: String?
	var activeBasicId: String
		
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
		
		businessId = d["businessId"] as! String
		token = d["token"] as! String
		email = d["email"] as! String
		refreshToken = d["refreshToken"] as! String
		deviceFIRToken = d["deviceFIRToken"] as! String
		
		referredByUserId = d["referredByUserId"] as? String
		referredByBusinessId = d["referredByBusinessId"] as? String
		
		activeBasicId = d["activeBasicId"] as! String
		
		basics = []
		if let basicDict = d["basics"] as? [String: Any] {
			for b in basicDict.keys {
				let thisBasic = BasicBusiness.init(dictionary: basicDict[b] as! [String: Any], basicId: b)
				basics.append(thisBasic)
			}
		}
		
		finance = BusinessFinance.init(dictionary: d["finance"] as! [String: Any], businessId: businessId)
		
		drafts = []
		if let draftDict = d["drafts"] as? [String: Any] {
			for draftId in draftDict.keys {
				drafts.append(DraftOffer.init(dictionary: draftDict[draftId] as! [String: Any], businessId: businessId, draftId: draftId))
			}
		}
		
		sentOffers = []
		if let sentOffersDict = d["sentOffers"] as? [String: Any] {
			for sentOfferId in sentOffersDict.keys {
				sentOffers.append(sentOffer.init(dictionary: sentOffersDict[sentOfferId] as! [String: Any], businessId: businessId, sentOfferId: sentOfferId))
			}
		}
		
	}
	
	init(businessId: String, token: String, email: String, refreshToken: String, deviceFIRToken: String, referredByUserId: String, referredByBusinessId: String, drafts: [DraftOffer], finance: BusinessFinance, sentOffers: [sentOffer], basic: [BasicBusiness], activeBasicId: String) {
		
		self.businessId = businessId
		self.token = token
		self.email = email
		self.refreshToken = refreshToken
		self.deviceFIRToken = deviceFIRToken
		self.referredByUserId = referredByUserId
		self.referredByBusinessId = referredByBusinessId
		
		self.drafts = drafts
		self.finance = finance
		self.basics = basic
		self.sentOffers = sentOffers
		self.activeBasicId = activeBasicId
		
	}
	
	// To Diciontary Function
		
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["finance"] = finance.toDictionary()
		
		if basics.count != 0 {
			var basicDict: [String: Any] = [:]
			for b in basics {
				basicDict[b.basicId] = b.toDictionary()
			}
			d["basics"] = basicDict
		}
		
		if let referredByUserId = referredByUserId {
			d["referredByUserId"] = referredByUserId
		}
		if let referredByBusinessId = referredByBusinessId {
			d["referredByBusinessId"] = referredByBusinessId
		}
		
		if drafts.count != 0 {
			var draftDictionary: [String: Any] = [:]
			for draft in drafts {
				draftDictionary[draft.draftId] = draft.toDictionary()
			}
			d["drafts"] = draftDictionary
		}
		
		if sentOffers.count != 0 {
			var sentOffersDictionary: [String: Any] = [:]
			for sentOffer in sentOffers {
				sentOffersDictionary[sentOffer.sentOfferId] = sentOffer.toDictionary()
			}
			d["sentOffers"] = sentOffersDictionary
		}
		
		d["businessId"] = businessId
		d["token"] = token
		d["email"] = email
		d["refreshToken"] = refreshToken
		d["deviceFIRToken"] = deviceFIRToken
		d["activeBasicId"] = activeBasicId
		
		return d
	}
}

//MARK: Subclasses

class BasicBusiness {
	var name: String
	var logoUrl: String
	var mission: String
	var website: String
	var joinedDate: Date
	var referralCode: String
	var flags: [String]
	var followedBy: [String]
	
	var businessId: String
	var basicId: String
    var type: BusinessType
    var locations: [String]
	
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
    
    func GetLocationZips() -> [String] {
        
        var zipCodes = [String]()
        
        for location in self.locations {
            let commaSeparate = location.components(separatedBy: ",")
            let zipComma = commaSeparate.filter { (loc) -> Bool in
                return zipcodes.contains(loc)
            }
            zipCodes.append(contentsOf: zipComma)
            
            let spaceSeparate = location.components(separatedBy: " ")
            let zipSpace = spaceSeparate.filter { (loc) -> Bool in
                return zipcodes.contains(loc)
            }
            zipCodes.append(contentsOf: zipSpace)
        }
        
        return zipCodes
        }
	
    init(name: String, logoUrl: String, mission: String, website: String, joinedDate: Date, referralCode: String, flags: [String], followedBy: [String], businessId: String, locations: [String], type: BusinessType) {
		
		self.businessId = businessId
		
		self.basicId = makeFirebaseUrl(name + " " + GetNewID())
		
		self.name = name
		self.logoUrl = logoUrl
		self.mission = mission
		self.website = website
		self.joinedDate = joinedDate
		self.referralCode = referralCode
		self.flags = flags
		self.followedBy = followedBy
        self.type = type
        self.locations = locations
		
	}
	
	init(dictionary d: [String: Any], basicId bid: String) {
		basicId = bid
		
		businessId = d["businessId"] as! String
		name = d["name"] as! String
		logoUrl = d["logoUrl"] as! String
		mission = d["mission"] as! String
		website = d["website"] as! String
		joinedDate = (d["joinedDate"] as! String).toUDate()
		referralCode = d["referralCode"] as! String
		flags = d["flags"] as? [String] ?? []
		followedBy = d["followedBy"] as? [String] ?? []
        let type = d["type"] as? String ?? (BusinessType.getAllType().first!.rawValue)
        self.type = BusinessType(rawValue: type)!
        locations = d["locations"] as? [String] ?? []
	}
	
	// To Diciontary Function
	
	func toDictionary() -> [String: Any] {
		var d: [String: Any] = [:]
		
		d["name"] = name
		d["logoUrl"] = logoUrl
		d["mission"] = mission
		d["website"] = website
		d["joinedDate"] = joinedDate.toUString()
		d["referralCode"] = referralCode
		d["flags"] = flags
		d["followedBy"] = followedBy
		d["businessId"] = businessId
        d["type"] = self.type.rawValue
        d["locations"] = self.locations
		return d
	}
}

class BusinessFinance {
	
	var hasStripeAccount: Bool {
		get {
			return stripeAccount != nil
		}
	}
	
	var stripeAccount: StripeAccountInformation?
	var log: [BusinessTransactionLogItem]
	
	var balance: Double
	var businessId: String
	
	init(stripeAccount: StripeAccountInformation?, log: [BusinessTransactionLogItem], balance: Double, businessId: String) {
		self.stripeAccount = stripeAccount
		self.log = log
		self.balance = balance
		self.businessId = businessId
		
	}
	
	init(dictionary d: [String: Any], businessId id: String) {
		businessId = id
		
		log = []
		if let thisLog = d["log"] as? [String: Any] {
			for logItem in thisLog.keys {
				let thisLogItem = thisLog[logItem] as! [String : Any]
				log.append(BusinessTransactionLogItem(dictionary: thisLogItem, businessId: businessId, transactionId: logItem))
			}
		}
		
		if let thisStripeAccount = d["stripeAccount"] as? [String: Any] {
			stripeAccount = StripeAccountInformation(dictionary: thisStripeAccount, userOrBusinessId: id)
		}
		
		balance = d["balance"] as! Double
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

class BusinessTransactionLogItem {
	var value: Double
	var time: Date
	var type: String //acceptable values: creditCardDeposit, withdrawedToStripe, ambver, sentOffer, tookBackOffer, addedOfferFunds
	
	var transactionId: String
	var businessId: String
	
	init(dictionary d: [String: Any], businessId id: String, transactionId tID: String) {
		businessId = id
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
