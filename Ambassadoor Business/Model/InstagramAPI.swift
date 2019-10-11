//
//  InstagramAPI.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/12/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//
import Foundation

struct API {
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_CLIENT_ID = "fa083c34de6847ff95db596d75ef1c31"
    static let INSTAGRAM_CLIENTSERCRET = "b81172265e6b417782fcf075e2daf2ff"
    static let INSTAGRAM_REDIRECT_URI = "https://ambassadoor.co/welcome"
    static var INSTAGRAM_ACCESS_TOKEN = ""
    static let threeMonths: Double = 7889229
    static let INSTAGRAM_SCOPE = "public_content" /* add whatever scope you need https://www.instagram.com/developer/ */
    static var NOTME: Bool = false
    
    static var instagramProfileData: [String: AnyObject] = [:]
    
    static var kBaseURL = "https://us-central1-amassadoor.cloudfunctions.net/"
    
    static var kDwollaClient_id = "CijOdBYNcHDSwXjkf4PnsXjHBYSgKdgc7TdfoDNUZiNvOPfAst"
    
    static var kDwollaClient_secret = "m8oCRchilXnkR3eFAKlNuQWFqv9zROJX0CkD5aiys1H3nmvQMb"
    
    static var kCreateCustomer = "https://api-sandbox.dwolla.com/customers"
    
    static var kCreateFundingSourceURL = "https://api-sandbox.dwolla.com/customers/AB443D36-3757-44C1-A1B4-29727FB3111C/funding-sources"
    
    static var kFundTransferURL = "https://api-sandbox.dwolla.com/transfers"
    
    static var superBankFundingSource = "https://api-sandbox.dwolla.com/funding-sources/b23abf0b-c28d-4941-84af-617626865f2b"
    
