//
//  StatsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive property of Marco Gonzalez Hauger.
//

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage

class OfferStatistic: NSObject {
	var offer: Offer
	var accepted: [User] = []
	var posted: [User] = []
	func getInformation() {
		
	}
	init(offer: Offer) {
		self.offer = offer
	}
}

class StatsVC: BaseVC {
	
	var distributedOffers: [OfferStatistic] = []
	
	func getStatistics() {
		getAllDistributedOffers { (status, results) in
			if status {
				if let results = results {
					if self.distributedOffers.count == results.count {
						var rslts: [OfferStatistic] = []
						for i in results {	rslts.append(OfferStatistic.init(offer: i))
						}
						self.distributedOffers = rslts
						self.reloadShelf()
					} else {
						getStatsForAllOffers()
					}
				}
			}
		}
	}
	
	func getStatsForAllOffers() {
		for doffer in distributedOffers {
			
		}
	}
	
	func reloadShelf() {
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let user = Singleton.sharedInstance.getCompanyUser().userID!
        
        if Singleton.sharedInstance.getCompanyUser().isCompanyRegistered == false {
            self.performSegue(withIdentifier: "toCompanyRegister", sender: self)
        } else {
            
            let user = Singleton.sharedInstance.getCompanyUser().companyID!
            
            getCompany(companyID: user) { (company, error) in
                
                Singleton.sharedInstance.setCompanyDetails(company: company!)
				YourCompany = company
				self.setCompanyTabBarItem()
            }
            
        }
        
        
        self.getStatisticsTimerData()

	}
    
	override func viewDidAppear(_ animated: Bool) {
//		if showTutorialVideoOnShow {
//			playTutorialVideo(sender: self)
//			showTutorialVideoOnShow = false
//		}
	}
	
	func setCompanyTabBarItem() {
		guard let logo = YourCompany.logo else {return}
		downloadImage(logo) { (image) in
			let size = CGSize.init(width: 32, height: 32)
			
			let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
			
			UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
			image?.draw(in: rect)
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			if var image = newImage {
				print(image.scale)
				image = makeImageCircular(image: image)
				print(image.scale)
				self.tabBarController?.viewControllers?.first?.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
			}
		}
	}
	
	@objc func getStatisticsTimerData() {
		
		getStatistics()
		
		if !timercreated {
			Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.getStatisticsTimerData), userInfo: nil, repeats: true)
			timercreated = true
		}
        
        
    }
	
	var timercreated = false
}
