//
//  structs.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//
import Foundation
import UIKit

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
    @IBInspectable var ShadowOpacity: Float = 0.2 { didSet { DrawShadows() } }
    @IBInspectable var ShadowRadius: Float = 1.75 { didSet { DrawShadows() } }
    @IBInspectable var ShadowColor: UIColor = UIColor.black { didSet { DrawShadows() } }
    @IBInspectable var borderWidth: Float = 0.0 { didSet { DrawShadows() }}
    @IBInspectable var borderColor: UIColor = UIColor.black { didSet { DrawShadows() }}
    //    @IBInspectable
    //    var borderWidth: CGFloat {
    //        get {
    //            return layer.borderWidth
    //        }
    //        set {
    //            layer.borderWidth = newValue
    //        }
    //    }
    //
    //    @IBInspectable
    //    var borderColor: UIColor? {
    //        get {
    //            if let color = layer.borderColor {
    //                return UIColor(cgColor: color)
    //            }
    //            return nil
    //        }
    //        set {
    //            if let color = newValue {
    //                layer.borderColor = color.cgColor
    //            } else {
    //                layer.borderColor = nil
    //            }
    //        }
    //    }
    
    func DrawShadows() {
        //draw shadow & rounded corners for offer cell
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = ShadowColor.cgColor
        self.layer.shadowOpacity = ShadowOpacity
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = CGFloat(ShadowRadius)
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
}

//Structure for an offer that comes into username's inbox
class Offer: NSObject {
    var offer_ID: String
    var money: Double
    var company: Company?
    var posts: [Post]
    var offerdate: Date
    var user_ID: [String]
    var expiredate: Date
    var allPostsConfirmedSince: Date?
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
    
    var debugInfo: String {
        return "Offer by \(company!.name) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
    }
    init(dictionary: [String: AnyObject]) {
        self.money = dictionary["money"] as! Double
        self.company = dictionary["company"] as? Company
        self.posts = dictionary["posts"] as! [Post]
        self.offerdate = dictionary["offerdate"] as! Date
        self.user_ID = [String]()
        if let userID = dictionary["user_ID"] as? [String] {
			self.user_ID = userID
        }
        self.offer_ID = dictionary["offer_ID"] as! String
        self.expiredate = dictionary["expiredate"] as! Date
        self.allPostsConfirmedSince = dictionary["allPostsConfirmedSince"] as? Date
        self.isAccepted = dictionary["isAccepted"] as! Bool
        self.ownerUserID = dictionary["ownerUserID"] as! String
    }
}

class TemplateOffer: Offer {
    var targetCategories: [Category]
    var category: [String]
    var zipCodes: [String]
    var genders: [String]
    var user_IDs: [String]
	var title: String
    var status: String
    

    override init(dictionary: [String: AnyObject]) {
        self.targetCategories = []
        if let tcs = dictionary["targetCategories"] as? [Category] {
            self.targetCategories = tcs
        } else {
            for cat in dictionary["targetCategories"] as! [String] {
                if let c = Category.init(rawValue: cat) {
                    self.targetCategories.append(c)
                } else {
                    self.targetCategories.append(.Other)
                }
            }
        }
        self.category = dictionary["category"] as! [String]
		self.title = dictionary["title"] as! String
        self.zipCodes = dictionary["zipCodes"] as! [String]
        self.genders = dictionary["genders"] as! [String]
        self.user_IDs = dictionary["user_IDs"] as? [String] ?? []
        self.status = dictionary["status"] as! String
        super.init(dictionary: dictionary)
    }
}

//Strcuture for users
class User: NSObject {
    
    var id: String?
    var name: String?
    var username: String
    var followerCount: Double
    var profilePicURL: String?
    var primaryCategory: Category
    var SecondaryCategory: Category?
    var averageLikes: Double?
    var zipCode: String?
    var gender: String?
    var accountBalance: Double?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.username = dictionary["username"] as! String
        self.followerCount = dictionary["followerCount"] as! Double
        if (dictionary["profilePicURL"] as? String ?? "") == "" {
            self.profilePicURL = nil
        } else {
            self.profilePicURL = dictionary["profilePicURL"] as? String
        }
		if let pc = dictionary["primaryCategory"] as? Category {
            self.primaryCategory = pc
        } else {
            if let pc = Category.init(rawValue: dictionary["primaryCategory"] as? String ?? "") {
                self.primaryCategory = pc
            } else {
                self.primaryCategory = .Other
            }
        }
        
