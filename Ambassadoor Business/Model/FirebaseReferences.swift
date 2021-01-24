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
                do {
                    let offerInstance = try Offer(dictionary: offerDictionary! as! [String : AnyObject])
                    offers.append(offerInstance)
                } catch let error {
                    print(error)
                }
                
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
    let user = Auth.auth().currentUser!.uid
    let ref = Database.database().reference().child("offers").child(user)
    let offerRef = ref.childByAutoId()
    let values: [String: AnyObject] = serializeOffer(offer: offer)
    offerRef.updateChildValues(values)
    return offer
}

func serializeOffer(offer: Offer) -> [String: AnyObject] {
    var post_IDS: [[String: Any]] = [[:]]
    for post in offer.posts {
        post_IDS.append(API.serializePost(post: post) as [String : Any])
    }
    var values = [
        "money": offer.money as AnyObject,
        "company": offer.company?.account_ID as AnyObject,
        "posts": post_IDS as AnyObject,
        "offerdate": offer.offerdate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ssZ") as AnyObject,
        "offer_ID": offer.offer_ID as AnyObject,
        "user_ID": offer.user_ID as AnyObject,
        "expiredate": offer.expiredate.toString(dateFormat: "yyyy/MMM/dd HH:mm:ssZ") as AnyObject,
        "allPostsConfirmedSince": offer.allPostsConfirmedSince?.toString(dateFormat: "yyyy/MMM/dd HH:mm:ssZ") ?? " ",
        "allConfirmed": offer.allConfirmed,
        "isAccepted": offer.isAccepted,
        "isExpired": offer.isExpired,
        ] as [String : AnyObject]
    if let templateOffer = offer as? TemplateOffer {
        values["targetCategories"] = templateOffer.targetCategories as AnyObject
        values["locationFilter"] = templateOffer.locationFilter as String as AnyObject
        values["genders"] = templateOffer.genders as [String] as AnyObject
    }
    return values
}



// Updates values for user in firebase via their id returns that same user
//func UpdateUserInDatabase(instagramUser: User) -> User {
//    let ref = Database.database().reference().child("users")
//	let userData = API.serialize(user: instagramUser, id: instagramUser.id)
//    ref.child(instagramUser.id).updateChildValues(userData)
//    return instagramUser
//}

//Creates an account with nothing more than the username of the account. Returns instance of account returned from firebase


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
        let post = Post.init(image: param.image!, instructions: param.instructions, captionMustInclude: param.captionMustInclude!, products: param.products!, post_ID: postReference.key!, PostType: param.PostType, confirmedSince: param.confirmedSince!, isConfirmed: param.isConfirmed, hashCaption: param.hashCaption, status: param.status, hashtags: param.hashtags, keywords: param.keywords, isPaid: param.isPaid, PayAmount: 0.0)
        let productData = API.serializePost(post: post)
        postReference.updateChildValues(productData)
        completion(post, true)
    })

}

