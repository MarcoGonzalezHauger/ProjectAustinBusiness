//
//  Offer Distribution Functions.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

extension DraftOffer {
	func distributeToPool(asBusiness: Business, asBasic: BasicBusiness, filter: OfferFilter, withMoney: Double, withDrawFundsFalseForTestingOnly withdrawFunds: Bool, completed: @escaping (_ failedReason: String, _ newBusinessWithChanges: Business?) -> ()) {
		if withdrawFunds && asBusiness.finance.balance < withMoney - 0.01 {
			completed("You do not enough money to distribute this offer.", nil)
			return
		}
		let newPoolOffer = PoolOffer.init(draftOffer: self, filter: filter, withMoney: withMoney, createdBy: asBusiness, sentFromBasicId: asBasic)
		newPoolOffer.UpdateToFirebase { (error) in
			if !error {
				asBusiness.sentOffers.append(sentOffer.init(poolId: newPoolOffer.poolId, draftOfferId: self.draftId, businessId: self.businessId, title: self.title, basicId: asBasic.basicId))
				if withdrawFunds {
					asBusiness.finance.balance -= withMoney
					if asBusiness.finance.balance < 0 {
						asBusiness.finance.balance = 0
					}
				}
				completed("", asBusiness)
				asBusiness.UpdateToFirebase(completed: nil)
			} else {
				completed("There was an network error.", nil)
			}
		}
	}
}

extension PoolOffer {
	func acceptThisOffer(asInfluencer thisInfluencer: Influencer, completed: @escaping (_ failedReason: String) -> ()) {
		
		for p in thisInfluencer.inProgressPosts {
			if p.PoolOfferId == self.poolId {
				completed("You already accepted this offer.")
			} else if p.draftOfferId == self.draftOfferId {
				completed("You already accepted this offer.")
			}
		}
		
		let costPerPost = self.pricePerPost(forInfluencer: thisInfluencer.basic)
		let totalCost = self.totalCost(forInfluencer: thisInfluencer.basic)
		
		if totalCost > self.cashPower {
			completed("There isn't enough money in this offer to afford your fee. (\(NumberToPrice(Value: totalCost)))")
		} else {
			if !self.filter.DoesInfluencerPassFilter(basicInfluencer: thisInfluencer.basic) {
				completed("You don't meet the filters of this offer.")
			} else {
				
				let newCashPower = roundPriceDown(price: self.cashPower - totalCost)
				
				var newAccUserIds: [String] = self.acceptedUserIds
				
				if self.hasInfluencerAccepted(influencer: thisInfluencer) {
					completed("You already accepted this offer.")
				} else {
					newAccUserIds.append(thisInfluencer.userId)
				}
				
				var newPosts: [InProgressPost] = [] // we do this before updating cashPower, because if the app crahses while compiling a list of new draftposts AFTER the money has been withdrawn, that would be a huge problem.
				
				for p in self.draftPosts {
					let newInP = InProgressPost.init(draftPost: p, comissionUserId: self.comissionUserId, comissionBusinessId: self.comissionBusinessId, userId: thisInfluencer.userId, poolOfferId: self.poolId, businessId: self.businessId, draftOfferId: self.draftOfferId, cashValue: costPerPost, basicId: basicId)
					newPosts.append(newInP)
				}
				
				let ref = Database.database().reference().child(poolPath)
				ref.updateChildValues(["cashPower": newCashPower, "acceptedUserIds": newAccUserIds]) { (err, dataref) in
					if err == nil {
						self.cashPower = newCashPower
						self.acceptedUserIds = newAccUserIds
						thisInfluencer.inProgressPosts.append(contentsOf: newPosts)
						thisInfluencer.UpdateToFirebase(alsoUpdateToPublic: false, completed: nil)
						completed("")
					} else {
						completed("A network error prevented you from accepting this offer.")
					}
				}
			}
		}
	}
}
