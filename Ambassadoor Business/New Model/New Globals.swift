//
//  New Globals.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

var Myself: Influencer!
var MyCompany: Business!

var globalBasicInfluencers: [BasicInfluencer] = []
var globalBasicBusinesses: [BasicBusiness] = []
var globalBasicBoth: [Any] = []
var offerPool: [PoolOffer] = []
var withdrawFee: Double = 4

let globalPoolOfferHeight: CGFloat = 195

let globalCornerRadius: Float = 8

var thisUserIsForTesting: Bool {
	get {
		if let me = Myself {
			return me.basic.checkFlag("isForTesting")
		}
		return false
	}
}

func GetNewID() -> String {
	return Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss") + ", " + randomString(length: 15)
}