func getCreatePostUniqueID(param: Post, completion: @escaping (Post,Bool) -> ()) {
    
    let ref = Database.database().reference()
    let postReference = ref.childByAutoId()
    let post = Post.init(image: param.image!, instructions: param.instructions, captionMustInclude: param.captionMustInclude!, products: param.products!, post_ID: postReference.key!, PostType: param.PostType, confirmedSince: param.confirmedSince!, isConfirmed: param.isConfirmed, hashCaption: param.hashCaption, status: param.status, hashtags: param.hashtags, keywords: param.keywords, isPaid: param.isPaid, PayAmount: 0.0)
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
func UpdateYourCompanyInFirebase(company: Company) {
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
    let data = image.resizeImage(image: image, targetSize: CGSize.init(width: 256.0, height: 256.0)).jpegData(compressionQuality: 1)
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
        "referralcode": company.owner_email,
        "userId": Auth.auth().currentUser!.uid,
        "isForTesting": API.isForTesting
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

func getFilteredInfluencers(category: [String:[AnyObject]],completion: @escaping (String,[User]?) -> ()) {
    
    var BusinessFilters = category
    
    let usersRef = Database.database().reference().child("users")
    
    usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
        
        if let userDatabase = snapshot.value as? [String: AnyObject] {
            
            let keys = userDatabase.keys //all user IDs
            
            var user = [User]()
            
            var filteredCategory = [String]() //all categories in the template offer.
            
            if category.keys.contains("categories") {
                
                let categoryValueArray = category["categories"] as! [String]
                
                filteredCategory.append(contentsOf: categoryValueArray)
                
                BusinessFilters.removeValue(forKey: "categories")
                
            }
			
			//filteredcategory list is now populated
            
            for userID in keys { //FOR EACH USER ID IN USER DATABASE
                
                let userData  = userDatabase[userID] as! [String: AnyObject] //Getting User data from ID.
                
                let BusinessFilterKeys = BusinessFilters.keys //Getting every property the users's have and putting it into a list, for example
                
				var categoryMatch = !BusinessFilterKeys.contains("categories")
				var genderMatch = !BusinessFilterKeys.contains("gender")
				var locationMatch = !BusinessFilterKeys.contains("zipCode")
				
				//Gender filter
				
				if !genderMatch {
					let gender: [String] = BusinessFilters["gender"] as! [String]
					if let userGender = userData["gender"] as? String {
						if gender.contains(userGender) {
							genderMatch = true
						}
					}
				}
				
				
				//ZIP CODE
								
                if !locationMatch && genderMatch {
					let zips: [String] = BusinessFilters["zipCode"] as! [String]
					if let userZip = userData["zipCode"] as? String {
						if zips.contains(userZip) {
							locationMatch = true
						}
					}
				}
                
                //CATEGORIES
				
								
                if !categoryMatch && locationMatch && genderMatch {
					let businessCats: [String] = BusinessFilters["categories"] as! [String]
					if let userCats = userData["categories"] as? [String] {
						//cats = Checks if user is a crazy cat person.
						//Okay maybe I shouldn't joke when commenting.
						for userCat in userCats {
							let catExistsInBusinessFilter = businessCats.contains(userCat)
							if catExistsInBusinessFilter {
								categoryMatch = true
								break
							}
						}
					}
				}
				
				//MAKE FINAL SAY
                
                if categoryMatch && genderMatch && locationMatch {
                    user.append(User.init(dictionary: userData))
                }
				
				//userIDs.shuffle()
                //user.shuffle()
                
                
            }
            let sortedPriority = user.sorted(by: { $0.priorityValue ?? 0 < $1.priorityValue ?? 0 })
            user.removeAll()
            user.append(contentsOf: sortedPriority)
            completion("success", user)
        }else{
            completion("error", nil)
        }

        
    }, withCancel: { (error) in
        
        completion("error", nil)
        
    })
    
}

func getAllProducts(path: String, completion: @escaping ([Product]?) -> ()) {
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
        }else{
            completion(nil)
        }
    }, withCancel: nil)
}

///This function is no longer being used by Tesseract Freelance, LLC.

//func sendOffer(offer: Offer, money: Double, completion: @escaping (Offer) -> ()) {
//    let offersRef = Database.database().reference().child("offers")
//    let offerKey = offersRef.childByAutoId()
//    offer.offer_ID = offerKey.key!
//    var offerDictionary: [String: Any] = [:]
//    if type(of: offer) == TemplateOffer.self {
//        findInfluencers(offer: offer as! TemplateOffer, money: money, completion: { (o) in
//            offerDictionary = API.serializeTemplateOffer(offer: o)
//            offerKey.updateChildValues(offerDictionary)
//        })
//    } else {
//        offerDictionary = API.serializeOffer(offer: offer)
//        offerKey.updateChildValues(offerDictionary)
//    }
//    YourCompany.accountBalance -= offer.money
//    UpdateCompanyInDatabase(company: YourCompany)
//    debugPrint(offerDictionary)
//}

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


