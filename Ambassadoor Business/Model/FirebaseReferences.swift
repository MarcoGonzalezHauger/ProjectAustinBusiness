//
//  FirebaseReferences.swift
//  Ambassadoor Business
//
//  Created by Chris Chomicki on 4/11/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//
import Foundation
import Firebase
import UIKit

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

//func UploadTemplateOffersToUser() {
//	let ref = Database.database().reference().child("companies").child("<#T##pathString: String##String#>")
//}

//Creates the offer and returns the newly created offer as an Offer instance
func CreateOffer(offer: Offer) -> Offer {
    let user = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("offers").child(user)
    let offerRef = ref.childByAutoId()
    let values: [String: AnyObject] = serializeOffer(offer: offer)
    offerRef.updateChildValues(values)
    return offer
}



//func GetFakeProducts() -> [Product] {
//    let fakeproduct = [Product.init(dictionary: ["image": "https://media.kohlsimg.com/is/image/kohls/2375536_Gray?wid=350&hei=350&op_sharpen=1", "name": "Any Nike Shoe", "price": 80.0, "buy_url": "https://store.nike.com/us/en_us/pw/mens-shoes/7puZoi3", "color": "Any", "product_ID": ""]),
//                       Product.init(dictionary: ["image": "https://ae01.alicdn.com/kf/HTB1_iYaljihSKJjy0Fiq6AuiFXat/Original-New-Arrival-NIKE-TEE-FUTURA-ICON-LS-Men-s-T-shirts-Long-sleeve-Sportswear.jpg_640x640.jpg", "name": "Any Nike Shirt", "price": 25.0, "buy_url": "https://store.nike.com/us/en_us/pw/mens-tops-t-shirts/7puZobp", "color": "Any", "product_ID": ""]),
//                       Product.init(dictionary: ["image": "https://s3.amazonaws.com/nikeinc/assets/60756/USOC_MensLaydown_2625x1500_hd_1600.jpg?1469461906", "name": "Any Nike Product", "price": 20.0, "buy_url": "https://www.nike.com/", "color": "Any", "product_ID": ""]),
//                       Product.init(dictionary: ["image": "https://s3.amazonaws.com/boutiika-assets/image_library/BTKA_1520271255702342_ddff2a8ce6a4e69bce5a8da0444a57.jpg", "name": "Any of our shoes", "price": 20.0, "buy_url": "http://www.jmichaelshoes.com/shop/birkenstock-birkenstock-arizona-olive-bf-6991148", "color": "Any", "product_ID": ""])
//
//    ]
//    return fakeproduct
//}

