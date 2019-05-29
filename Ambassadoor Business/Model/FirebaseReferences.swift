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

func GetCompany(account_ID: String) -> Company {
    let ref = Database.database().reference().child("companies")
    let companyRef = ref.child(account_ID)
    var companyInstance = Company(dictionary: [:])
    companyRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let companyDictionary = dictionary as NSDictionary
            companyInstance = Company(dictionary: companyDictionary as! [String : AnyObject])
        }
    }, withCancel: nil)
    return companyInstance
}

//Creates the offer and returns the newly created offer as an Offer instance
func CreateOffer(offer: Offer) -> Offer {
    let ref = Database.database().reference().child("offers")
    let offerRef = ref.childByAutoId()
    let values: [String: AnyObject] = serializeOffer(offer: offer)
    offerRef.updateChildValues(values)
    return offer
}

func GetFakeProducts() -> [Product] {
    let fakeproduct = [Product.init(dictionary: ["image": "https://media.kohlsimg.com/is/image/kohls/2375536_Gray?wid=350&hei=350&op_sharpen=1", "name": "Any Nike Shoe", "price": 80.0, "buy_url": "https://store.nike.com/us/en_us/pw/mens-shoes/7puZoi3", "color": "Any", "product_ID": ""]),
                       Product.init(dictionary: ["image": "https://ae01.alicdn.com/kf/HTB1_iYaljihSKJjy0Fiq6AuiFXat/Original-New-Arrival-NIKE-TEE-FUTURA-ICON-LS-Men-s-T-shirts-Long-sleeve-Sportswear.jpg_640x640.jpg", "name": "Any Nike Shirt", "price": 25.0, "buy_url": "https://store.nike.com/us/en_us/pw/mens-tops-t-shirts/7puZobp", "color": "Any", "product_ID": ""]),
                       Product.init(dictionary: ["image": "https://s3.amazonaws.com/nikeinc/assets/60756/USOC_MensLaydown_2625x1500_hd_1600.jpg?1469461906", "name": "Any Nike Product", "price": 20.0, "buy_url": "https://www.nike.com/", "color": "Any", "product_ID": ""]),
                       Product.init(dictionary: ["image": "https://s3.amazonaws.com/boutiika-assets/image_library/BTKA_1520271255702342_ddff2a8ce6a4e69bce5a8da0444a57.jpg", "name": "Any of our shoes", "price": 20.0, "buy_url": "http://www.jmichaelshoes.com/shop/birkenstock-birkenstock-arizona-olive-bf-6991148", "color": "Any", "product_ID": ""])
        
    ]
    return fakeproduct
}