// We do separate Commission and User Amount Sentout Offers too
func sentOutOffers(pathString: String, templateOffer: TemplateOffer, completion: @escaping (TemplateOffer,Bool) -> ()) {
    print(templateOffer.posts.count)
    let offersRef = Database.database().reference().child("SentOutOffers").child(pathString)
    var offerDictionary: [String: Any] = [:]
    offerDictionary = API.serializeTemplateOffer(offer: templateOffer)
    offersRef.updateChildValues(offerDictionary)
    completion(templateOffer, true)
}

// We do separate Commission and User Amount Sentout Offers too
func sentOutOffersToOfferPool(pathString: String, templateOffer: TemplateOffer, completion: @escaping (TemplateOffer,Bool) -> ()) {
    print(templateOffer.posts.count)
    
    let offersRef = Database.database().reference().child("OfferPool").child(pathString)
    
    offersRef.observeSingleEvent(of: .value) { (offerPoolSnap) in
        
        if offerPoolSnap.exists(){
           
            if let offerExisted = offerPoolSnap.value as? [String: AnyObject]{
                
                do {
                    let tempOfferPool = try TemplateOffer.init(dictionary: offerExisted)
                    print(tempOfferPool.cashPower!)
                    tempOfferPool.cashPower! += templateOffer.cashPower!
                    
                    //tempOfferPool.accepted = templateOffer.accepted
                    
                    tempOfferPool.category = templateOffer.category
                    
                    tempOfferPool.genders = templateOffer.genders
                    
                    tempOfferPool.locationFilter = templateOffer.locationFilter
                    
                    tempOfferPool.money += templateOffer.money
                    
                    tempOfferPool.originalAmount += templateOffer.originalAmount
                    
                    tempOfferPool.commission! += templateOffer.commission!
                    
                    tempOfferPool.incresePay! = templateOffer.incresePay!
                    
                    tempOfferPool.offerdate = templateOffer.offerdate
                    
                    tempOfferPool.referralAmount! += templateOffer.referralAmount!
                    
                    tempOfferPool.referralCommission! += templateOffer.referralCommission!
                    
                    tempOfferPool.mustBeTwentyOne = templateOffer.mustBeTwentyOne
                    
                    tempOfferPool.referralID = templateOffer.referralID
                    
                    var updatedPosts = [Post]()
                    
                    for postValue in templateOffer.posts {
                        
                        var matchingTag = false
                        
                        for (index,tempPostValue) in tempOfferPool.posts.enumerated() {
                            
                            if tempPostValue.post_ID == postValue.post_ID {
                               matchingTag = true
                               tempOfferPool.posts.remove(at: index)
                                updatedPosts.append(postValue)
                            }
                            
                        }
                        
                        if !matchingTag{
                           updatedPosts.append(postValue)
                        }
                        
                        
                    }
                    
                    
                    tempOfferPool.posts.append(contentsOf: updatedPosts)
                    
                    var offerDictionary: [String: Any] = [:]
                    offerDictionary = API.serializeTemplateOffer(offer: tempOfferPool)
                    offersRef.updateChildValues(offerDictionary)
                    completion(tempOfferPool, true)
                    
                    
                } catch let error {
                    print(error)
                }
                
            }
            
        }else{
            
            var offerDictionary: [String: Any] = [:]
            offerDictionary = API.serializeTemplateOffer(offer: templateOffer)
            offersRef.updateChildValues(offerDictionary)
            completion(templateOffer, true)
            
        }
        
    }
    
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
    
    let transactionRef = Database.database().reference().child("users").child(user.id)
    
    
    transactionRef.updateChildValues(["yourMoney":amount])
    
}

