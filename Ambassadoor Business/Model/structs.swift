//
//  structs.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//
import Foundation
import UIKit
import CoreData

//Protocol for ACCEPTING offers.
protocol OfferResponse {
	func OfferAccepted(offer: Offer) -> ()
}



//Shadow Class reused all throughout this app.
@IBDesignable
class ShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        DrawShadows()
    }
    override var bounds: CGRect { didSet { DrawShadows() } }
    @IBInspectable var cornerRadius: Float = 10 {    didSet { DrawShadows() } }
    @IBInspectable var ShadowOpacity: Float = 0 { didSet { DrawShadows() } }
    @IBInspectable var ShadowRadius: Float = 1.75 { didSet { DrawShadows() } }
    @IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { DrawShadows() } }
    @IBInspectable var borderWidth: Float = 0.0 { didSet { DrawShadows() }}
	@IBInspectable var borderColor: UIColor = UIColor.black { didSet { DrawShadows() } }
	@IBInspectable var maskToBounds: Int = -1 { didSet { DrawShadows() } }
    
    func DrawShadows() {
        //draw shadow & rounded corners for offer cell
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = ShadowColor.cgColor
        self.layer.shadowOpacity = ShadowOpacity
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = CGFloat(ShadowRadius)
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
		if maskToBounds != -1 {
			self.layer.masksToBounds = maskToBounds == 1
            //self.layer.masksToBounds = false
		} else {
			self.layer.masksToBounds = false
		}
		let rect = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height + 2)
        self.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
}

//Structure for an offer that comes into username's inbox
class Offer: NSObject {
    var offer_ID: String
    var money: Double
    var originalAmount: Double
    var commission: Double?
    var isCommissionPaid: Bool?
    var company: Company?
    var posts: [Post]
    var offerdate: Date
    var user_ID: [String]
    var expiredate: Date
    var allPostsConfirmedSince: Date?
    var isAllPaid: Bool?
    var isRefferedByInfluencer: Bool?
    var isReferCommissionPaid: Bool?
    var referralAmount: Double?
    var referralCommission: Double?
    var referralID: String?
    var allConfirmed: Bool {
        get {
            var areConfirmed = true
            for x : Post in posts {
                if x.isConfirmed == false {
                    areConfirmed = false
                }
            }
            return areConfirmed
        }
    }
    var isAccepted: Bool
    var isExpired: Bool {
        return self.expiredate.timeIntervalSinceNow <= 0
    }
    var ownerUserID: String
    var notify: Bool
    
    var cashPower: Double?
    
    var influencerFilter: [String: AnyObject]?
    
    var incresePay: Double?
    
    var companyDetails: [String: Any]?
    
    var mustBeTwentyOne: Bool?
    