    static func getProfileInfo(completed: ((_ userDictionary: [String: Any]) -> () )?) {
        let url = URL(string: "https://api.instagram.com/v1/users/self/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            
            debugPrint("Downloading username data from instagram API")
            
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            self.instagramProfileData = profileData["data"] as! [String : AnyObject]
                            var userDictionary: [String: Any] = [
                                "name": instagramProfileData["full_name"] as! String,
                                "username": instagramProfileData["username"] as! String,
                                "followerCount": instagramProfileData["counts"]?["followed_by"] as! Double,
                                "profilePicURL": instagramProfileData["profile_picture"] as! String,
                                ]
                            debugPrint("Done Creating Userinfo dictinary")
                            getAverageLikesOfUser(instagramId: instagramProfileData["id"] as! String, completed: { (averageLikes: Double?) in
                                DispatchQueue.main.async {
                                    debugPrint("Got Average Likes of User.")
                                    userDictionary["averageLikes"] = averageLikes
                                    completed?(userDictionary)
                                }
                            })
                        }
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
            }.resume()
    }
	
	static func serializeProduct(product: Product) -> [String: Any] {
		let userData: [String: Any] = [
			"product_ID": product.product_ID as Any,
			"image": product.image as Any,
			"name": product.name,
			"price": product.price,
			"buy_url": product.buy_url as Any,
			"color": product.color
		]
		return userData
	}
	
    static func serializeUser(user: User, id: String) -> [String: Any] {
        var userData: [String: Any] = [
            "name": user.name!,
            "username": user.username,
            "followerCount": user.followerCount,
            "profilePicURL": user.profilePicURL!,
            "primaryCategory": user.primaryCategory.rawValue,
            "secondaryCategory": user.SecondaryCategory == nil ? "" : user.SecondaryCategory!.rawValue,
            "averageLikes": user.averageLikes ?? "",
            "zipCode": user.zipCode as Any,
			"gender": user.gender!
        ]
        if id != "" {
            userData["id"] = id
        }
        return userData
    }
    
    static func serializePost(post: Post) -> [String: Any] {
        //                           Post.init(image: nil, instructions: desPost.text!, captionMustInclude: <#T##String?#>, products: <#T##[Product]?#>, post_ID: <#T##String#>, PostType: <#T##TypeofPost#>, confirmedSince: <#T##Date?#>, isConfirmed: <#T##Bool#>)
        var product = [[String: Any]]()
        
        for value in post.products! {
            product.append(serializeProduct(product: value))
        }
        //DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: post.confirmedSince!, format: "yyyy/MMM/dd HH:mm:ss")
        let postData: [String: Any] = ["image":post.image!,"instructions":post.instructions,"captionMustInclude":post.captionMustInclude!,"products":product,"post_ID":post.post_ID,"PostType": post.PostType,"confirmedSince":"" ,"isConfirmed":post.isConfirmed,"hashCaption":post.hashCaption]
        
        return postData
    }
    
    static func serializeTemplateOffer(offer: TemplateOffer) -> [String: Any] {
        var offerData = serializeOffer(offer: offer)
        var cats: [String] = []
        for cat in offer.targetCategories {
            cats.append(cat.rawValue)
        }
        offerData["targetCategories"] = cats
        offerData["zipCodes"] = offer.zipCodes
        offerData["genders"] = offer.genders
        offerData["user_IDs"] = offer.user_IDs
        offerData["category"] = offer.category
        offerData["title"] = offer.title
        offerData["status"] = offer.status
        return offerData
    }
    
    static func serializeDepositDetails(deposit: Deposit) -> [String: Any] {
        var transactionData = serializeTransactionDetails(transaction: deposit.lastTransactionHistory!)
        /*var userID: String?
        var currentBalance: Double?
        var totalDepositAmount: Double?
        var totalDeductedAmount: Double?
        var lastDeductedAmount: Double?
        var lastDepositedAmount: Double?
        var lastTransactionHistory: TransactionDetails?
        var depositHistory: [AnyObject]?
        var depositDetails = []*/
        let depositSerialize = ["userID":deposit.userID!,"currentBalance":deposit.currentBalance!,"totalDepositAmount":deposit.totalDepositAmount,"totalDeductedAmount":deposit.totalDeductedAmount,"lastDeductedAmount":deposit.lastDeductedAmount,"lastDepositedAmount":deposit.lastDepositedAmount,"lastTransactionHistory":transactionData,"depositHistory":deposit.depositHistory] as [String : Any]
        
        return depositSerialize
    }
    
    static func serializeDwollaCustomers(object: DwollaCustomerInformation) -> [String: Any]{
        
        let dwollaCustomerSerialize = ["firstname": object.firstName,"lastname": object.lastName,"accountID":object.acctID,"customerURL": object.customerURL,"customerFSURL":object.customerFSURL,"isFSAdded": object.isFSAdded,"mask":object.mask,"name":object.name] as [String : Any]
        
        return dwollaCustomerSerialize
        
    }
    
    static func serializeTransactionDetails(transaction: TransactionDetails) -> [String: Any] {
        
        /*var id: String?
         var status: String?
         var type: String?
         var currencyIsoCode: String?
         var amount: String?
         var createdAt: String?
         var updatedAt: String?
         var cardDetails: Any?
         */
        var transactionSerialize = ["id":transaction.id,"status":transaction.status,"type":transaction.type,"currencyIsoCode":transaction.currencyIsoCode,"amount":transaction.amount,"createdAt":transaction.createdAt,"updatedAt":transaction.updatedAt,"cardDetails":transaction.cardDetails] as [String: Any]
        
        return transactionSerialize
    }
    
    static func serializeOffer(offer: Offer) -> [String: Any] {
        var posts: [[String: Any]] = [[String: Any]]()
        for post in offer.posts {
            posts.append(API.serializePost(post: post)) 
        }
        
        var offerConSin = ""
        
        if offer.allPostsConfirmedSince != nil {
           offerConSin = offer.allPostsConfirmedSince!.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss")
        }else{
           offerConSin = ""
        }
        let offerData: [String: Any] = [
            "offer_ID": offer.offer_ID,
            "money": offer.money,
            "company": offer.company?.account_ID as Any,
            "posts": posts,
            "offerdate": offer.offerdate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
            "user_ID": offer.user_ID as Any,
            "expiredate": offer.expiredate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
            "allPostsConfirmedSince": offerConSin,
            "allConfirmed": offer.allConfirmed,
            "isAccepted": offer.isAccepted,
            "isExpired": offer.isExpired,"ownerUserID": offer.ownerUserID
            ]
        return offerData
    }
    
    static func getProfilePictureURL(userId: String) -> String {
        let url = URL(string: "https://api.instagram.com/v1/users/" + userId + "/?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        var profilePictureURL = ""
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let profileData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String : AnyObject] {
                            if let data = profileData["data"] {
                                profilePictureURL = data["profile_picture"] as! String
                                debugPrint(profilePictureURL)
                            }
                        }
                    }
                } catch {
                    print("JSON Downloading Error!")
                }
            }
            }.resume()
        return profilePictureURL
    }
    
    // Computes the average amount of likes on the 5 latest posts or the average of the posts in the last 3 months if more
    static func getAverageLikesOfUser(instagramId: String, completed: @escaping (_ averageLikes: Double?) -> ()) {
        let url = URL(string: "https://api.instagram.com/v1/users/" + String(instagramId) + "/media/recent?access_token=" + INSTAGRAM_ACCESS_TOKEN)
        let currentTime = NSDate().timeIntervalSince1970
        var count = 0
        var average = 0
        var averageLikes: Double?
        URLSession.shared.dataTask(with: url!){ (data, response, err) in
            if err == nil {
                // check if JSON data is downloaded yet
                guard let jsondata = data else { return }
                do {
                    do {
                        // Deserilize object from JSON
                        if let postData: [String: AnyObject] = try JSONSerialization.jsonObject(with: jsondata, options: []) as? [String: AnyObject] {
                            if let data = postData["data"] {
                                // Go through posts and check to see if they're less than 3 months old
                                for post in data as! [AnyObject] {
                                    if let createdTime = post["created_time"] as? String {
                                        let createdTimeDouble = Double(createdTime)!
                                        if (createdTimeDouble > (currentTime - threeMonths) || count <= 5 ) {
                                            let likes = post["likes"] as AnyObject
                                            let likesCount = likes["count"] as! Int
                                            average += likesCount
                                            count += 1
                                        }
                                    }
                                }
                                averageLikes = count >= 5 ? round(Double(average / count)) : nil
                            }
                        }
                        DispatchQueue.main.async {
                            completed(averageLikes)
                        }
                    }
                } catch {
                    print("JSON Downloading Error! in Average Likes Of User Function.")
                }
            }
            }.resume()
    }
}