func UpdatePriorityValue(user: User) {
    
    let transactionRef = Database.database().reference().child("users").child(user.id)
    
    transactionRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let userData = snapshot.value as? NSDictionary{
            var priorityValue = 0
            if (userData["priorityValue"] as? Int) != nil {
            priorityValue = userData["priorityValue"] as! Int + 24
            }else{
                
            priorityValue = 24
                
            }
            transactionRef.updateChildValues(["priorityValue":priorityValue])
            
        }
        
    }) { (error) in
        
    }
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
            let tempGroup = DispatchGroup()
            
            for value in totalValues.allKeys {
                tempGroup.enter()
                print("start =",value)
                var offer = totalValues[value] as! [String: AnyObject]
                let post = parseTemplateOffer(offer: offer)
                offer["posts"] = post as AnyObject
                let conDate = offer["offerdate"] as! String
                let exDate = offer["expiredate"] as! String
                let dateCon = DateFormatManager.sharedInstance.getDateFromStringWithAutoFormat(dateString: conDate)
                let dateEx = DateFormatManager.sharedInstance.getDateFromStringWithAutoFormat(dateString: exDate)
                offer["offerdate"] = dateCon as AnyObject?
                offer["expiredate"] = dateEx as AnyObject?
                do {
                    let temValue = try TemplateOffer.init(dictionary: offer)
                    
                    if temValue.isFinished() == []{
                        
                        let offerPoolRef = Database.database().reference().child("OfferPool").child(userID).child(temValue.offer_ID)
                        offerPoolRef.observeSingleEvent(of: .value) { (offerPool) in
                            
                            if offerPool.exists(){
                                temValue.isStatistic = true
                                print("1 =",value)
                                template.append(temValue)
                                
                                if let offerPoolOffer = offerPool.value as? [String: AnyObject]{
                                    
                                    do {
                                        let offer = try TemplateOffer.init(dictionary: offerPoolOffer)
                                        let offerStat = OfferStatistic.init(offer: offer)
                                        temValue.offerStatistics = offerStat
                                        temValue.offerStatistics?.getInformation()
                                        
                                    } catch let error {
                                        print(error)
                                    }
                                    
                                    //if let accepted = offerPoolOffer["accepted"] as? [String]{
                                        
                                       
                                        
                                    //}
                                    
                                }
                                
                                tempGroup.leave()
                            }else{
                                template.append(temValue)
                                tempGroup.leave()
                                print("1 =")
                            }
                            
                            
                            
                        }
                        
                    }else{
                        template.append(temValue)
                        tempGroup.leave()
                        print("end=", value)
                    }
                    
                    
                } catch let error {
                    print(error)
                }
                
            }
            
            tempGroup.notify(queue: .main) {
                
                template.sort{$0.lastEdited.compare($1.lastEdited) == .orderedDescending}
                
                completion(template, "success")
            }
            
        }else{
            completion([], "failure")
        }
        
    }) { (error) in
        completion([], "failure")
    }
    
}

