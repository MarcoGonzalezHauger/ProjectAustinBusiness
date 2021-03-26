//
//  Savvy.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 11/22/18.
//  Copyright © 2018 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Firebase
import CoreData

func NumberToPrice(Value: Double, enforceCents isBig: Bool = false) -> String {
	if floor(Value) == Value && isBig == false {
		return "$" + String(Int(Value))
	}
	let formatter = NumberFormatter()
	formatter.locale = Locale(identifier: "en_US")
	formatter.numberStyle = .currency
	if let formattedAmount = formatter.string(from: Value as NSNumber) {
		return formattedAmount
	}
	return ""
}

//func GetForeColor() -> UIColor {
//	if #available(iOS 13.0, *) {
//		return .label
//	} else {
//		return .black
//	}
//}

//func GetBackColor() -> UIColor {
//	if #available(iOS 13.0, *) {
//		return .systemBackground
//	} else {
//		return .white
//	}
//}

func saveCoreDataUpdate(object: NSManagedObject) {
    
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    print(paths[0])
    do {
        try object.managedObjectContext?.save()
    } catch {
        print("Failed saving")
    }
    
}


//let impact = UIImpactFeedbackGenerator()
//func UseTapticEngine() {
//	impact.impactOccurred()
//}

func GoogleSearch(query: String) {
	let newquery = query.replacingOccurrences(of: " ", with: "+")
	if let url = URL(string: "https://www.google.com/search?q=\(newquery)") {
		UIApplication.shared.open(url, options: [:])
	}
}

func DateToAgo(date: Date) -> String {
	let i : Double = date.timeIntervalSinceNow * -1
	switch true {
		
	case i < 60 :
		return "now"
	case i < 3600:
		return "\(Int(floor(i/60)))m ago"
	case i < 21600:
		return "\(Int(floor(i/3600)))h ago"
	case i < 86400:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "h:mm a"
		formatter.amSymbol = "AM"
		formatter.pmSymbol = "PM"
		return formatter.string(from: date)
	default:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "MM/dd/YYYY"
		return formatter.string(from: date)
	}
}

func YouShallNotPass(SaveButtonView viewToReject: UIView, returnColor rcolor: UIColor = .systemBlue) {
	
	UseTapticEngine()
	
	MakeShake(viewToShake: viewToReject)
	
	viewToReject.backgroundColor = .systemRed
	DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
		UIView.animate(withDuration: 0.8) {
			viewToReject.backgroundColor = rcolor
		}
	})
	
}

func DateToCountdown(date: Date) -> String? {
	let i : Double = date.timeIntervalSinceNow
	let pluralSeconds: Bool = Int(i) % 60 != 1
	let pluralMinutes: Bool = Int(floor(i/60)) % 60 != 1
	let pluralHours: Bool = Int(floor(i/3600)) % 24 != 1
	let pluralDays: Bool = Int(floor(i/86400)) % 365 != 1
	switch true {
	case Int(i) <= 0:
		return nil
	case i < 60 :
		return "in \(Int(i)) second\(pluralSeconds ? "s" : "")"
	case i < 3600:
		return "in \(Int(floor(i/60))) minute\(pluralMinutes ? "s" : ""), \(Int(i) % 60) second\(pluralSeconds ? "s" : "")"
	case i < 86400:
		return "in \(Int(floor(i/3600))) hour\(pluralHours ? "s" : ""), \(Int(floor(Double((Int(i) % 3600) / 60)))) minute\(pluralMinutes ? "s" : "")"
	case i < 604800:
		return "in \(Int(floor(i/86400))) day\(pluralDays ? "s" : ""), \(Int(floor(Double((Int(i) % 86400) / 3600)))) hour\(pluralHours ? "s" : "")"
	default:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "MM/dd/YYYY"
		return "on " + formatter.string(from: date)
	}
}

func DateToLetterCountdown(date: Date) -> String? {
	let i : Double = date.timeIntervalSinceNow
	switch true {
	case Int(i) <= 0:
		return nil
	case i < 60 :
		return "\(Int(i))s"
	case i < 3600:
		return "\(Int(floor(i/60)))m \(Int(i) % 60)s"
	case i < 86400:
		return "\(Int(floor(i/3600)))h \(Int(floor(Double((Int(i) % 3600) / 60))))m \(Int(i) % 60)s"
	case i < 604800:
		return "\(Int(floor(i/86400)))d \(Int(floor(Double((Int(i) % 86400) / 3600))))h \(Int(floor(Double((Int(i) % 3600) / 60))))m \(Int(i) % 60)s"
	default:
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US")
		formatter.dateFormat = "MM/dd/YYYY"
		return formatter.string(from: date)
	}
}