    var accepted: [String]?
    
    
    var debugInfo: String {
        return "Offer by \(company!.name) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
    }
    init(dictionary: [String: AnyObject]) throws {
        
        let err = isDeseralizable(dictionary: dictionary, type: .offer)
        if err.count > 0 {
            throw NSError(domain: err.joined(separator: ", "), code: 101, userInfo: ["class": "Offer Class", "value": dictionary])
        }
        
        self.money = dictionary["money"] as! Double
        self.company = dictionary["company"] as? Company
        
        if let posts = dictionary["posts"] as? [Post]{
           self.posts = posts
        }else{
            
            let posts = parseTemplateOffer(offer: dictionary)
            self.posts = posts
        }
        
        if let _ = dictionary["offerdate"] as? Date{
           self.offerdate = dictionary["offerdate"] as! Date
        }else{
            self.offerdate = DateFormatManager.sharedInstance.getDateFromStringWithAutoFormat(dateString: dictionary["offerdate"] as! String)!
        }
        
        
        //self.offerdate = dictionary["offerdate"] as! Date
        self.user_ID = [String]()
        if let userID = dictionary["user_ID"] as? [String] {
			self.user_ID = userID
        }
        self.offer_ID = dictionary["offer_ID"] as! String
        
        if let _ = dictionary["expiredate"] as? Date{
           self.expiredate = dictionary["expiredate"] as! Date
        }else{
            print(dictionary["expiredate"] as! String)
            self.expiredate = DateFormatManager.sharedInstance.getDateFromStringWithAutoFormat(dateString: dictionary["expiredate"] as! String) ?? Date()
        }
        
        if let allpostCon = dictionary["allPostsConfirmedSince"] as? Date{
           self.allPostsConfirmedSince = allpostCon
        }else{
            self.allPostsConfirmedSince = DateFormatManager.sharedInstance.getDateFromStringWithAutoFormat(dateString: dictionary["allPostsConfirmedSince"] as! String) ?? nil
        }
        self.isAccepted = dictionary["isAccepted"] as! Bool
        self.ownerUserID = dictionary["ownerUserID"] as! String
        self.commission = dictionary["commission"] as? Double
        self.isCommissionPaid = dictionary["isCommissionPaid"] as? Bool ?? false
        self.isAllPaid = dictionary["isAllPaid"] as? Bool ?? false
        self.isRefferedByInfluencer = dictionary["isRefferedByInfluencer"] as? Bool ?? false
        self.isReferCommissionPaid = dictionary["isReferCommissionPaid"] as? Bool ?? false
        self.referralAmount = dictionary["referralAmount"] as? Double ?? 0.0
        self.referralID = dictionary["referralID"] as? String ?? ""
        self.notify = dictionary["notify"] as? Bool ?? false
        self.cashPower = dictionary["cashPower"] as? Double ?? 0.0
        self.referralCommission = dictionary["referralCommission"] as? Double ?? 0.0
        self.influencerFilter = dictionary["influencerFilter"] as? [String: AnyObject] ?? [:]
        self.incresePay = dictionary["incresePay"] as? Double ?? 0.0
        self.companyDetails = dictionary["companyDetails"] as? [String: Any] ?? [:]
        self.mustBeTwentyOne = dictionary["mustBeTwentyOne"] as? Bool ?? false
        self.originalAmount = dictionary["originalAmount"] as? Double ?? 0.0
        
        if let acceptedUsers = dictionary["accepted"] as? [String]{
            var actUers = [String]()
            for accpetedUser in acceptedUsers {
                if !actUers.contains(accpetedUser){
                    actUers.append(accpetedUser)
                }
            }
            self.accepted = actUers
        }else{
            self.accepted = []
        }
    }
}




class TemplateOffer: Offer {
    var targetCategories: [String]
    var category: [String]
    var locationFilter: String
    var genders: [String]
    var user_IDs: [String]
	var title: String
    var status: String
	var lastEdited: Date
	
	func isFinished() -> [String] {
		var returnValue: [String] = []
		if title == "" {
			returnValue.append("title")
		}
		if genders == [] {
			returnValue.append("genders")
		}
		if targetCategories == [] {
			returnValue.append("cats")
		}
		if title == "" {
			returnValue.append("title")
		}
		if self.posts.count == 0 {
			returnValue.append("nopost")
		}
		var postsNotDone: Int = 0
		for p in posts {
			if p.isFinished().count > 0 {
				postsNotDone += 1
			}
		}
		if postsNotDone > 0 {
			returnValue.append("postNotDone")
		}
		return returnValue
	}

    override init(dictionary: [String: AnyObject])throws {
		self.targetCategories = dictionary["targetCategories"] as? [String] ?? []
		self.category = dictionary["category"] as? [String] ?? []
		self.title = dictionary["title"] as? String ?? ""
        self.locationFilter = dictionary["locationFilter"] as? String ?? ""
        self.genders = dictionary["genders"] as? [String] ?? []
        self.user_IDs = dictionary["user_IDs"] as? [String] ?? []
        self.status = dictionary["status"] as? String ?? ""
		self.lastEdited = FirebaseToDate(object: dictionary["lastEditDate"])
        try super.init(dictionary: dictionary)
    }
	
	func GetSummary() -> String {
		var lines: [String] = []
		if self.posts.count == 1 {
			lines.append("This Offer has 1 Post.")
		} else if self.posts.count == 0 {
			lines.append("This Offer doesn't have posts yet.")
		} else {
			lines.append("This Offer has \(self.posts.count) Posts:")
		}
		var index = 1
		for post in self.posts {
			lines.append("• Post #\(index): \(post.GetSummary(maxItems: 2))")
			index += 1
		}
		lines.append("")
		lines.append("Has been sent to \(user_IDs.count) influencer\(user_IDs.count != 1 ? "s" : "").")
		return lines.joined(separator: "\n")
	}
}