func parseTemplateOffer(offer: [String: AnyObject]) -> [Post] {
    
    var postValues = [Post]()
    let post = offer["posts"] as? [NSDictionary] ?? []
    for value in post {
        
        var productList = [Product]()
		if let product = value["products"] as? [[String: AnyObject]] {
			for productValue in product {
				
				let productInitialized = Product.init(dictionary: productValue)
				productList.append(productInitialized)
			}
		}
		
        let postInitialized = Post.init(image: "", instructions: value["instructions"] as? String ?? "", captionMustInclude: value["captionMustInclude"] as? String, products: productList, post_ID: value["post_ID"] as! String, PostType: value["PostType"] as! String, confirmedSince: value["confirmedSince"] as? Date, isConfirmed: (value["isConfirmed"] as? Bool ?? false), hashCaption: value["hashCaption"] as! String, status: value["status"] as? String ?? "", hashtags: value["hashtags"] as? [String] ?? [], keywords: value["keywords"] as? [String] ?? [], isPaid: value["isPaid"] as? Bool ?? false, PayAmount: value["PayAmount"] as? Double ?? 0.0)
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
    //companyUser
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

//MARK: Statistic Page Data

func getStatisticsData(completion: @escaping([Statistics]?,String,Error?) -> Void) {
    
    let ref = Database.database().reference().child("SentOutOffers").child(Auth.auth().currentUser!.uid)
    
	var attempted = 0
	
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        var staticsArray = [Statistics]()
        
        if let totalValues = snapshot.value as? NSDictionary{
            
            for (index, offerKey) in totalValues.allKeys.enumerated() {
                
                if let Offer = totalValues[offerKey] as? NSDictionary {
                    
                    
                    if let userIDs = Offer["user_IDs"] as? [String] {
                        
                        for (userIDIndex,userID) in userIDs.enumerated() {
                            
                            let refUserPost = Database.database().reference().child("SentOutOffersToUsers").child(userID).child(offerKey as! String)
                            
                            //print(offerKey)
                            
                            refUserPost.observeSingleEvent(of: .value, with: { (userpublish) in
                                
                                let object = Statistics()
                                
                                if let offerValues = userpublish.value as? NSDictionary {
                                    
                                    object.offerID = offerKey as! String
                                    object.userID = userID
                                    object.offer = offerValues
                                    staticsArray.append(object)
                                    
                                }else{
                                    
                                    object.offerID = offerKey as! String
                                    object.userID = userID
                                    staticsArray.append(object)
                                }
                                
								attempted += 1
								
								if attempted >= totalValues.allKeys.count {
									completion(staticsArray, "success", nil)
								}
                                
                            }) { (error) in
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            
        }
    }) { (error) in
        
        completion(nil, "success", error)
        
    }
     
}

//MARK: Get Instagram Post

func getInstagramPosts(statisticsData: [Statistics],completion: @escaping([String: instagramOfferDetails]?,String,Error?) -> Void) {
    
    var instagramOfferDetailsArray = [String: instagramOfferDetails]()
    
    
    for (index,statistics) in statisticsData.enumerated() {
        
        //let ref = Database.database().reference().child("InfluencerInstagramPost").child("3225555942").child("XXXDefault")
        
        let ref = Database.database().reference().child("InfluencerInstagramPost").child(statistics.userID).child(statistics.offerID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            print(snapshot.value)
            
            if let instagramPostOffer = snapshot.value as? NSDictionary {
                
                for offerKey in instagramPostOffer.allKeys {
                    
                    if let instagramPost = instagramPostOffer[offerKey] as? NSDictionary {
                        
                        if instagramOfferDetailsArray.keys.contains(statistics.userID){
                            let insData = instagramOfferDetailsArray[statistics.userID]
                            
                            if let commentsData = instagramPost["comments"] as? NSDictionary {
                                
                                insData?.commentsCount = insData!.commentsCount + (commentsData["count"] as! Int)
                                
                            }
                            
                            if let likesData = instagramPost["likes"] as? NSDictionary {
                                
                                insData?.likesCount = insData!.likesCount + (likesData["count"] as! Int)
                                
                            }
                            
                            if let userData = instagramPost["user"] as? NSDictionary {
                                insData?.userInfo = userData
                            }
                            
                            instagramOfferDetailsArray[statistics.userID] = insData
                            
                        }else{
                            
                            let insData = instagramOfferDetails()
                            
                            if let commentsData = instagramPost["comments"] as? NSDictionary {
                                
                                insData.commentsCount = (commentsData["count"] as! Int)
                                
                            }
                            
                            if let likesData = instagramPost["likes"] as? NSDictionary {
                                
                                insData.likesCount = (likesData["count"] as! Int)
                                
                            }
                            
                            if let userData = instagramPost["user"] as? NSDictionary {
                                insData.userInfo = userData
                            }
                            
                            instagramOfferDetailsArray[statistics.userID] = insData
                            
                        }
                        
                    }
                    
                }
               

                
            }
            
            if index == statisticsData.count - 1 {
                completion(instagramOfferDetailsArray, "success", nil)
            }
            
        }) { (error) in
            
            completion(nil, "failure", error)
            
        }
        
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


//OLD DISTRUBUTE ALGOITHM WRITTEN BY CHRIS CHOMIKI AND OWNED BY TESSERACT FREELANCE, LLC.
//THIS APP NO LONGER USES THIS ALGORITHM.

//func findInfluencers(offer: TemplateOffer, money: Double, completion: @escaping (TemplateOffer) -> ()) {
//    var moneyForOffer = money
//    var count = 0
//    GetAllUsers(completion: { (users) in
//		var shuffledUsers : [User] = users
//		shuffledUsers.shuffle()
//        for user in shuffledUsers {
//            if moneyForOffer <= 0 {
//                return
//            }
//			let cost: Double = calculateCostForUser(offer: offer, user: user)
//			var inList: Bool = false
//			for zip in offer.zipCodes {
//				if user.zipCode == zip {
//					inList = true
//				}
//			}
//			for cat in offer.targetCategories {
//				if user.primaryCategory == cat {
//					inList = true
//				}
//			}
//            for gender in offer.genders {
//                if user.gender == gender {
//                    inList = true
//                }
//            }
//            if inList {
//                offer.user_IDs.append(user.id!)
//                count += 1
//                moneyForOffer -= cost
//            }
//        }
//        completion(offer)
//    })
//}

func UpdateCompanyInDatabase(company: Company) {
    let ref = Database.database().reference().child("companies").child(Auth.auth().currentUser!.uid)
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
        "token": companyUser.token!,"isCompanyRegistered": companyUser.isCompanyRegistered!,"companyID":companyUser.companyID!,"businessReferral": companyUser.businessReferral!, "isForTesting": API.isForTesting]
    return companyUserData
    
}
//
func getCurrentCompanyUser(userID: String,signInButton: UIButton? = nil, completion: @escaping (CompanyUser?,String) -> Void) {
    
    var isGetData: Bool = false
    
    let ref = Database.database().reference().ref.child("CompanyUser").child(userID)
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        isGetData = true
        if let value = snapshot.value as? NSDictionary{
           let companyUser = CompanyUser.init(dictionary: value as! [String : Any])
            companyUser.deviceFIRToken = global.deviceFIRToken
            let updateRef = Database.database().reference().child("CompanyUser").child(userID)
            updateRef.updateChildValues(["deviceFIRToken":global.deviceFIRToken])
           completion(companyUser, "")
        }else{
//            Auth.auth().currentUser?.delete(completion: { (error) in
//
//            })
          completion(nil, "error")
        }
    }) { (error) in
        print(error.localizedDescription)
        }
    if signInButton != nil{
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        if !isGetData{
            signInButton!.setTitle("Sign In", for: .normal)
            ref.removeAllObservers()
        }
       //completion(nil, "error")
    }
    }
    
}

//MARK: Get User By Refferal Code

func getUserByReferralCode(referralcode: String,completion: @escaping (User?) -> Void) {
    
    let usersRef = Database.database().reference().child("users")
        
        let query = usersRef.queryOrdered(byChild: "referralcode").queryEqual(toValue: referralcode)
        
        query.observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let userInstance = User(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
                completion(userInstance)
                
            }
            
        }
    
}

func sentReferralAmountToBusiness(referralID: String,completion: @escaping(CompanyUser?)->Void) {
    
    let usersRef = Database.database().reference().child("CompanyUser")
    
    let query = usersRef.queryOrdered(byChild: "businessReferral").queryEqual(toValue: referralID)
    
    query.observeSingleEvent(of: .value) { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {
            
            let userInstance = CompanyUser(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
            completion(userInstance)
            
            
        }
        
    }
    
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
func getCompany(companyID: String,signInButton: UIButton? = nil,completion: @escaping (Company?,String) -> Void) {
    let user = Auth.auth().currentUser!.uid
    //let user = "GoQjJPCnHBVRTc5PxfnjohUWcVw2"
    let ref = Database.database().reference().child("companies").child(user).child(companyID)
    var isGetData: Bool = false
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
            isGetData = true
            if let value = snapshot.value as? NSDictionary{
                let company = Company.init(dictionary: value as! [String : Any])
                completion(company,"")
            }else{
            completion(nil, "error")
        }
    }) { (error) in
        
    }
    
    if signInButton != nil{
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        
        if !isGetData{
            signInButton!.setTitle("Sign In", for: .normal)
            ref.removeAllObservers()
            completion(nil, "error")
            
        }
    }
    }
    
}