//func GetFakeOffers() -> [Offer] {
//
//
//    var fakeoffers : [Offer] = []
//    let fakeproduct = GetFakeProducts()
//
//    //Creates the fake Company NIKE. Unofficial Sponsor.
//
//    let fakeNike = Company.init(dictionary: ["name": "Nike" as AnyObject, "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png" as AnyObject, "mission": "Just Do It." as AnyObject, "website": "https://www.nike.com/" as AnyObject, "account_ID": "" as AnyObject, "instagram_name": "" as AnyObject, "description": "Nike, Inc. is an American multinational corporation that is engaged in the design, development, manufacturing, and worldwide marketing and sales of footwear, apparel, equipment, accessories, and services. The company is headquartered near Beaverton, Oregon, in the Portland metropolitan area." as AnyObject, "accountBalance": 0.0])
//
//    //creates first NIKE post, that is for little money
//
//    fakeoffers.append(TemplateOffer.init(dictionary: ["money": 7.5 as AnyObject, "company": fakeNike as AnyObject, "posts": [
//
//        Post.init(image: nil, instructions: "Post an image near a basketball court", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
//
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: false)]
//
//        as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject as AnyObject, "allPostsConfirmedSince": Date(timeIntervalSinceNow: 86400) as AnyObject, "isAccepted": false as AnyObject, "zipCodes": ["11942"] as AnyObject, "targetCategories": ["BodyBuilding"] as AnyObject, "genders": ["male"] as AnyObject, "user_IDs": [] as AnyObject]))
//
//    //creates good offer that's already been accepted, but not complete.
//
//    fakeoffers.append(Offer.init(dictionary: ["money": 13.65 as AnyObject, "company": fakeNike as AnyObject, "user_ID": "-LabEKrth-DRbVpG0WPn" as AnyObject, "posts": [
//
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
//
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: true),
//
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "Just Do It. #sponsored", products: [fakeproduct[2]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: true)]
//
//        as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": true as AnyObject]))
//
//    //Offer that has been completed.
//
//    fakeoffers.append(Offer.init(dictionary: ["money": 13.44 as AnyObject, "company": "JMichaels" as AnyObject, "user_ID": "-LabEKrth-DRbVpG0WPn" as AnyObject, "posts": [
//
//        Post.init(image: nil, instructions: "Post an image using one of the proudcts.", captionMustInclude: "J Michaels #sponsored", products: [fakeproduct[3]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false)]
//
//        as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": "" as AnyObject, "isAccepted": false as AnyObject]))
//
//    return fakeoffers
//}
//
//func GetTestTemplateOffer() -> TemplateOffer {
//    let fakeproduct = GetFakeProducts()
//    let fakeNike = Company.init(dictionary: ["name": "Nike", "logo": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png", "mission": "Just Do It.", "website": "https://www.nike.com/", "account_ID": "", "instagram_name": "", "description": "Nike, Inc. is an American multinational corporation that is engaged in the design, development, manufacturing, and worldwide marketing and sales of footwear, apparel, equipment, accessories, and services. The company is headquartered near Beaverton, Oregon, in the Portland metropolitan area.", "accountBalance": 0.0])
//    
//	return TemplateOffer.init(dictionary: ["title": "Offer 1" as AnyObject, "money": 13.65 as AnyObject, "company": fakeNike as AnyObject, "posts": [
//        
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "20% off Nike w/ AMB10 #sponsored", products: [fakeproduct[0], fakeproduct[1]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: false),
//        
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "NIKE #ad", products: [fakeproduct[2]], post_ID: "", PostType: .MultiPost, confirmedSince: nil, isConfirmed: true),
//        
//        Post.init(image: nil, instructions: "Post an image outside", captionMustInclude: "Just Do It. #sponsored", products: [fakeproduct[2]], post_ID: "", PostType: .SinglePost, confirmedSince: nil, isConfirmed: true)] as AnyObject, "offerdate": Date().addingTimeInterval(3000) as AnyObject, "offer_ID": "fakeOffer\(Int.random(in: 1...9999999))" as AnyObject, "expiredate": Date(timeIntervalSinceNow: 86400) as AnyObject, "allPostsConfirmedSince": Date(timeIntervalSinceNow: 86400) as AnyObject as AnyObject, "isAccepted": true as AnyObject, "targetCategories": [] as NSArray, "zipCodes": ["11942","13210"] as NSArray, "genders": ["male", "female"] as NSArray, "user_IDs": [] as NSArray])
//}


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
// */
//func GetRandomName() ->  String {
//    return "TestUser\(Int.random(in: 100...9999))"
//}
//
//func getRandomUsername() -> String {
//    return "marco_m_polo"
//}

func serializeOffer(offer: Offer) -> [String: AnyObject] {
    var post_IDS: [[String: Any]] = [[:]]
    for post in offer.posts {
        post_IDS.append(API.serializePost(post: post) as [String : Any])
    }
    var values = [
        "money": offer.money as AnyObject,
        "company": offer.company?.account_ID as AnyObject,
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
    let user = Singleton.sharedInstance.getCompanyUser()
    let ref = Database.database().reference().child("products").child(Auth.auth().currentUser!.uid).child(user.companyID!)
    var productData = productDictionary
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        let productReference = ref.childByAutoId()
        productData["product_ID"] = productReference.key
        productReference.updateChildValues(productData)
        let productInstance: Product = Product(dictionary: productData)
        completed(productInstance)
    })
}

func CreatePost(param: Post,completion: @escaping (Post,Bool) -> ())  {

    let ref = Database.database().reference().child("post").child(Auth.auth().currentUser!.uid)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        let postReference = ref.childByAutoId()
        let post = Post.init(image: param.image!, instructions: param.instructions, captionMustInclude: param.captionMustInclude!, products: param.products!, post_ID: postReference.key!, PostType: param.PostType, confirmedSince: param.confirmedSince!, isConfirmed: param.isConfirmed, hashCaption: param.hashCaption)
        let productData = API.serializePost(post: post)
        postReference.updateChildValues(productData)
        completion(post, true)
    })

}

