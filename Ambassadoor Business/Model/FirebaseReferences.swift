//
//  FirebaseReferences.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/11/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
import Firebase

//Gets all offers relavent to the user via Firebase
func GetOffers(userId: String) -> [Offer] {
    let ref = Database.database().reference().child("offers")
    let offersRef = ref.child(userId)
    var offers: [Offer] = []
    offersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, offer) in dictionary{
                let offerDictionary = offer as? NSDictionary
                let offerInstance = Offer(dictionary: offerDictionary! as! [String : AnyObject])
                offers.append(offerInstance)
            }
        }
    }, withCancel: nil)
    return offers
}

//Creates the offer and returns the newly created offer as an Offer instance
func CreateOffer(offer: Offer) -> Offer {
    let ref = Database.database().reference().child("offers")
    let offerRef = ref.childByAutoId()
    let values: [String: AnyObject] = serializeOffer(offer: offer)
    offerRef.updateChildValues(values)
    return offer
}

func GetTestTemplateOffer() -> TemplateOffer {
    let fakeproduct = [Product.init(image: "https://media.kohlsimg.com/is/image/kohls/2375536_Gray?wid=350&hei=350&op_sharpen=1", name: "Any Nike Shoe", price: 80, buy_url: "https://store.nike.com/us/en_us/pw/mens-shoes/7puZoi3", color: "Any", product_ID: ""),
                       Product.init(image: "https://ae01.alicdn.com/kf/HTB1_iYaljihSKJjy0Fiq6AuiFXat/Original-New-Arrival-NIKE-TEE-FUTURA-ICON-LS-Men-s-T-shirts-Long-sleeve-Sportswear.jpg_640x640.jpg", name: "Any Nike Shirt", price: 25, buy_url: "https://store.nike.com/us/en_us/pw/mens-tops-t-shirts/7puZobp", color: "Any", product_ID: ""),
                       Product.init(image: "https://s3.amazonaws.com/nikeinc/assets/60756/USOC_MensLaydown_2625x1500_hd_1600.jpg?1469461906", name: "Any Nike Product", price: 20, buy_url: "https://www.nike.com/", color: "Any", product_ID: ""),
                       Product.init(image: "https://s3.amazonaws.com/boutiika-assets/image_library/BTKA_1520271255702342_ddff2a8ce6a4e69bce5a8da0444a57.jpg", name: "Any of our shoes", price: 20, buy_url: "http://www.jmichaelshoes.com/shop/birkenstock-birkenstock-arizona-olive-bf-6991148", color: "Any", product_ID: "")]
    
    let fakeNike = Company.init(name: "Nike", logo: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png", mission: "Just Do It.", website: "https://www.nike.com/", account_ID: "", instagram_name: "", description: "Nike, Inc. is an American multinational corporation that is engaged in the design, development, manufacturing, and worldwide marketing and sales of footwear, apparel, equipment, accessories, and services. The company is headquartered near Beaverton, Oregon, in the Portland metropolitan area.")
    
    return TemplateOffer.init(dictionary: ["money": 13.65 as AnyObject, "company": fakeNike as AnyObject, "user_ID": "-LabEKrth-DRbVpG0WPn" as AnyObject, "posts": [
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: true),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "Just Do It. #sponsored", products: [fakeproduct[2]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: true)] as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": true as AnyObject, "targetCategories": [] as NSArray, "zipCodes": ["11942","13210"] as NSArray, "genders": ["male", "female"] as NSArray])
}


//Gets all relavent people, people who you are friends and a few random people to compete with.
/*
func GetRandomTestUsers() -> [User] {
    var userslist : [User] = []
    for _ : Int in (1...Int.random(in: 1...50)) {
        for x : Category in [.Entrepreneuner, .Hiker, .WinterSports, .Baseball, .Basketball, .Golf, .Tennis, .Soccer, .Football, .Boxing, .MMA, .Swimming, .TableTennis, .Gymnastics, .Dancer, .Rugby, .Bowling, .Frisbee, .Cricket, .SpeedBiking, .MountainBiking, .WaterSkiing, .Running, .PowerLifting, .BodyBuilding, .Wrestling, .StrongMan, .NASCAR, .RalleyRacing, .Parkour, .Model, .Makeup, .Actor, .RunwayModel, .Designer, .Brand, .Stylist, .HairStylist, .FasionArtist, .Painter, .Sketcher, .Musician, .Band, .SingerSongWriter, .WinterSports] {
            userslist.append(User.init(dictionary: ["name": GetRandomName() as AnyObject, "username": getRandomUsername() as AnyObject, "followerCount": Double(Int.random(in: 10...1000) << 2) as AnyObject, "profilePicture": "https://scontent-lga3-1.cdninstagram.com/vp/60d965d5d78243bd600e899ceef7b22e/5D03F5A8/t51.2885-19/s150x150/16123627_1826526524262048_8535256149333639168_n.jpg?_nc_ht=scontent-lga3-1.cdninstagram.com" as  AnyObject, "primaryCategory": x as AnyObject, "averageLikes": pow(Double(Int.random(in: 1...1000)), 2) as AnyObject, "id": "" as AnyObject]))
        }
    }
    return userslist
}
*/
func GetRandomName() ->  String {
    return "TestUser\(Int.random(in: 100...9999))"
}

func getRandomUsername() -> String {
    return "marco_m_polo"
}

func serializeOffer(offer: Offer) -> [String: AnyObject] {
    var post_IDS: [String] = []
    for post in offer.posts {
        post_IDS.append(post.post_ID)
    }
    var values = [
         "money": offer.money,
         "company": offer.company.name,
         "posts": post_IDS,
         "offerdate": offer.offerdate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
         "offer_ID": offer.offer_ID,
         "user_ID": offer.user_ID,
         "expiredate": offer.expiredate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss"),
         "allPostsConfrimedSince": offer.allPostsConfrimedSince?.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss") ?? " ",
         "allConfirmed": offer.allConfirmed,
         "isAccepted": offer.isAccepted,
         "isExpired": offer.isExpired,
     ] as [String : AnyObject]
    if let templateOffer = offer as? TemplateOffer {
        values["targetCategories"] = templateOffer.targetCategories as AnyObject
        values["zipCodes"] = templateOffer.zipCodes as [String] as AnyObject
        values["genders"] = templateOffer.genders as [String] as AnyObject
    }
    return values
}

// Updates values for user in firebase via their id returns that same user
func UpdateUserInDatabase(instagramUser: User) -> User {
    let ref = Database.database().reference().child("users")
    let userData = API.serializeUser(user: instagramUser, id: instagramUser.id!)
    ref.child(instagramUser.id!).updateChildValues(userData)
    return instagramUser
}

//Creates an account with nothing more than the username of the account. Returns instance of account returned from firebase
func CreateAccount(instagramUser: [String: Any], completed: @escaping (_ userDictionary: [String: Any]) -> ()) {
    // Pointer reference in Firebase to Users
    let ref = Database.database().reference().child("users")
    // Boolean flag to keep track if user is already in database
    var alreadyRegistered: Bool = false
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        var userId: String = ""
        var userData: [String: Any] = instagramUser
        for case let user as DataSnapshot in snapshot.children {
            if (user.childSnapshot(forPath: "username").value as! String == userData["username"] as! String) {
                alreadyRegistered = true
                userId = user.childSnapshot(forPath: "id").value as! String
                userData["id"] = user.childSnapshot(forPath: "id").value as! String
                userData["primaryCategory"] = user.childSnapshot(forPath: "primaryCategory").value as! String
                userData["secondaryCategory"] = user.childSnapshot(forPath: "secondaryCategory").value as! String
                // userData = API.serializeUser(user: instagramUser, id: userId)
                break
            }
        }
        // If user isn't registered then create a new instance in firebase, else update the existing data for that user in firebase
        if !alreadyRegistered {
            let userReference = ref.childByAutoId()
            userData["id"] = userReference.key
            // var userData = API.serializeUser(user: instagramUser, id: userReference.key!)
            userReference.updateChildValues(userData)
        } else {
            debugPrint(userData)
            ref.child(userId).updateChildValues(userData)
        }
        completed(userData)
    })
}

// Query all users in Firebase and to do filtering based on algorithm
func GetAllUsers(completion: @escaping ([User]) -> ()){
    let usersRef = Database.database().reference().child("users")
    var users: [User] = []
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, user) in dictionary {
                let userDictionary = user as? NSDictionary
                let userInstance = User(dictionary: userDictionary! as! [String : AnyObject])
                users.append(userInstance)
            }
            completion(users)
        }
    }, withCancel: nil)
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