func getAllDistributedOffers(completion: @escaping (_ status: Bool,_ offers: [TemplateOffer]?) -> ()){
	guard let YourCompany = YourCompany else {return}
	guard let id = YourCompany.userID else {return}
   // let id = "GoQjJPCnHBVRTc5PxfnjohUWcVw2"
	let offerPoolRef = Database.database().reference().child("OfferPool").child(id)
    offerPoolRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let allOfferDict = snapshot.value as? [String: [String:AnyObject]]{
            var offersList = [TemplateOffer]()
            for (_, offerDict) in allOfferDict {
                if isDeseralizable(dictionary: offerDict, type: .offer).count == 0{
                    do {
                        let offer = try TemplateOffer.init(dictionary: offerDict)
                       // if offer.offer_ID == "-MGirAckIGCn5IqxPqmb"{
                        offersList.append(offer)
                        //}
                    } catch let error {
                        print(error)
                    }
                }
            }
			offersList.sort { (offer1, offer2) -> Bool in
				return offer1.offerdate > offer2.offerdate
			}
            completion(true, offersList)
        }else{
            let offersList = [TemplateOffer]()
           completion(false, offersList)
        }
    }) { (error) in
        completion(false, nil)
    }
}

func getInfluencersWhoAcceptedOffer(offer: Offer, completion: @escaping(_ status: Bool, _ users: [User]?)->()){
	if offer.accepted != nil {
        
        
       let filteredFinalUser = global.allInfluencers.filter { (user) -> Bool in
            
           let filteredUser = offer.accepted!.filter({ (userId) -> Bool in
                
                return user.id == userId
                
            })
            
            return filteredUser.count != 0 ? true : false
            
        }
        
        completion(true, filteredFinalUser)
        
        
//		var users = [User]()
//        var countTag = 0
//
//        for (_,userId) in offer.accepted!.enumerated() {
//			let userRef = Database.database().reference().child("users").child(userId)
//            print("post1",userRef)
//			userRef.observeSingleEvent(of: .value, with: { (userSnapshot) in
//
//                countTag += 1
//				if let userDict = userSnapshot.value as? [String: Any] {
//					let user = User.init(dictionary: userDict)
//					users.append(user)
//				}
//				if countTag >= offer.accepted!.count {
//					completion(true, users)
//				}
//
//			}) { (userError) in
//				completion(false, nil)
//			}
//		}
	} else {
		completion(true, [])
	}
}

