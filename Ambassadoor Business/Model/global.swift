//
//  global.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/11/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

//Allows any ViewController to add itself to the global as a delegate,
//and get updated whenever there is a change to any of the global variables.
//This is used in the offers and social pages.
@objc protocol GlobalListener {
    @objc optional func TemplateOffersChanged() -> ()
    @objc optional func SocialDataChanged() -> ()
    @objc optional func OffersForUserChanged() -> ()
}

class CentralVariables {
    
    //The offers that are currently in the users inbox.
	
    var TemplateOffers: [Offer] = [] { didSet {
			EachListener(){ if let targetfunction = $0.TemplateOffersChanged{ targetfunction()}}
		}}
	
    //The offers the user has completed.
    var SocialData: [User] = [] { didSet {
        EachListener(){ if let targetfunction = $0.SocialDataChanged{ targetfunction()}}}}
    
    //Offers tied to a User
    var OffersForUser: [Offer] = [] { didSet { EachListener(){ if let targetfunction = $0.OffersForUserChanged{ targetfunction()}}}}
    
    //Every VC that is connected to this global variable.
    func EachListener(updatefor: (_ Listener: GlobalListener) -> ()) {
        for x : GlobalListener in delegates {
            updatefor(x)
        }
    }
    var delegates: [GlobalListener] = []
	
	
	//Passive Variables. No option to listen for change.
    //MARK: Only Once Product will be loaded and used to entire app
    var products: [Product] = []
	var OfferDrafts: [TemplateOffer] = []
    
    
    var influencers: [User] = []
    
    //MARK: To Edit, Reuse and Add new Post globbally in AddOfferVC, AddPostVC & DistributeOffer
    var post: [Post] = []
    
    //MARK: Business user can increment the user's pay through Increase Pay while Distributing Offer. loading IncreasePay Array to pick Increase Pay while Distributing Offer(DistributeVC).
    var IncreasePay = ["None", "+5%", "+10%", "+20%"]
    
    //MARK: Not Used
    var dwollaCustomerInformation = DwollaCustomerInformation()
    
    var deviceFIRToken = ""
    
    var cachedImageList = [CachedImages]()
    var distributedOffers = [OfferStatistic]()
    
    var launchWay = ""
    
    var allInfluencers = [User]()
	
}

let global = CentralVariables()