func getCreatePostUniqueID(param: Post, completion: @escaping (Post,Bool) -> ()) {
    
    let ref = Database.database().reference()
    let postReference = ref.childByAutoId()
    let post = Post.init(image: param.image!, instructions: param.instructions, captionMustInclude: param.captionMustInclude!, products: param.products!, post_ID: postReference.key!, PostType: param.PostType, confirmedSince: param.confirmedSince!, isConfirmed: param.isConfirmed, hashCaption: param.hashCaption)
    //let productData = API.serializePost(post: post)
    completion(post,true)
}

/*
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
 */


func CreateCompany(company: Company, completed: @escaping (_ companyInstance: Company) -> ()) {
    let ref = Database.database().reference().child("companies").child(Auth.auth().currentUser!.uid)
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
            let refUpdate = Database.database().reference().child("CompanyUser").child(Auth.auth().currentUser!.uid)
            refUpdate.updateChildValues(["isCompanyRegistered":true,"companyID":companyReference.key!])
		}
        let categoryInstance: Company = Company(dictionary: companyData)
        completed(categoryInstance)
    })
}

func updateProductDetails(dictionary: [String: Any], productID: String) {
    
    let user = Singleton.sharedInstance.getCompanyUser()
    let ref = Database.database().reference().child("products").child(Auth.auth().currentUser!.uid).child(user.companyID!).child(productID)
    ref.updateChildValues(dictionary)
}
// A MARCO FUNCTION.
func UpdateYourCompanyInFirebase() {
	if let id = YourCompany.account_ID {
		let companyData: [String: Any] = serializeCompany(company: YourCompany)
		let ref = Database.database().reference().child("companies").child(id)
		ref.updateChildValues(companyData)
	}
}

// Uploads image to firebase, parameters: the image, the type of photo ("company", "product", etc.), the id of the item to upload
func getImage(id: String, completed: @escaping (_ image: UIImage) -> ()) {
    let fileName = id + ".png"
    let ref = Storage.storage().reference().child("images").child(fileName)
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

// Uploads image to firebase, parameters: the image, the type of photo ("company", "product", etc.), assignes a random ID that is returned.
func uploadImage(image: UIImage) -> String {
	guard let accountID = YourCompany.account_ID else { return "" }
	let id = "\(accountID)_\(Calendar.current.component(.year, from: Date()))_\(NSUUID().uuidString.lowercased())"
    let data = image.pngData()
    let fileName = id + ".png"
    let ref = Storage.storage().reference().child("images").child(fileName)
    ref.putData(data!, metadata: nil, completion: { (metadata, error) in
        if error != nil {
            debugPrint(error!)
            return
        }
        debugPrint(metadata!)
    })
    return id
}

func uploadImageToFIR(image: UIImage, childName: String, path: String, completion: @escaping (String,Bool) -> ()) {
    let data = image.jpegData(compressionQuality: 0.2)
    let fileName = path + ".png"
    let ref = Storage.storage().reference().child(childName).child(fileName)
    ref.putData(data!, metadata: nil, completion: { (metadata, error) in
        if error != nil {
            debugPrint(error!)
            completion("", true)
            return
        }else {
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                completion("", true)
                return
            }
            // You can also access to download URL after upload.
            ref.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completion("", true)
                    return
                }
                completion(downloadURL.absoluteString, false)
            }
        }
        debugPrint(metadata!)
    })
    //return id
}