func getInfluencersWhoPostedForOffer(offer: Offer, completion: @escaping(_ status: Bool, _ users: [PostInfo]?)->()){
   var postInfo = [PostInfo]()
	if offer.accepted != nil {
		var attempted = 0
        for (_,userId) in offer.accepted!.enumerated() {
			let sentOutOffer = Database.database().reference().child("SentOutOffersToUsers").child(userId).child(offer.offer_ID)
            print("post2",sentOutOffer)
			sentOutOffer.observeSingleEvent(of: .value, with: { (sentOutAnapshot) in
                
                attempted += 1
			if let sentOutOfferDict = sentOutAnapshot.value as? [String: AnyObject]{
					do {
						let sentOutOffer = try Offer.init(dictionary: sentOutOfferDict)
						for post in sentOutOffer.posts {
							if post.status == "posted" || post.status == "verified" || post.status == "paid" {
								let postInfoValue = PostInfo.init(imageUrl: "", userWhoPosted: nil, associatedPost: post, caption: "", datePosted: "", userId: userId, offerId: offer.offer_ID)
								postInfo.append(postInfoValue)
							}
						}
						
						if attempted >= offer.accepted!.count {
							completion(true, postInfo)
						}
					} catch let error {
						print(error)
					}
				}
			}) { (sentOutError) in
                
                
                
            }
			
		}
		
	}
}

func getPostUserDetails(postInfo: [PostInfo], completion: @escaping(_ status: Bool,_ postInfo: [PostInfo]?)->()) {
    
    var modifiedPostInfo = [PostInfo]()
    
    for (index,post) in postInfo.enumerated() {
            
            var postDetail = post
            
            let userRef = Database.database().reference().child("users").child(post.userId!)
            print("post3",userRef)
            
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let userDict = snapshot.value as? [String: Any]{
                    
                    let user = User.init(dictionary: userDict)
                    postDetail.userWhoPosted = user
                    modifiedPostInfo.append(postDetail)
                    //let postInfo = PostInfo.init(dictionary: )
                    
                }
                
				if modifiedPostInfo.count >= postInfo.count {
                    
                    completion(true, modifiedPostInfo)
                    
                }
                
            }) { (error) in
                
            }
            
        }
    
}