func GetFakeOffers() -> [Offer] {
    
    
    var fakeoffers : [Offer] = []
    let fakeproduct = GetFakeProducts()
    
    //Creates the fake Company NIKE. Unofficial Sponsor.
    
    let fakeNike = Company.init(dictionary: ["name": "Nike" as AnyObject, "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png" as AnyObject, "mission": "Just Do It." as AnyObject, "website": "https://www.nike.com/" as AnyObject, "account_ID": "" as AnyObject, "instagram_name": "" as AnyObject, "description": "Nike, Inc. is an American multinational corporation that is engaged in the design, development, manufacturing, and worldwide marketing and sales of footwear, apparel, equipment, accessories, and services. The company is headquartered near Beaverton, Oregon, in the Portland metropolitan area." as AnyObject, "accountBalance": 0.0])
    
    let JMichaels = Company.init(dictionary: ["name": "J Michael's Shoes", "logo": "https://media.licdn.com/dms/image/C4E0BAQEqnu9inQDs7w/company-logo_200_200/0?e=2159024400&v=beta&t=f5RjDMFwqrFg3mqGt7JoBcDn92Zgi0f31F2pr59OACI", "mission": "Est 1983", "website": "http://www.jmichaelshoes.com/", "account_ID": "", "instagram_name": "", "description": "Since 1983, J Michael has been bringing European and Domestic designs as well as fashions from the East and West coasts to the Syracuse University Campus. Our unique collection of clothing, footwear, and accessories has made us the favorite spot to shop for generations of co-eds and Central New Yorkers. Thanks for shopping our site, but of course, we’d love to see you at our brick-and-mortar store so that you can feel the J Michael heat. Remember, “If it’s Hot…It’s Here!”™", "accountBalance": 0.0])
    
    //creates first NIKE post, that is for little money
    
    fakeoffers.append(TemplateOffer.init(dictionary: ["money": 7.5 as AnyObject, "company": fakeNike as AnyObject, "posts": [
        
        Post.init(image: nil, instructions: "Post an image near a basketball court", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: false)]
        
        as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject as AnyObject, "allPostsConfirmedSince": Date(timeIntervalSinceNow: 86400) as AnyObject, "isAccepted": false as AnyObject, "zipCodes": ["11942"] as AnyObject, "targetCategories": ["BodyBuilding"] as AnyObject, "genders": ["male"] as AnyObject, "user_IDs": [] as AnyObject]))
    
    //creates good offer that's already been accepted, but not complete.
    
    fakeoffers.append(Offer.init(dictionary: ["money": 13.65 as AnyObject, "company": fakeNike as AnyObject, "user_ID": "-LabEKrth-DRbVpG0WPn" as AnyObject, "posts": [
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: true),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "Just Do It. #sponsored", products: [fakeproduct[2]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: true)]
        
        as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": true as AnyObject]))
    
    //Offer that has been completed.
    
    fakeoffers.append(Offer.init(dictionary: ["money": 13.44 as AnyObject, "company": "JMichaels" as AnyObject, "user_ID": "-LabEKrth-DRbVpG0WPn" as AnyObject, "posts": [
        
        Post.init(image: nil, instructions: "Post an image using one of the proudcts.", captionMustInclude: "J Michaels #sponsored", products: [fakeproduct[3]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false)]
        
        as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": false as AnyObject]))
    
    return fakeoffers
}

func GetTestTemplateOffer() -> TemplateOffer {
    let fakeproduct = GetFakeProducts()
    let fakeNike = Company.init(dictionary: ["name": "Nike", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png", "mission": "Just Do It.", "website": "https://www.nike.com/", "account_ID": "", "instagram_name": "", "description": "Nike, Inc. is an American multinational corporation that is engaged in the design, development, manufacturing, and worldwide marketing and sales of footwear, apparel, equipment, accessories, and services. The company is headquartered near Beaverton, Oregon, in the Portland metropolitan area.", "accountBalance": 0.0])
    
    return TemplateOffer.init(dictionary: ["money": 13.65 as AnyObject, "company": fakeNike as AnyObject, "posts": [
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: true),
        
        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "Just Do It. #sponsored", products: [fakeproduct[2]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: true)] as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": Date(timeIntervalSinceNow: 86400) as AnyObject as AnyObject, "isAccepted": true as AnyObject, "targetCategories": [] as NSArray, "zipCodes": ["11942","13210"] as NSArray, "genders": ["male", "female"] as NSArray, "user_IDs": [] as NSArray])
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
        "money": offer.money as AnyObject,
        "company": offer.company.name as AnyObject,
        "posts": post_IDS as AnyObject,
        "offerdate": offer.offerdate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss") as AnyObject,
        "offer_ID": offer.offer_ID as AnyObject,
        "user_ID": offer.user_ID as AnyObject,
        "expiredate": offer.expiredate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss") as AnyObject,
        "allPostsConfirmedSince": offer.allPostsConfirmedSince?.toString(dateFormat: "yyyy/MMM/dd HH:mm:ss") ?? " ",
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

func CreateProduct(productDictionary: [String: Any], completed: @escaping (_ product: Product) -> ()) {
    let ref = Database.database().reference().child("products")
    var productData = productDictionary
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        let productReference = ref.childByAutoId()
        productData["product_ID"] = productReference.key
        productReference.updateChildValues(productData)
        let productInstance: Product = Product(dictionary: productData)
        completed(productInstance)
    })
}

func CreateCompany(company: Company, completed: @escaping (_ companyInstance: Company) -> ()) {
    let ref = Database.database().reference().child("companies")
    // Boolean flag to keep track if company is already in database
    var alreadyRegistered: Bool = false
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        var companyData: [String: Any] = serializeCompany(company: company)
        for case let company as DataSnapshot in snapshot.children {
            if (company.childSnapshot(forPath: "name").value as! String == companyData["name"] as! String) {
                companyData["account_ID"] = company.childSnapshot(forPath: "account_ID").value as! String
                alreadyRegistered = true
                break
            }
        }
        // If company isn't registered then create a new instance in firebase
        if !alreadyRegistered {
            let companyReference = ref.childByAutoId()
            companyData["account_ID"] = companyReference.key
            companyReference.updateChildValues(companyData)
        }
        let categoryInstance: Company = Company(dictionary: companyData)
        completed(categoryInstance)
    })
}

// Uploads image to firebase, parameters: the image, the type of photo ("company", "product", etc.), the id of the item to upload
func getImage(type: String, id: String, completed: @escaping (_ image: UIImage) -> ()) {
    let fileName = id + ".png"
    let ref = Storage.storage().reference().child(type).child(fileName)
    var image: UIImage = UIImage()
    ref.getData(maxSize: 10000000000000000, completion: { (data, error) in
        if error != nil {
            debugPrint(error!)
            return
        }
        image = UIImage(data: data!)!
        completed(image)
    })
}

// Uploads image to firebase, parameters: the image, the type of photo ("company", "product", etc.), the id of the item to upload
func uploadImage(image: UIImage, type: String, id: String) -> UIImage {
    let data = image.pngData()
    let fileName = id + ".png"
    let ref = Storage.storage().reference().child(type).child(fileName)
    ref.putData(data!, metadata: nil, completion: { (metadata, error) in
        if error != nil {
            debugPrint(error!)
            return
        }
        debugPrint(metadata!)
    })
    return image
}

func serializeCompany(company: Company) -> [String: Any] {
    let companyData: [String: Any] = [
        "account_ID": company.account_ID!,
        "name": company.name,
        "logo": company.logo!,
        "mission": company.mission,
        "website": company.website,
        "instagram_name": company.instagram_name,
        "description": company.companyDescription,
        "accountBalance": company.accountBalance
    ]
    return companyData
}

// Query all users in Firebase and to do filtering based on algorithm
func GetAllUsers(completion: @escaping ([User]) -> ()) {
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

func getAllProducts(completion: @escaping ([Product]) -> ()) {
    let productsRef = Database.database().reference().child("products")
    var products: [Product] = []
    productsRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            for (_, product) in dictionary {
                let productDictionary = product as? NSDictionary
                let productInstance = Product(dictionary: productDictionary! as! [String : AnyObject])
                products.append(productInstance)
            }
            completion(products)
        }
    }, withCancel: nil)
}

func sendOffer(offer: Offer, money: Double, completion: @escaping (Offer) -> ()) {
    let offersRef = Database.database().reference().child("offers")
    let offerKey = offersRef.childByAutoId()
    offer.offer_ID = offerKey.key!
    var offerDictionary: [String: Any] = [:]
    if type(of: offer) == TemplateOffer.self {
        findInfluencers(offer: offer as! TemplateOffer, money: money, completion: { (o) in
            offerDictionary = API.serializeTemplateOffer(offer: o)
            offerKey.updateChildValues(offerDictionary)
        })
    } else {
        offerDictionary = API.serializeOffer(offer: offer)
        offerKey.updateChildValues(offerDictionary)
    }
    YourCompany.accountBalance -= offer.money
    UpdateCompanyInDatabase(company: YourCompany)
    debugPrint(offerDictionary)
}

func calculateCostForUser(offer: Offer, user: User) -> Double {
    return 0.055 * user.averageLikes! * Double(offer.posts.count)
}

func findInfluencers(offer: TemplateOffer, money: Double, completion: @escaping (TemplateOffer) -> ()) {
    var moneyForOffer = money
    var count = 0
    GetAllUsers(completion: { (users) in
		var shuffledUsers : [User] = users
		shuffledUsers.shuffle()
        for user in shuffledUsers {
            if moneyForOffer <= 0 {
                return
            }
			let cost: Double = calculateCostForUser(offer: offer, user: user)
			var inList: Bool = false
			for zip in offer.zipCodes {
				if user.zipCode == zip {
					inList = true
				}
			}
			for cat in offer.targetCategories {
				if user.primaryCategory == cat {
					inList = true
				}
			}
            for gender in offer.genders {
                if user.gender == gender {
                    inList = true
                }
            }
            if inList {
                offer.user_IDs.append(user.id!)
                count += 1
                moneyForOffer -= cost
            }
        }
        completion(offer)
    })
}

func UpdateCompanyInDatabase(company: Company) -> Company {
    let ref = Database.database().reference().child("companies")
    var companyData = serializeCompany(company: company)
    ref.child(company.account_ID!).updateChildValues(companyData)
    return company
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
