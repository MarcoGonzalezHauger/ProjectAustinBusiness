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
    
    func DrawShadows() {
        //draw shadow & rounded corners for offer cell
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.shadowColor = ShadowColor.cgColor
        self.layer.shadowOpacity = ShadowOpacity
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = CGFloat(ShadowRadius)
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
    }
}

//Structure for an offer that comes into username's inbox
class Offer: NSObject {
    var offer_ID: String
    var money: Double
    var company: Company
    var posts: [Post]
    var offerdate: Date
    var user_ID: String?
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
    var debugInfo: String {
        return "Offer by \(company.name) for $\(String(money)) that is \(isExpired ? "" : "not ") expired."
    }
    init(dictionary: [String: AnyObject]) {
        self.money = dictionary["money"] as! Double
        self.company = dictionary["company"] as! Company
        self.posts = dictionary["posts"] as! [Post]
        self.offerdate = dictionary["offerdate"] as! Date
        if let userID = dictionary["user_ID"] as? String {
			self.user_ID = userID
        }
        self.offer_ID = dictionary["offer_ID"] as! String
        self.expiredate = dictionary["expiredate"] as! Date
        self.allPostsConfirmedSince = dictionary["allPostsConfirmedSince"] as? Date
        self.isAccepted = dictionary["isAccepted"] as! Bool
    }
}

class TemplateOffer: Offer {
    var targetCategories: [Category]
    var zipCodes: [String]
    var genders: [String]
    var user_IDs: [String]
	var title: String

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
		self.title = dictionary["title"] as! String
        self.zipCodes = dictionary["zipCodes"] as! [String]
        self.genders = dictionary["genders"] as! [String]
        self.user_IDs = dictionary["user_IDs"] as! [String]
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
        /*debugPrint("Category: \(String(describing: dictionary["primaryCategory"]))")
         if ((dictionary["primaryCategory"] ?? "") as! String) == ""{
         debugPrint("It's other")
         self.primaryCategory = Category.init(rawValue: "Other")!
         } else {
         debugPrint("what's up")
         self.primaryCategory = (((dictionary["primaryCategory"] as! String) ?? "") == "" ? Category.init(rawValue: "Other")! : Category.init(rawValue: dictionary["primaryCategory"] as! String))!
         }
         if (dictionary["primaryCategory"] as? String != nil) {
         if Yourself != nil {
         self.primaryCategory = Yourself.primaryCategory
         } else {
         debugPrint("hey")
         self.primaryCategory = Category.init(rawValue: dictionary["primaryCategory"] as? String ?? "Other")!
         }
         } else {
         debugPrint("sup")
         self.primaryCategory = Category.init(rawValue: "Other")!
         debugPrint(self.primaryCategory.rawValue)
         }
         if ((dictionary["secondaryCategory"] ?? "") as! String) == ""{
         self.SecondaryCategory = nil
         */
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
    let post_ID: String
    let PostType: TypeofPost
    var confirmedSince: Date?
    var isConfirmed: Bool
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
        self.owner_email = dictionary["owner"] as! String
        self.companyDescription = dictionary["description"] as! String
        self.accountBalance = dictionary["accountBalance"] as! Double
    }
}

//Carries personal info only avalible to view and edit by the user.
struct PersonalInfo {
    let gender: Gender?
    let accountBalance: Int?
}

enum Gender {
    case male, female, other
}

enum TypeofPost {
    case SinglePost, MultiPost, Story
}
