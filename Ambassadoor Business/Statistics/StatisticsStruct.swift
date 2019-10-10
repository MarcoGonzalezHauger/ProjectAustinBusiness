//
//  StatisticsStruct.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 10/1/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UIKit

//Refer to Ambassadoor Documentation on use cases.

struct StatInfluencer {
	var username: String
	var OfferStatus: String
}

struct StatisticsStruct {
	var TotalLikes: Double
	var TotalComments: Double
	var influencers: [StatInfluencer]
}
