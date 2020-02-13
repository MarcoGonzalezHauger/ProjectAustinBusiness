//
//  BusinessLabel.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

@IBDesignable
class BusinessLabel: UILabel {
	
	@IBInspectable var showLogo: Bool = false
	
	override func awakeFromNib() {
		//let ambassaC: UIColor = UIColor(red: 0.04, green: 0.68, blue: 0.91, alpha: 1.00)//UIColor(red: 0.40, green: 0.65, blue: 1.00, alpha: 1.00)
		//let doorC: UIColor = UIColor(red: 0.15, green: 0.50, blue: 0.94, alpha: 1.00) //UIColor(red: 0.07, green: 0.52, blue: 0.96, alpha: 1.00)
		let BusinessC: UIColor = UIColor(red: 0.27, green: 0.52, blue: 0.89, alpha: 1.00)
		let fontSize: CGFloat = 21
		let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : GetForeColor()]
		let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : GetForeColor()]
		let attrs3 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: fontSize), NSAttributedString.Key.foregroundColor : BusinessC]
		let ambassa = NSMutableAttributedString(string:"Ambassa", attributes:attrs1 as [NSAttributedString.Key : Any])
		let door = NSMutableAttributedString(string:"door", attributes:attrs2 as [NSAttributedString.Key : Any])
		let business = NSMutableAttributedString(string:" Business", attributes:attrs3 as [NSAttributedString.Key : Any])
		ambassa.append(door)
		ambassa.append(business)
		self.attributedText = ambassa
		if showLogo {
			
			let logopic: UIImageView = UIImageView.init(frame: CGRect.init(x: self.frame.origin.x - 52.5, y: self.frame.origin.y - 6, width: 40, height: 40))
			
			logopic.image = UIImage.init(named: "BlackLogo")
			logopic.contentMode = .scaleAspectFit
			
			self.superview?.addSubview(logopic)
		}
	}

}