func NumberToStringWithCommas(number: Double) -> String {
	let numformat = NumberFormatter()
	numformat.numberStyle = NumberFormatter.Style.decimal
	return numformat.string(from: NSNumber(value:number)) ?? String(number)
}

func playTutorialVideo(sender: UIViewController) {
	guard let path = Bundle.main.path(forResource: "tutorial", ofType:"mp4") else {
		print("Ambasadoor Tutorial Video not found.")
		return
	}
	let player = AVPlayer(url: URL(fileURLWithPath: path))
	let playerController = AVPlayerViewController()
	playerController.player = player
	sender.present(playerController, animated: true) {
		player.play()
	}
}

func GetTierFromFollowerCount(FollowerCount: Double) -> Int? {
	
	//Tier is grouping people of similar follower count to encourage competition between users.
	
	switch FollowerCount {
	case 100...199: return 1
	case 200...349: return 2
	case 350...499: return 3
	case 500...749: return 4
	case 750...999: return 5
	case 1000...1249: return 6
	case 1250...1499: return 7
	case 1500...1999: return 8
	case 2000...2999: return 9
	case 3000...3999: return 10
	case 4000...4999: return 11
	case 5000...7499: return 12
	case 7500...9999: return 13
	case 10000...14999: return 14
	case 15000...24999: return 15
	case 25000...49999: return 16
	case 50000...74999: return 17
	case 75000...99999: return 18
	case 100000...149999: return 19
	case 150000...199999: return 20
	case 200000...299999: return 21
	case 300000...499999: return 22
	case 500000...749999: return 23
	case 750000...999999: return 24
	case 1000000...1499999: return 25
	case 1500000...1999999: return 26
	case 2000000...2999999: return 27
	case 3000000...3999999: return 28
	case 4000000...4999999: return 29
	case 5000000...: return 30
	default: return nil
	}
}

func isGoodUrl(url: String) -> Bool {
	if url == "" { return true }
	if let url = URL(string: url) {
		return UIApplication.shared.canOpenURL(url)
	} else {
		return false
	}
}

func GetOrganicSubscriptionFromTier(tier: Int?) -> Double {
	guard let tier = tier else { return 0 }
	if tier >= 6 {
		return 5
	}
	switch tier {
	case 1:
		return 1
	case 2:
		return 1.5
	case 3:
		return 2
	case 4:
		return 3
	case 5:
		return 4
	default:
		debugPrint("Exhaust activated on GetOragnicSubscriptionFromTier Function, this is never suppost to be activated.")
		return 5
	}
}

func MakeShake(viewToShake thisView: UIView, coefficient: Float = 1, negativeCoefficient: Float = 1, positiveCoefficient: Float = 1) {
	let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
	animation.timingFunction = CAMediaTimingFunction(name: .linear)
	animation.duration = 0.6
	animation.values = [-20.0 * coefficient * negativeCoefficient,
						20.0 * coefficient * positiveCoefficient,
						-20.0 * coefficient * negativeCoefficient,
						20.0 * coefficient * positiveCoefficient,
						-10.0 * coefficient * negativeCoefficient,
						10.0 * coefficient * positiveCoefficient,
						-5.0 * coefficient * negativeCoefficient,
						5.0 * coefficient * positiveCoefficient,
						0 ]
	thisView.layer.add(animation, forKey: "shake")
}

func makeImageCircular(image: UIImage) -> UIImage {
	let ImageLayer = CALayer()
	
	ImageLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
	ImageLayer.contents = image.cgImage
	ImageLayer.masksToBounds = true
	ImageLayer.cornerRadius = image.size.width/2
	ImageLayer.contentsScale = image.scale
	
	UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
	ImageLayer.render(in: UIGraphicsGetCurrentContext()!)
	let NewImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return NewImage!
}

func OfferFromID(id: String) -> Offer? {
	debugPrint("attempting to find offer with ID \(id)")
	return global.TemplateOffers.filter { (ThisOffer) -> Bool in
		return ThisOffer.offer_ID == id
	}[0]
}

//func CompressNumber(number: Double) -> String {
//	switch number {
//	case 0...9999:
//		return NumberToStringWithCommas(number: number)
//	case 10000...99999:
//		return "\(floor(number/100) / 10)K"
//	case 100000...999999:
//		return "\(floor(number/1000))K"
//	case 1000000...9999999:
//		return "\(floor(number/100000) / 10)M"
//	case 10000000...999999999:
//		return "\(floor(number/1000000))M"
//	default:
//		return String(number)
//	}
//}