func serializeCompany(company: Company) -> [String: Any] {
    let companyData: [String: Any] = [
        "account_ID": company.account_ID!,
        "name": company.name,
        "logo": company.logo!,
        "mission": company.mission,
        "website": company.website,
        "description": company.companyDescription,
        "accountBalance": company.accountBalance,
		"owner": company.owner_email,
        "referralcode": company.owner_email
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

func getFilteredInfluencers(category: [String:[AnyObject]],completion: @escaping ([String]?,String,[User]?) -> ()) {
    
    var mutatingCategory = category
    
    let usersRef = Database.database().reference().child("users")
    
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            let keys = dictionary.keys
            
            var userIDs = [String]()
            
            var user = [User]()
            
            var filteredCategory = [String]()
            
            if category.keys.contains("primaryCategory") {
                
                let categoryValueArray = category["primaryCategory"] as! [String]
                
                filteredCategory.append(contentsOf: categoryValueArray)
                
                mutatingCategory.removeValue(forKey: "primaryCategory")
                
            }
            
            
            for value in keys {
                
                let first  = dictionary[value] as! [String: AnyObject]
                
                //_ = first["primaryCategory"] as! String
                //Getting All Keys From Offer
                let categoryArray = mutatingCategory.keys
                
                
                var checkStatus = true
                for keyValue in categoryArray {
                    
                    //                    if !(category[keyValue]?.contains(first[keyValue] as! String))!{
                    //                       checkStatus = false
                    //                    }
                    
                    if (mutatingCategory[keyValue]?.contains(where: { (errer) -> Bool in
                        print("a=",errer)
                        print("b=",first[keyValue])
                        //return (first[keyValue]?.isEqual(errer))!
                        if (first[keyValue] as? String) != nil {
                            return (first[keyValue]?.isEqual(errer))!
                        }else{
                            return false
                        }
                    }))! == false {
                        checkStatus = false
                    }else{
                        
                    }
                    
                    
                }
                
                
                var checkCategoryArray = false
                
                if category.keys.contains("primaryCategory") {
                    //categories
                    if first.keys.contains("categories") {
                        
                        if let userCategoryArray = first["categories"] as? [String] {
                            
                            for userCategoryValue in userCategoryArray {
                                
                                let offerCategory = category["primaryCategory"] as! [String]
                                
                                if offerCategory.contains(userCategoryValue ){
                                    checkCategoryArray = true
                                    break
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
                
                if checkStatus == true && checkCategoryArray == true {
                    userIDs.append(first["id"] as! String)
                    user.append(User.init(dictionary: first))
                }
                
            }
            completion(userIDs, "success", user)
        }else{
            completion([], "error", nil)
        }

        
    }, withCancel: { (error) in
        
        completion([], "error", nil)
        
    })
    
//    usersRef.observe(.value, with: { (snapshot) in
//
//
//    }) { (error) in
//
//    }
}

func getAllProducts(path: String, completion: @escaping ([Product]) -> ()) {
    let productsRef = Database.database().reference().child("products").child(path)
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

func createTemplateOffer(pathString: String,edited: Bool,templateOffer: TemplateOffer,completion: @escaping (TemplateOffer,Bool) -> ()) {
    let offersRef = Database.database().reference().child("TemplateOffers").child(pathString)
    if edited == false {
    let offerKey = offersRef.childByAutoId()
    templateOffer.offer_ID = offerKey.key!
    var offerDictionary: [String: Any] = [:]
    offerDictionary = API.serializeTemplateOffer(offer: templateOffer)
    offerKey.updateChildValues(offerDictionary)
    completion(templateOffer, true)
    }else{
        var offerDictionary: [String: Any] = [:]
        offerDictionary = API.serializeTemplateOffer(offer: templateOffer)
        offersRef.removeValue()
        offersRef.updateChildValues(offerDictionary)
        completion(templateOffer, true)
    }
    
}



func sentOutOffers(pathString: String, templateOffer: TemplateOffer, completion: @escaping (TemplateOffer,Bool) -> ()) {
    let offersRef = Database.database().reference().child("SentOutOffers").child(pathString)
    var offerDictionary: [String: Any] = [:]
    offerDictionary = API.serializeTemplateOffer(offer: templateOffer)
    offersRef.updateChildValues(offerDictionary)
    completion(templateOffer, true)
}

func completedOffersToUsers(pathString: String, templateOffer: TemplateOffer) {
    
    let offersRef = Database.database().reference().child("SentOutOffersToUsers").child(pathString)
    var offerDictionary: [String: Any] = [:]
    offerDictionary = API.serializeTemplateOffer(offer: templateOffer)
    offersRef.updateChildValues(offerDictionary)
}

func sentOutTransactionToInfluencer(pathString: String,transactionData: [String: Any]) {
    
    let transactionRef = Database.database().reference().child("InfluencerTransactions").child(pathString)
    
    var valueArray = [[String:Any]]()
    
    transactionRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        print(snapshot.value)
        
        if let arrayValues = snapshot.value as? [[String: AnyObject]] {
            
            valueArray.append(contentsOf: arrayValues)
            valueArray.append(transactionData)
            let transactionRefVal = Database.database().reference().child("InfluencerTransactions")
            let data = [pathString: valueArray]
            transactionRefVal.updateChildValues(data)
            
//            for keyValues in arrayValues.keys {
//                
//                let singleValue = arrayValues[keyValues] as! [String: AnyObject]
//                valueArray.append(singleValue)
//                let transactionRefVal = Database.database().reference().child("InfluencerTransactions")
//                let data = [pathString: valueArray]
//                transactionRefVal.updateChildValues(data)
//                
//            }
            
        }else{
            
            let transactionRefVal = Database.database().reference().child("InfluencerTransactions")
            valueArray.append(transactionData)
            let data = [pathString: valueArray]
            transactionRefVal.updateChildValues(data)
            
        }
        
    }) { (error) in
        
        let transactionRefVal = Database.database().reference().child("InfluencerTransactions")
        let data = [pathString: valueArray]
        transactionRefVal.updateChildValues(data)
        
    }
    
    
    
}

//Mark: Influencer Amount Updated By Business User

func updateInfluencerAmountByReferral(user: User, amount: Double) {
    
    let transactionRef = Database.database().reference().child("users").child(user.id!)
    
    
    transactionRef.updateChildValues(["yourMoney":amount])
    
}

func removeTemplateOffers(pathString: String, templateOffer: TemplateOffer) {
    let offersRef = Database.database().reference().child("TemplateOffers").child(pathString)
    offersRef.removeValue()
}

func updateTemplateOffers(pathString: String, templateOffer: TemplateOffer, userID: [Any]) {
    let offersRef = Database.database().reference().child("TemplateOffers").child(pathString)
//    var userIDValue = [String]()
//    for uderIDs in userID {
//        userIDValue.append(uderIDs.id!)
//    }
    offersRef.updateChildValues(["user_IDs":userID])
    //offersRef.removeValue()
}

func getAllTemplateOffers(userID: String, completion: @escaping([TemplateOffer],String) -> Void) {
    
    let ref = Database.database().reference().child("TemplateOffers").child(userID)
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            var template = [TemplateOffer]()
            
            for value in totalValues.allKeys {
                var offer = totalValues[value] as! [String: AnyObject]
                let post = parseTemplateOffer(offer: offer)
                offer["posts"] = post as AnyObject
                let conDate = offer["offerdate"] as! String
                let exDate = offer["expiredate"] as! String
                let dateCon = DateFormatManager.sharedInstance.getDateFromStringWithFormat(dateString: conDate, format: "yyyy/MMM/dd HH:mm:ss")
                let dateEx = DateFormatManager.sharedInstance.getDateFromStringWithFormat(dateString: exDate, format: "yyyy/MMM/dd HH:mm:ss")
                offer["offerdate"] = dateCon as AnyObject?
                offer["expiredate"] = dateEx as AnyObject?
                template.append(TemplateOffer.init(dictionary: offer))
            }
            completion(template, "success")
        }else{
            completion([], "failure")
        }
        
    }) { (error) in
        completion([], "failure")
    }
    
}

