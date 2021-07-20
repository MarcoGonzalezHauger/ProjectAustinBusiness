//
//  UpdateToFirebase Ext.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension PoolOffer {
	var poolPath: String {
		get {
			return "Pool/\(self.poolId)"
		}
	}
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(poolPath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
	}
}

extension Business {
	
	var privatePath: String {
		get {
			return "Accounts/Private/Businesses/\(self.businessId)"
		}
	}
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(privatePath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
		for b in self.basics {
			b.UpdateToFirebase(completed: nil)
		}
	}
    
}

extension BasicBusiness {
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(publicPath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
	}
	
	var publicPath: String {
		get {
			return "Accounts/Public/Businesses/\(self.basicId)"
		}
	}
}

extension Influencer {
	
	var privatePath: String {
		get {
			return "Accounts/Private/Influencers/\(self.userId)"
		}
	}
	
	func UpdateToFirebase(alsoUpdateToPublic: Bool, completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(privatePath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
		if alsoUpdateToPublic {
			self.basic.UpdateToFirebase(completed: {_ in })
		}
	}
}

extension BasicInfluencer {
	
	var publicPath: String {
		get {
			return "Accounts/Public/Influencers/\(self.userId)"
		}
	}
    
    var privatePath: String {
        get {
            return "Accounts/Private/Influencers/\(self.userId)/basic"
        }
    }
	
	func UpdateToFirebase(completed: ((_ success: Bool) -> ())?) {
		let ref = Database.database().reference().child(publicPath)
		ref.updateChildValues(self.toDictionary()) { (err, dataref) in
			completed?(err != nil)
		}
        
        let refPrivate = Database.database().reference().child(privatePath)
        refPrivate.updateChildValues(["followedBy":self.followedBy]) { (err, dataref) in
            completed?(err != nil)
        }
        
	}
}

extension DraftOffer{
    
    var pathString: String{
        get{
            return "Pool"
        }
    }
    
    
    func getDraftFromPool(completed: ((_ success: Bool) -> ())?) {
        let ref = Database.database().reference().child(pathString).queryOrdered(byChild: "draftOfferId").queryEqual(toValue: self.draftId)
        ref.observeSingleEvent(of: .value) { snap in
            completed?(snap.exists())
        } withCancel: { error in
            completed?(false)
        }

    }
    
}