func PostTypeToText(posttype: TypeofPost) -> String {
	switch posttype {
	case .SinglePost:
		return "Single Post"
	case .MultiPost:
		return "Multi Post"
	case .Story:
		return "Story Post"
	}
}

func DateToFirebase(date: Date) -> AnyObject {
	return NSDate().timeIntervalSince1970 as AnyObject
}

func FirebaseToDate(object: AnyObject?) -> Date {
	guard let object = object else { return Date() }
	let myTimeInterval = TimeInterval(exactly: object as! NSNumber)!
	let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
	return time as Date
}

func IncreasePayVariableValue(pay: String) -> IncreasePayVariable {
    switch pay {
    case "None":
         return IncreasePayVariable.None
    case "+5%":
        return IncreasePayVariable.Five
    case "+10%":
        return IncreasePayVariable.Ten
    case "+20%":
        return IncreasePayVariable.Twenty
    default:
        return IncreasePayVariable.None
    }
}

func randomString(length: Int) -> String {
    let letters = "ABCDEFGHIJKLMNPQRSTUVWXYZ123456789"
    
    let randomStringValue = (0..<length).map{ _ in letters.randomElement()!}.reduce("") { (result, current) -> String in
        return result + String(current)
    }
    
    let finalString = randomStringValue
    
    return finalString
}

//returns a list of ERRORS

func isDeseralizable(dictionary: [String: AnyObject], type: structType) -> [String] {
    var necessaryItems: [String] = []
    var errors: [String] = []
    switch type {
        //"companyDetails"
    case .offer:
        necessaryItems = ["status", "money","posts", "offer_ID", "offerdate", "ownerUserID", "title", "isAccepted", "expiredate"]
    case .businessDetails:
        necessaryItems = ["name", "mission"]
    }
    for i in necessaryItems {
        if dictionary[i] == nil {
            errors.append("Dictionary[\(i)] returned NIL")
        }
    }
    return errors
}

func downloadBeforeLoad() {
    /*
    getAllDistributedOffers { (status, results) in
        if status {
            if let results = results {
                if results.count == 0 {
                } else {
                    
                var rslts: [OfferStatistic] = []
                for i in results {
                    rslts.append(OfferStatistic.init(offer: i))
                }
                global.distributedOffers = rslts
        
                }
            }
        }
    }
    */
    
    //Auth.auth().currentUser!.uid
    
    getAllTemplateOffers(userID: Auth.auth().currentUser!.uid) { (templateOffers, status) in
        
        if status == "success" && templateOffers.count != 0 {
            global.OfferDrafts.removeAll()
            global.OfferDrafts.append(contentsOf: templateOffers)
        }
        
    }
    //(Auth.auth().currentUser?.uid)!
    setDepositDetails(userID: (Auth.auth().currentUser?.uid)!)
    
}

func getGlobalAllInfluencers() {
    GetAllUsers { (users) in
        global.allInfluencers.removeAll()
        global.allInfluencers = users
    }
}

func setDepositDetails(userID: String) {
        getDepositDetails(companyUser: userID) { (deposit, status, error) in
        
        if status == "success" {
            
            transactionHistory.removeAll()
            global.accountBalance = deposit!.currentBalance!
            accountBalance = global.accountBalance
            //(Auth.auth().currentUser?.uid)!
            setHapticMenu(companyUserID: (Auth.auth().currentUser?.uid)!, amount: accountBalance)
            for value in deposit!.depositHistory! {
                
                if let valueDetails = value as? NSDictionary {
                    
                    var amount = 0.0
                    
                    if let amt = valueDetails["amount"] as? String {
                        amount = Double(amt)!
                    }else if let amt = valueDetails["amount"] as? Double{
                       amount = amt
                    }
                    
                    transactionHistory.append(Transaction(description: "", details: valueDetails["cardDetails"] as AnyObject, time: valueDetails["updatedAt"] as! String, amount: amount, type: valueDetails["type"] as! String, status: valueDetails["status"] as? String ?? "", userName: valueDetails["userName"] as? String ?? "", date: DateFormatManager.sharedInstance.getDateFromStringWithAutoMonthFormat(dateString: valueDetails["updatedAt"] as! String), id: valueDetails["id"] as? String ?? ""))
                }
            }
            
        }
        
    }
    
    //accountBalance = Double(arc4random() % 1000)
}