func parseTemplateOffer(offer: [String: AnyObject]) -> [Post] {
    
    var postValues = [Post]()
    let post = offer["posts"] as! [NSDictionary]
    for value in post {
        
        let product = value["products"] as! [[String: AnyObject]]
        var productList = [Product]()
        for productValue in product {
            
            let productInitialized = Product.init(dictionary: productValue)
            productList.append(productInitialized)
        }
        
        let postInitialized = Post.init(image: "", instructions: value["instructions"] as? String ?? "", captionMustInclude: value["captionMustInclude"] as? String, products: productList, post_ID: value["post_ID"] as! String, PostType: value["PostType"] as! String, confirmedSince: value["confirmedSince"] as? Date, isConfirmed: (value["isConfirmed"] != nil), hashCaption: value["hashCaption"] as! String)
        postValues.append(postInitialized)
    }
    return postValues
}

func sendDepositAmount(deposit: Deposit,companyUser: String,completion: @escaping(Deposit,String) -> Void) {
    
    let ref = Database.database().reference().child("BusinessDeposit").child(companyUser)
    var offerDictionary: [String: Any] = [:]
    offerDictionary = API.serializeDepositDetails(deposit: deposit)
    ref.updateChildValues(offerDictionary)
    completion(deposit, "success")
}

