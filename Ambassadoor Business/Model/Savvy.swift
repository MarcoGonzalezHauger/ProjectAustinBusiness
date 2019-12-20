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

//func SubCategoryToString(subcategory: Categories) -> String {
//	switch subcategory {
//	case .Hiker: return "Hiker"
//	case .WinterSports: return "Winter Sports"
//	case .Baseball: return "Baseball"
//	case .Basketball: return "Basketball"
//	case .Golf: return "Golf"
//	case .Tennis: return "Tennis"
//	case .Soccer: return "Soccer"
//	case .Football: return "Football"
//	case .Boxing: return "Boxing"
//	case .MMA: return "MMA"
//	case .Swimming: return "Swimming"
//	case .TableTennis: return "Table Tennis"
//	case .Gymnastics: return "Gymnastics"
//	case .Dancer: return "Dancer"
//	case .Rugby: return "Rugby"
//	case .Bowling: return "Bowling"
//	case .Frisbee: return "Frisbee"
//	case .Cricket: return "Cricket"
//	case .SpeedBiking: return "Speed Biking"
//	case .MountainBiking: return "Mountain Biking"
//	case .WaterSkiing: return "Water Skiing"
//	case .Running: return "Running"
//	case .PowerLifting: return "Power Lifting"
//	case .BodyBuilding: return "Body Building"
//	case .Wrestling: return "Wrestling"
//	case .StrongMan: return "Strong Man"
//	case .NASCAR: return "NASCAR"
//	case .RalleyRacing: return "Ralley Racing"
//	case .Parkour: return "Parkour"
//	case .Model: return "Model"
//	case .Makeup: return "Makeup"
//	case .Actor: return "Actor"
//	case .RunwayModel: return "Runway Model"
//	case .Designer: return "Designer"
//	case .Brand: return "Brand"
//	case .Stylist: return "Stylist"
//	case .HairStylist: return "Hair Stylist"
//	case .FasionArtist: return "Fasion Artist"
//	case .Painter: return "Painter"
//	case .Sketcher: return "Sketcher"
//	case .Musician: return "Musician"
//	case .Band: return "Band"
//	case .SingerSongWriter: return "Singer/Songwriter"
//    case .Other: return "Other"
//	}
//}

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

//MARK: Shake Animation for views

func MakeShake(viewToShake thisView: UIView, coefficient: Float = 1) {
	let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
	animation.timingFunction = CAMediaTimingFunction(name: .linear)
	animation.duration = 0.6
	animation.values = [-20.0 * coefficient, 20.0 * coefficient, -20.0 * coefficient, 20.0 * coefficient, -10.0 * coefficient, 10.0 * coefficient, -5.0 * coefficient, 5.0 * coefficient, 0 ]
	thisView.layer.add(animation, forKey: "shake")
}

func makeImageCircular(image: UIImage) -> UIImage {
	let ImageLayer = CALayer()
	
	ImageLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
	ImageLayer.contents = image.cgImage
	ImageLayer.masksToBounds = true
	ImageLayer.cornerRadius = image.size.width/2
	
	UIGraphicsBeginImageContext(image.size)
	ImageLayer.render(in: UIGraphicsGetCurrentContext()!)
	let NewImage = UIGraphicsGetImageFromCurrentImageContext()
	UIGraphicsEndImageContext()
	
	return NewImage!;
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