//Strcuture for users
class User: NSObject {
    
	let name: String?
	let username: String
	let followerCount: Double
	let profilePicURL: String?
	let averageLikes: Double?
	var zipCode: String?
	let id: String
	var gender: String?
	//var gender: Gender?
	var isBankAdded: Bool
	var joinedDate: String?
	var categories: [String]?
	var referralcode: String
	var accountBalance: Double?
	var isDefaultOfferVerify: Bool
	var priorityValue: Int?
    var tokenFIR: String?
	
	init(dictionary: [String: Any]) {
		self.name = dictionary["name"] as? String
		self.username = dictionary["username"] as! String
		self.followerCount = dictionary["followerCount"] as! Double
		if (dictionary["profilePicture"] as? String ?? "") == "" {
			self.profilePicURL = nil
		} else {
			self.profilePicURL = dictionary["profilePicture"] as? String
		}
		self.averageLikes = dictionary["averageLikes"] as? Double
		self.zipCode = dictionary["zipCode"] as? String
		self.id = dictionary["id"] as! String
		self.gender = dictionary["gender"] as? String
		//self.gender = dictionary["gender"] as? Gender
		self.isBankAdded = dictionary["isBankAdded"] as! Bool
		self.joinedDate = dictionary["joinedDate"] as? String
		self.categories = dictionary["categories"] as? [String]
		
		self.accountBalance = dictionary["yourMoney"] as? Double
		self.referralcode = dictionary["referralcode"] as? String ?? ""
		self.isDefaultOfferVerify = dictionary["isDefaultOfferVerify"] as? Bool ?? false
		self.priorityValue = dictionary["priorityValue"] as? Int
        self.tokenFIR = dictionary["tokenFIR"] as? String ?? ""
	}
	
	func GetSummary() -> String {
		return "\(username): with \(followerCount) followers. ZIP: \(zipCode ?? "nil")."
	}
}

//Structure for post
struct Post {
    let image: String?
    let instructions: String
    let captionMustInclude: String?
    let products: [Product]?
    var post_ID: String
    let PostType: String
    //let PostType: TypeofPost
    var confirmedSince: Date?
    var isConfirmed: Bool
    var hashCaption: String
    var status: String
	var hashtags: [String]
	var keywords: [String]
    var isPaid: Bool?
    var PayAmount: Double?
    
	func isFinished() -> [String] {
		var returnValue: [String] = []
		if instructions == "" {
			returnValue.append("instructions")
		}
		if hashtags == [] && keywords == [] {
			returnValue.append("hash and keywords")
		}
		if hashtags.contains("") {
			returnValue.append("empty hash")
		}
		if keywords.contains("") {
			returnValue.append("empty keyword")
		}
		return returnValue
	}
	
	func GetSummary(maxItems: Int = 5) -> String {
		var all = /*--->*/ [String](/*GROSS*/) //ew ~Marco Jan 18 2020
		for p in keywords {
			all.append("\"\(p)\"")
		}
		for h in hashtags {
			all.append("#\(h)")
		}
		
		if all.count == 0 {
			if maxItems == 5 {
				return "Post"
			} else {
				return "Incomplete Post"
			}
		} else {
			
			var str = ""
			for i in 0...(all.count - 1) {
				if i < maxItems {
					str += all[i] + ", "
				}
			}
			str = String(str.dropLast(2))
			return str
		}
	}
	
}

struct PostInfo{
    var imageUrl: String?
    var userWhoPosted: User?
    var associatedPost: Post?
    var caption: String?
    var datePosted: String?
    var userId: String?
    var offerId: String?
}

class InfluencerInstagramPost: NSObject {
    var caption: String
    var id: String?
    var images: String?
    var like_count: Int?
    var status: String
    var timestamp: String
    var type: String?
    var username: String
    
