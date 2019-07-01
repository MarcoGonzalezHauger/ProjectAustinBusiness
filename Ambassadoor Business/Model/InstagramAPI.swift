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
        return offerData
    }
    
    static func serializeOffer(offer: Offer) -> [String: Any] {
        var post_IDS: [String] = []
        for post in offer.posts {
            post_IDS.append(post.post_ID)
        }
        let offerData: [String: Any] = [
            "offer_ID": offer.offer_ID,
            "money": offer.money,
			"company": offer.company.account_ID as Any,
            "posts": post_IDS,
            "offerdate": offer.offerdate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
            "user_ID": offer.user_ID as Any,
            "expiredate": offer.expiredate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
            "allPostsConfirmedSince": offer.allPostsConfirmedSince!.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
            "allConfirmed": offer.allConfirmed,
            "isAccepted": offer.isAccepted,
            "isExpired": offer.isExpired,
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
