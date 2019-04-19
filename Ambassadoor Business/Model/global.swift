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
	
    var AvaliableOffers: [Offer] = [] { didSet {
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
}

let global = CentralVariables()