    init(dictionary: [String: AnyObject]) {
        self.caption = dictionary["caption"] as! String
        self.id = dictionary["id"] as? String ?? ""
        self.images = dictionary["images"] as? String ?? ""
        self.like_count = dictionary["like_count"] as? Int ?? 0
        self.status = dictionary["status"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }
}

//struct for product
class Product: NSObject {
    var product_ID: String?
    var image: String?
    var name: String
    var price: Double
    var buy_url: String?
    var color: String
    
    init(dictionary: [String: Any]) {
        self.product_ID = (dictionary["product_ID"] as? String)!
        self.image = dictionary["image"] as? String
        self.name = (dictionary["name"] as? String)!
        self.price = (dictionary["price"] as? Double)!
        self.buy_url = dictionary["buy_url"] as? String
        self.color = dictionary["color"] as! String
     }
}

//struct for company
class Company: NSObject {
    var userID: String?
    let account_ID: String?
    var name: String
    var logo: String?
    var mission: String
    var website: String
	let owner_email: String
    let companyDescription: String
    var accountBalance: Double
    var referralcode: String?
    
    
    
    init(dictionary: [String: Any]) {
		self.account_ID = dictionary["account_ID"] as? String
		self.name = dictionary["name"] as! String
		self.logo = dictionary["logo"] as? String
		self.mission = dictionary["mission"] as! String
		self.website = dictionary["website"] as! String
		self.owner_email = (dictionary["owner"] as? String) ?? ""
		self.companyDescription = dictionary["description"] as! String
		self.accountBalance = dictionary["accountBalance"] as! Double
		self.referralcode = dictionary["referralcode"] as? String
        self.userID = dictionary["userId"] as? String ?? ""
    }
}

//struct for complany user
class CompanyUser: NSObject {
    var userID: String?
    var token: String?
    var email: String?
    var refreshToken: String?
    var isCompanyRegistered: Bool?
    var companyID: String?
    var deviceFIRToken: String?
    var businessReferral: String?
    
    init(dictionary: [String: Any]) {
        
        self.userID = dictionary["userID"] as? String
        self.token = dictionary["token"] as? String
        self.email = dictionary["email"] as? String
        self.refreshToken = dictionary["refreshToken"] as? String
        self.isCompanyRegistered = dictionary["isCompanyRegistered"] as? Bool
        self.companyID = dictionary["companyID"] as? String
        self.deviceFIRToken = dictionary["deviceFIRToken"] as? String ?? ""
        self.businessReferral = dictionary["businessReferral"] as? String ?? ""
    }
}

//Deposit Amount & Details of business user

class Deposit: NSObject {
    var userID: String?
    var currentBalance: Double?
    var totalDepositAmount: Double?
    var totalDeductedAmount: Double?
    var lastDeductedAmount: Double?
    var lastDepositedAmount: Double?
    var lastTransactionHistory: TransactionDetails?
    var depositHistory: [Any]?
    
    init(dictionary: [String: Any]) {
        
        self.userID = dictionary["userID"] as? String
        self.currentBalance = dictionary["currentBalance"] as? Double
        self.totalDepositAmount = dictionary["totalDepositAmount"] as? Double
        self.totalDeductedAmount = dictionary["totalDeductedAmount"] as? Double
        self.lastDeductedAmount = dictionary["lastDeductedAmount"] as? Double
        self.lastDepositedAmount = dictionary["lastDepositedAmount"] as? Double
        self.lastTransactionHistory = TransactionDetails.init(dictionary: dictionary["lastTransactionHistory"] as! [String : Any])
        self.depositHistory = dictionary["depositHistory"] as? [Any]
        
    }
    
}

class Statistics: NSObject {
    
    var offerID: String = ""
    var userID: String = ""
    var offer: NSDictionary? = nil
    
}

class instagramOfferDetails: NSObject {
    
    var userID: String = ""
    var likesCount: Int = 0
    var commentsCount: Int = 0
    var userInfo: NSDictionary? = nil
    
}

class DwollaCustomerInformation: NSObject {
    
    var acctID = ""
    var firstName = ""
    var lastName = ""
    var customerURL = ""
    var customerFSURL = ""
    var isFSAdded = false
    var mask = ""
    var name = ""
    
}

class DwollaCustomerFSList: NSObject {
    