func filterApproximation(category: [String:[AnyObject]], users: [User], completion: @escaping(_ status: Bool,_ users: [User]?)->()) {
    
    var filteredUsers = [User]()
    
    
    var BusinessFilters = category
//    var filteredCategory = [String]() //all categories in the template offer.
//    
//    if category.keys.contains("categories") {
//        
//        let categoryValueArray = category["categories"] as! [String]
//        
//        filteredCategory.append(contentsOf: categoryValueArray)
//        
//        BusinessFilters.removeValue(forKey: "categories")
//        
//    }
    
    for userData in users {
        
        let BusinessFilterKeys = BusinessFilters.keys 
        
        var categoryMatch = !BusinessFilterKeys.contains("categories")
        var genderMatch = !BusinessFilterKeys.contains("gender")
        var locationMatch = !BusinessFilterKeys.contains("zipCode")
        
        //Gender filter
        
        if !genderMatch {
            let gender: [String] = BusinessFilters["gender"] as! [String]
            if let userGender = userData.gender {
                if gender.contains(userGender) {
                    genderMatch = true
                }
            }
        }
        
        //ZIP CODE
                        
        if !locationMatch && genderMatch {
            let zips: [String] = BusinessFilters["zipCode"] as! [String]
            if let userZip = userData.zipCode {
                if zips.contains(userZip) {
                    locationMatch = true
                }
            }
        }
        
        //CATEGORIES
        
        if !categoryMatch && locationMatch && genderMatch {
            let businessCats: [String] = BusinessFilters["categories"] as! [String]
            if let userCats = userData.categories {
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
        
        if categoryMatch && genderMatch && locationMatch {
            filteredUsers.append(userData)
        }
        
    }
    
    completion(true, filteredUsers)
    
}

enum structType {
    case offer
    case businessDetails
}

func instantiateViewController(storyboard: String, reference: String) -> AnyObject{
    
    let mainStoryBoard = UIStoryboard(name: storyboard, bundle: nil)
    let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: reference)
    return redViewController
}

func setHapticMenu(companyUserID: String, amount: Double? = nil) {
    
    var shortcutItems = UIApplication.shared.shortcutItems ?? []
	
	if amount == nil || shortcutItems.count == 0 {
        
        getDepositDetails(companyUser: companyUserID) { (deposit, status, error) in
            
            var amountDob: Double = 0.0
            
            
            if (error == nil){
                if status == "success" {
                    amountDob = deposit!.currentBalance!
                }
            }
            
			shortcutItems = [UIApplicationShortcutItem.init(type: "com.ambassadoor.offers", localizedTitle: "Offers", localizedSubtitle:nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.compose), userInfo: nil),
							 UIApplicationShortcutItem.init(type: "com.ambassadoor.account", localizedTitle: "Account", localizedSubtitle:nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.contact), userInfo: nil),
							 UIApplicationShortcutItem.init(type: "com.ambassadoor.money", localizedTitle: "Money", localizedSubtitle: "Balance: \(NumberToPrice(Value: amountDob, enforceCents: true))", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.home), userInfo: nil)]
            UIApplication.shared.shortcutItems = shortcutItems
            
        }
        
    }else{
        
        shortcutItems[2] = UIApplicationShortcutItem.init(type: "com.ambassadoor.money", localizedTitle: "Money", localizedSubtitle: "Balance: \(NumberToPrice(Value: amount!, enforceCents: true))", icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIcon.IconType.home), userInfo: nil)
        UIApplication.shared.shortcutItems = shortcutItems
    }
    
}

func GetZipsFromLocationFilter(locationFilter: String, completion: @escaping ([String]?) -> ()) {
    switch locationFilter.components(separatedBy: ":")[0] {
    case "nw":
        completion(nil)
    case "states":
        let data = locationFilter.components(separatedBy: ":")[1]
        var returnData: [String] = []
        var index = 0
        for stateName in data.components(separatedBy: ",") {
            GetZipCodesInState(stateShortName: stateName) { (zips1) in
                returnData.append(contentsOf: zips1)
                index += 1
                if index == data.components(separatedBy: ",").count {
                    completion(returnData)
                }
            }
        }
    case "radius":
        let data1 = locationFilter.components(separatedBy: ":")[1]
        var returnData: [String] = []
        var index = 0
        for data in data1.components(separatedBy: ",") {
            let zip = data.components(separatedBy: "-")[0]
            let radius = Int(data.components(separatedBy: "-")[1]) ?? 0
            GetAllZipCodesInRadius(zipCode: zip, radiusInMiles: radius) { (returns, zip, radius) in
                if let returns = returns {
                    returnData.append(contentsOf: returns.keys)
                }
                index += 1
                if index >= data1.components(separatedBy: ",").count {
                    completion(returnData)
                }
            }
        }
    default:
        completion(nil)
    }
}
var countries = ["United States", "USA"]
var towns = ["New York", "NY"]
var zipcodes = ["10001"]

