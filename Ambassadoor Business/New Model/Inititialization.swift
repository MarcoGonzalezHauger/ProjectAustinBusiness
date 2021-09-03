//
//  Inititialization.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/31/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

func InitializeAmbassadoorBusiness() {
	
	InitializeZipCodeAPI(completed: nil)
	
	
	getInfluencers {}
    //getBusinesses {}
	//This is for statistics page, other times will include when statistics are manually refreshed.
	
	
    StartListening()
	
}

func StartListening() {
	
	RefreshPublicData {
		print("Public data downloaded.")
	}
	
	//startListeningToMyself(userId: Myself.userId)
	
	StartListeningToPublicData()
	
	startListeningToOfferPool()
	
}

func StartListeningToReadOnly() {
	
}