func getDepositDetails(companyUser: String,completion: @escaping(Deposit?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("BusinessDeposit").child(companyUser)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            let deposit = Deposit.init(dictionary: totalValues as! [String : Any])
            completion(deposit, "success", nil)
        }else{
            completion(nil, "new", nil)
        }
    }) { (error) in
           completion(nil, "failure", error)
    }
}

//MARK: Dwolla Customer Creation

func createDwollaCustomerToFIR(object: DwollaCustomerInformation) {
    
    let ref = Database.database().reference().child("DwollaCustomers").child(Auth.auth().currentUser!.uid).child(object.acctID)
    var customerDictionary: [String: Any] = [:]
    customerDictionary = API.serializeDwollaCustomers(object: object)
    ref.updateChildValues(customerDictionary)
}

func getDwollaFundingSource(completion: @escaping([DwollaCustomerFSList]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("DwollaCustomers").child(Auth.auth().currentUser!.uid)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            var objects = [DwollaCustomerFSList]()
            
            for value in totalValues.allKeys {
                
                let fundSource = DwollaCustomerFSList.init(dictionary: totalValues[value] as! [String: Any])
                objects.append(fundSource)
                
            }
            completion(objects, "success", nil)
        }
        
        
    }) { (error) in
        completion(nil, "success", error)
    }
    
}

func fundTransferAccount(transferURL: String,accountID: String, Obj: DwollaCustomerFSList, currency: String, amount: String) {
    
    let ref = Database.database().reference().child("FundTransfer").child(Auth.auth().currentUser!.uid).child(accountID)
    let fundTransfer: [String: Any] = ["accountID":accountID,"transferURL":transferURL,"currency":currency,"amount":amount,"name":Obj.name,"mask":Obj.mask,"customerURL":Obj.customerURL,"FS":Obj.customerFSURL,"firstname":Obj.firstName,"lastname":Obj.lastName]
    ref.updateChildValues(fundTransfer)
    
//    var fundingSURL = [String]()
//
//    let getRef = Database.database().reference().child("FundTransfer").child(Auth.auth().currentUser!.uid).child(accountID)
//
//    getRef.observeSingleEvent(of: .value, with: { (snapshot) in
//
//        if let value = snapshot.value as? NSDictionary{
//
//           if let fundingURL = value["transferURL"] as? [String] {
//
//            if fundingURL.count != 0 {
//
//                fundingSURL.append(contentsOf: fundingURL)
//                fundingSURL.append(transferURL)
//                let ref = Database.database().reference().child("FundTransfer").child(Auth.auth().currentUser!.uid).child(accountID)
//                let fundTransfer: [String: Any] = ["accountID":accountID,"transferURL":fundingSURL]
//                ref.updateChildValues(fundTransfer)
//
//            }else{
//
//                let ref = Database.database().reference().child("FundTransfer").child(Auth.auth().currentUser!.uid).child(accountID)
//                fundingSURL.append(transferURL)
//                let fundTransfer: [String: Any] = ["accountID":accountID,"transferURL":fundingSURL]
//                ref.updateChildValues(fundTransfer)
//
//            }
//
//            }
//            //if
//
//        }else{
//
//            let ref = Database.database().reference().child("FundTransfer").child(Auth.auth().currentUser!.uid).child(accountID)
//            fundingSURL.append(transferURL)
//            let fundTransfer: [String: Any] = ["accountID":accountID,"transferURL":fundingSURL]
//            ref.updateChildValues(fundTransfer)
//
//        }
//
//    }) { (error) in
//
//        let ref = Database.database().reference().child("FundTransfer").child(Auth.auth().currentUser!.uid).child(accountID)
//        fundingSURL.append(transferURL)
//        let fundTransfer: [String: Any] = ["accountID":accountID,"transferURL":fundingSURL]
//        ref.updateChildValues(fundTransfer)
//
//    }
    
    
    
    
    
}

func transactionInfo(completion: @escaping([TransactionInfo]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("FundTransfer").child("3225555942")
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            var objects = [TransactionInfo]()
            
            for value in totalValues.allKeys {
                
                let transactionInfo = TransactionInfo.init(dictionary: totalValues[value] as! [String: Any])
                objects.append(transactionInfo)
                
            }
            completion(objects, "success", nil)
        }
        
        
    }) { (error) in
        completion(nil, "success", error)
    }
    
}

