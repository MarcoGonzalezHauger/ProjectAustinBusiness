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

func GetForeColor() -> UIColor {
	if #available(iOS 13.0, *) {
		return .label
	} else {
		return .black
	}
}

func GetBackColor() -> UIColor {
	if #available(iOS 13.0, *) {
		return .systemBackground
	} else {
		return .white
	}
}

let impact = UIImpactFeedbackGenerator()
func UseTapticEngine() {
	impact.impactOccurred()
}

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

func CompressNumber(number: Double) -> String {
	switch number {
	case 0...9999:
		return NumberToStringWithCommas(number: number)
	case 10000...99999:
		return "\(floor(number/100) / 10)K"
	case 100000...999999:
		return "\(floor(number/1000))K"
	case 1000000...9999999:
		return "\(floor(number/100000) / 10)M"
	case 10000000...999999999:
		return "\(floor(number/1000000))M"
	default:
		return String(number)
	}
}

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
    case .offer:
        necessaryItems = ["status", "money", "companyDetails", "posts", "offer_ID", "offerdate", "ownerUserID", "title", "isAccepted", "expiredate", "cashPower"]
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

enum structType {
    case offer
    case businessDetails
}
