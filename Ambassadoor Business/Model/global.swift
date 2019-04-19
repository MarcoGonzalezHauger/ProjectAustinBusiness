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
    @objc optional func AvaliableOffersChanged() -> ()
    @objc optional func RejectedOffersChanged() -> ()
    @objc optional func AcceptedOffersChanged() -> ()
    @objc optional func CompletedOffersChanged() -> ()
    @objc optional func SocialDataChanged() -> ()
    @objc optional func OffersForUserChanged() -> ()
}

class CentralVariables {
    
    //The offers that are currently in the users inbox.
    var AvaliableOffers: [Offer] = [] { didSet {
        UIApplication.shared.applicationIconBadgeNumber = AvaliableOffers.count
        AvaliableOffers = AvaliableOffers.sorted{ (Offer1, Offer2) -> Bool in
            return (Offer1.money / Double(Offer1.posts.count)) > (Offer2.money / Double(Offer2.posts.count))    }
        EachListener(){ if let targetfunction = $0.AvaliableOffersChanged { targetfunction()}}}}
    
    //The offers that the user has rejected.
    var RejectedOffers: [Offer] = [] { didSet { EachListener(){ if let targetfunction = $0.RejectedOffersChanged { targetfunction()}}}}
    
    //The offers that the user has accepted.
    var AcceptedOffers: [Offer] = [] { didSet {    EachListener() { if let targetfunction = $0.AcceptedOffersChanged { targetfunction()}}}
    }
    
    //The offers the user has completed.
    var CompletedOffers: [Offer] = [] {    didSet { EachListener(){ if let targetfunction = $0.CompletedOffersChanged { targetfunction()}}}}
    
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