func calculateCostForUser(offer: Offer, user: User, increasePayVariable: Double = 1.00) -> Double {
    return 0.055 * user.averageLikes! * Double(offer.posts.count) * increasePayVariable
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

func UpdateCompanyInDatabase(company: Company) {
    let ref = Database.database().reference().child("companies")
	let companyData = serializeCompany(company: company)
    ref.child(company.account_ID!).updateChildValues(companyData)
}
//Create Company User
func CreateCompanyUser(companyUser: CompanyUser) -> CompanyUser {
    
    let ref = Database.database().reference().child("CompanyUser")
    let values: [String: Any] = serializeCompanyUser(companyUser: companyUser)
    let offerRef = ref.child(values["userID"] as! String)
    offerRef.updateChildValues(values)
    return companyUser
    
}
//Serialize Company User
func serializeCompanyUser(companyUser: CompanyUser) -> [String: Any] {
    
    let companyUserData: [String: Any] = [
        "userID": companyUser.userID!,
        "email": companyUser.email!,
        "refreshToken": companyUser.refreshToken!,
        "token": companyUser.token!,"isCompanyRegistered": companyUser.isCompanyRegistered!,"companyID":companyUser.companyID!]
    return companyUserData
    
}
//
func getCurrentCompanyUser(userID: String, completion: @escaping (CompanyUser?,String) -> Void) {
    
    let ref = Database.database().reference()
    ref.child("CompanyUser").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        if let value = snapshot.value as? NSDictionary{
           let companyUser = CompanyUser.init(dictionary: value as! [String : Any])
           completion(companyUser, "")
        }else{
          completion(nil, "error")
        }
    }) { (error) in
        print(error.localizedDescription)
    }
    
    
}

//MARK: Get User By Refferal Code

func getUserByReferralCode(referralcode: String,completion: @escaping (User?) -> Void) {
    
    let usersRef = Database.database().reference().child("users")
    
    usersRef.queryOrdered(byChild: referralcode).observeSingleEvent(of: .value) { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            for values in dictionary.keys {
                
                if let dict = dictionary[values] as? [String: AnyObject] {
                    
                    if dict.keys.contains("referralcode") {
                    
                    if dict["referralcode"] as! String == referralcode {
                        
                        let userInstance = User(dictionary: dict)
                        if userInstance.referralcode == referralcode {
                            completion(userInstance)
                            break
                        }
                        
                    }
                    }
                    
                }
                
            }
            
//            let userInstance = User(dictionary: dictionary)
//            if userInstance.referralcode == referralcode {
//                completion(userInstance)
//            }
            
        }
        
    }
    
//    usersRef.queryOrdered(byChild: referralcode).observe(.childAdded, with: { (snapshot) in
//
//        if let dictionary = snapshot.value as? [String: AnyObject] {
//            let userInstance = User(dictionary: dictionary)
//            if userInstance.referralcode == referralcode {
//               completion(userInstance)
//            }
//
//        }
//
//    }) { (error) in
//        completion(nil)
//    }
    
//    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
//        if let dictionary = snapshot.value as? [String: AnyObject] {
//            let userInstance = User(dictionary: dictionary as! [String : AnyObject])
//            completion(userInstance)
//        }
//    }, withCancel: nil)
    
}

func getAdminValues(completion: @escaping (String) -> Void) {
    
    Database.database().reference().child("Admin").observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let value = snapshot.value as? NSDictionary{
            
            
            
            let fsource = value["SourceFundingSource"] as! String
            let commision = value["paycommision"] as! Double
            Singleton.sharedInstance.setAdminFS(value: fsource)
            Singleton.sharedInstance.setCommision(value: commision)
            completion("")
            
        }else{
            completion("error")
        }
    }) { (error) in
        
    }
    
}

//
func getCompany(companyID: String,completion: @escaping (Company?,String) -> Void) {
    let user = Auth.auth().currentUser!.uid
    Database.database().reference().child("companies").child(user).child(companyID).observeSingleEvent(of: .value, with: { (snapshot) in
        
            if let value = snapshot.value as? NSDictionary{
                let company = Company.init(dictionary: value as! [String : Any])
                completion(company,"")
            }else{
            completion(nil, "error")
        }
    }) { (error) in
        
    }
    
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