    var acctID = ""
    var firstName = ""
    var lastName = ""
    var customerURL = ""
    var customerFSURL = ""
    var isFSAdded = false
    var mask = ""
    var name = ""
    
        init(dictionary: [String: Any]) {
    
            self.acctID = dictionary["accountID"] as! String
            self.firstName = dictionary["firstname"] as! String
            self.lastName = dictionary["lastname"] as! String
            self.customerURL = dictionary["customerURL"] as! String
            self.customerFSURL = dictionary["customerFSURL"] as! String
            self.isFSAdded = dictionary["isFSAdded"] as! Bool
            self.mask = dictionary["mask"] as! String
            self.name = dictionary["name"] as! String
        }
    
}

class TransactionInfo: NSObject {
    
    var acctID = ""
    var firstName = ""
    var lastName = ""
    var customerURL = ""
    var customerFSURL = ""
    var mask = ""
    var name = ""
    var transactionURL = ""
    var amount = ""
    var currency = ""
    
    init(dictionary: [String: Any]) {
        
        self.acctID = dictionary["accountID"] as! String
        self.firstName = dictionary["firstname"] as! String
        self.lastName = dictionary["lastname"] as! String
        self.customerURL = dictionary["customerURL"] as! String
        self.customerFSURL = dictionary["FS"] as! String
        self.mask = dictionary["mask"] as! String
        self.name = dictionary["name"] as! String
        self.transactionURL = dictionary["transferURL"] as! String
        self.amount = dictionary["amount"] as! String
        self.currency = dictionary["currency"] as! String
    }
    
}

class TransactionDetails: NSObject {
    var id: String?
    var status: String?
    var type: String?
    var currencyIsoCode: String?
    var amount: String?
    var commission: Double?
    var createdAt: String?
    var updatedAt: String?
    var transactionType: String?
    var cardDetails: Any?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.status = dictionary["status"] as? String
        self.type = dictionary["type"] as? String
        self.currencyIsoCode = dictionary["currencyIsoCode"] as? String
        self.amount = dictionary["amount"] as? String
        self.createdAt = dictionary["createdAt"] as? String
        self.updatedAt = dictionary["updatedAt"] as? String
        self.commission = dictionary["commission"] as? Double
        if dictionary.keys.contains("creditCard") {
            if dictionary["creditCard"] != nil {
                self.cardDetails = dictionary["creditCard"]
            }
        }else if dictionary.keys.contains("paypalAccount") {
            if dictionary["creditCard"] != nil {
                self.cardDetails = dictionary["paypalAccount"]
            }
        }else if dictionary.keys.contains("cardDetails") {
            if dictionary["cardDetails"] != nil {
                self.cardDetails = dictionary["cardDetails"]
            }
        }else if dictionary.keys.contains("paidDetails") {
            if dictionary["paidDetails"] != nil {
                self.cardDetails = dictionary["paidDetails"]
            }
        }
        
    }
    
}

//Carries personal info only avalible to view and edit by the user.
struct PersonalInfo {
    let gender: Gender?
    let accountBalance: Int?
}

enum IncreasePayVariable:Double {
    
    case None = 1.0, Five = 1.05, Ten = 1.1, Twenty = 1.2
}

enum Gender {
    case male, female, other
}

enum TypeofPost {
    case SinglePost, MultiPost, Story
}

struct Section {
    var categoryTitle: categoryClass!
    var categoryData: [String]!
    var expanded: Bool!
    var selectedAll: Bool!
    init(categoryTitle: categoryClass, categoryData: [String], expanded: Bool, selected: Bool) {
        self.categoryTitle = categoryTitle
        self.categoryData = categoryData
        self.expanded = expanded
        self.selectedAll = selected
    }
}

class CachedImages: NSObject {
    var link: String?
    var imagedata: Data?
    var object: NSManagedObject?
    var date: Date?
    
    init(object: NSManagedObject) {
        self.link = (object.value(forKey: "url") as! NSString) as String
        self.imagedata = (object.value(forKey: "imagedata") as! Data)
        self.date = (object.value(forKey: "updatedDate") as? Date ?? Date.getcurrentESTdate())
        self.object = object
    }
}