        if let sc = dictionary["secondaryCategory"] as? Category {
            self.SecondaryCategory = sc
        } else {
            if let sc = Category.init(rawValue: dictionary["secondaryCategory"] as? String ?? "") {
                self.SecondaryCategory = sc
            } else {
                self.SecondaryCategory = nil
            }
        }
        
        self.averageLikes = dictionary["averageLikes"] as? Double
        self.zipCode = dictionary["zipCode"] as? String
        self.gender = dictionary["gender"] as? String
        self.accountBalance = dictionary["accountBalance"] as? Double
    }
    
    override var description: String {
        return "NAME: \(name ?? "NIL")\nUSERNAME: \(username)\nFOLLOWER COUNT: \(followerCount)\nPROFILE PIC: \(profilePicURL ?? "NIL")\nACCOUNT TYPE: \(primaryCategory)\nAVERAGE LIKES: \(averageLikes ?? -404)"
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
    
//    init(image: String?,instructions: String,captionMustInclude: String?,products: [Product]?,post_ID: String,PostType: TypeofPost,confirmedSince: Date?,isConfirmed: Bool,hashCaption: String) {
//
//        self.image = image
//        self.instructions = instructions
//        self.captionMustInclude = captionMustInclude
//        self.products = products
//        self.post_ID = post_ID
//        self.PostType = PostType
//        self.confirmedSince = confirmedSince
//        self.isConfirmed = isConfirmed
//        self.hashCaption = hashCaption
//    }
    
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
    let account_ID: String?
    let name: String
    let logo: String?
    let mission: String
    let website: String
	let owner_email: String
    let companyDescription: String
    var accountBalance: Double
    
    
    
    init(dictionary: [String: Any]) {
        self.account_ID = dictionary["account_ID"] as? String
        self.name = dictionary["name"] as! String
        self.logo = dictionary["logo"] as? String
        self.mission = dictionary["mission"] as! String
        self.website = dictionary["website"] as! String
        self.owner_email = (dictionary["owner"] as? String) ?? ""
        self.companyDescription = dictionary["description"] as! String
        self.accountBalance = dictionary["accountBalance"] as! Double
        
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
    
    
    init(dictionary: [String: Any]) {
        
        self.userID = dictionary["userID"] as? String
        self.token = dictionary["token"] as? String
        self.email = dictionary["email"] as? String
        self.refreshToken = dictionary["refreshToken"] as? String
        self.isCompanyRegistered = dictionary["isCompanyRegistered"] as? Bool
        self.companyID = dictionary["companyID"] as? String
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

class DwollaCustomerInformation: NSObject {
    
    var acctID = ""
    var firstName = ""
    var lastName = ""
    var customerURL = ""
    var customerFSURL = ""
    var isFSAdded = false
    var mask = ""
    var name = ""
    
//    init(dictionary: [String: Any]) {
//
//        self.acctID = dictionary["accountID"] as! String
//        self.firstName = dictionary["firstname"] as! String
//        self.lastName = dictionary["lastname"] as! String
//        self.customerURL = dictionary["customerURL"] as! String
//        self.customerFSURL = dictionary["customerFSURL"] as! String
//        self.isFSAdded = dictionary["isFSAdded"] as! Bool
//        self.mask = dictionary["mask"] as! String
//        self.name = dictionary["name"] as! String
//    }
    
    
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
    var categoryData: [Category]!
    var expanded: Bool!
    init(categoryTitle: categoryClass, categoryData: [Category], expanded: Bool) {
        self.categoryTitle = categoryTitle
        self.categoryData = categoryData
        self.expanded = expanded
    }
}