func getInstagramPostByOffer(postInfo: [PostInfo], completion: @escaping(_ status: Bool,_ postInfo: [PostInfo]?)->()) {
	var modifiedPostInfo = [PostInfo]()
	var attempted = 0
	for (index,post) in postInfo.enumerated() {
		var postDetail = post
		let instaRef = Database.database().reference().child("InfluencerInstagramPost").child(postDetail.userId!).child(postDetail.offerId!).child(postDetail.associatedPost!.post_ID)
        
        print("post4",instaRef)
		instaRef.observeSingleEvent(of: .value, with: { (snapshot) in
			if let instaPostDict = snapshot.value as? [String: AnyObject]{
				let instaPost = InfluencerInstagramPost.init(dictionary: instaPostDict)
				postDetail.caption = instaPost.caption
				postDetail.imageUrl = instaPost.images!
				modifiedPostInfo.append(postDetail)
			}
			attempted += 1
			if attempted == postInfo.count {
				completion(true, modifiedPostInfo)
			}
		}, withCancel: { (error) in })
	}
	
}

func sentReferralAmountToInfluencer(referralID: String,completion: @escaping(User?)->Void) {
    let usersRef = Database.database().reference().child("users")
    let query = usersRef.queryOrdered(byChild: "referralcode").queryEqual(toValue: referralID)
    query.observeSingleEvent(of: .value) { (snapshot) in
        if let dictionary = snapshot.value as? [String: AnyObject] {
            let userInstance = User(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
            completion(userInstance)
        }
        
    }
    
}

func checkIfInfluencerReferralExist(referralID: String,completion: @escaping(Bool)->Void) {
    
    let usersRef = Database.database().reference().child("users")
    
    let query = usersRef.queryOrdered(byChild: "referralcode").queryEqual(toValue: referralID)
    
    query.observeSingleEvent(of: .value) { (snapshot) in
        
//        if let dictionary = snapshot.value as? [String: AnyObject] {
//
//            let userInstance = User(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
//            completion(userInstance)
//
//
//        }
        
        if snapshot.exists(){
            
            completion(true)
            
        }else{
            completion(false)
        }
        
    }
    
}

func checkIfBusinessReferralExist(referralID: String,completion: @escaping(Bool)->Void) {
    
    let usersRef = Database.database().reference().child("CompanyUser")
    
    let query = usersRef.queryOrdered(byChild: "businessReferral").queryEqual(toValue: referralID)
    
    query.observeSingleEvent(of: .value) { (snapshot) in
        
//        if let dictionary = snapshot.value as? [String: AnyObject] {
//
//            let userInstance = CompanyUser(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
//            completion(userInstance)
//
//
//        }
        
        if snapshot.exists(){
           completion(true)
        }else{
           completion(false)
        }
        
    }
    
}

func getInfluencerReferral(referralID: String,completion: @escaping(Bool,User?)->Void) {
    
    let usersRef = Database.database().reference().child("users")
    
    let query = usersRef.queryOrdered(byChild: "referralcode").queryEqual(toValue: referralID)
    
    query.observeSingleEvent(of: .value) { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {

            let userInstance = User(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
            completion(true, userInstance)

        }else{
            completion(false, nil)
        }
        
    }
    
}

func getBusinessReferral(referralID: String,completion: @escaping(Bool, CompanyUser?)->Void) {
    
    let usersRef = Database.database().reference().child("CompanyUser")
    
    let query = usersRef.queryOrdered(byChild: "businessReferral").queryEqual(toValue: referralID)
    
    query.observeSingleEvent(of: .value) { (snapshot) in
        
        if let dictionary = snapshot.value as? [String: AnyObject] {

            let userInstance = CompanyUser(dictionary: dictionary[dictionary.keys.first!] as! [String: AnyObject])
            completion(true, userInstance)

        }else{
            completion(false, nil)
        }
        
    }
    
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        return dateFormatter.string(from: self)
    }
}
