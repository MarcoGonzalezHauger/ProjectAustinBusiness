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

class OfferStatisticCell: UITableViewCell {
	@IBOutlet weak var offername: UILabel!
	@IBOutlet weak var acceptedLabel: UILabel!
	@IBOutlet weak var postedLabel: UILabel!
}

class OfferStatistic: NSObject {
	var offer: TemplateOffer
	var accepted: [User] = []
	var posted: [PostInfo] = []
	var acceptedCount: Int {
		get {
			return (offer.accepted ?? []).count
		}
	}
	func getInformation() {
		getInfluencersWhoAcceptedOffer(offer: offer) { (status, results) in
			if status {
				if let results = results {
					self.accepted = results
				}
			}
		}
		getInfluencersWhoPostedForOffer(offer: offer) { (status, results) in
			if status {
				if let results = results {
					self.posted = results
					getPostUserDetails(postInfo: self.posted) { (status, results) in
						if status {
							if let results = results {
								for r in results {
									let i = self.posted.firstIndex { (postinfo) -> Bool in
										return postinfo.userId == r.userId && postinfo.associatedPost?.post_ID == r.associatedPost?.post_ID
									}
									if let i = i {
										self.posted[i].userWhoPosted = r.userWhoPosted
									}
								}
							}
						}
					}
					getInstagramPostByOffer(postInfo: self.posted) { (status, results) in
						if status {
							if let results = results {
								for r in results {
									let i = self.posted.firstIndex { (postinfo) -> Bool in
										return postinfo.userId == r.userId && postinfo.associatedPost?.post_ID == r.associatedPost?.post_ID
									}
									if let i = i {
										self.posted[i].caption = r.caption
										self.posted[i].imageUrl = r.imageUrl
									}
								}
							}
						}
					}
				}
			}
		}
	}
	init(offer: TemplateOffer) {
		self.offer = offer
	}
}

class StatsVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return distributedOffers.count
	}
	
	var statToPass: OfferStatistic!
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		statToPass = distributedOffers[indexPath.row]
		performSegue(withIdentifier: "toStatInfo", sender: self)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = statShelf.dequeueReusableCell(withIdentifier: "offerStatCell") as! OfferStatisticCell
		let info = distributedOffers[indexPath.row]
		cell.offername.text = info.offer.title
		cell.acceptedLabel.text = "\(info.acceptedCount) influencer\(info.acceptedCount == 1 ? "" : "s") have accepted so far."
		//cell.postedLabel.text = "\(info.posted.count) influencer\(info.posted.count == 1 ? "" : "s") have posted so far."
        cell.postedLabel.text = "\(info.posted.count) post\(info.posted.count == 1 ? "" : "s") have posted so far."
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 170.0
	}
	
	@IBOutlet weak var statShelf: UITableView!
	@IBOutlet weak var noStatsLabel: UILabel!
	
	var firstGrab = true
	var distributedOffers: [OfferStatistic] = []
	
	func getStatistics() {
		getAllDistributedOffers { (status, results) in
			if status {
				if let results = results {
					if results.count == 0 {
						self.NoStatsLabel(true)
					} else {
						self.NoStatsLabel(false)
						if self.distributedOffers.count == results.count || self.firstGrab {
							var rslts: [OfferStatistic] = []
							for i in results {
								rslts.append(OfferStatistic.init(offer: i))
							}
							self.distributedOffers = rslts
							self.reloadShelf()
							self.firstGrab = false
						}
						self.getStatsForAllOffers()
					}
				}
			}
		}
	}
	
	func NoStatsLabel(_ setVisible: Bool) {
		noStatsLabel.isHidden = !setVisible
	}
	
	func getStatsForAllOffers() {
		for doffer in distributedOffers {
			doffer.getInformation()
		}
	}
	
	@objc func reloadShelf() {
		statShelf.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getStatisticsTimerData), name: Notification.Name.init(rawValue: "reloadstatics"), object: nil)
		statShelf.delegate = self
		statShelf.dataSource = self
		
        //let user = Singleton.sharedInstance.getCompanyUser().userID!
        
        if Singleton.sharedInstance.getCompanyUser().isCompanyRegistered == true {
            
            //self.performSegue(withIdentifier: "toCompanyRegister", sender: self)
            //let user = Singleton.sharedInstance.getCompanyUser().companyID!
            
            //getCompany(companyID: user) { (company, error) in
                
                //Singleton.sharedInstance.setCompanyDetails(company: company!)
                //YourCompany = company
                self.setCompanyTabBarItem()
            
            if global.distributedOffers.count != 0 {
                    
                    self.NoStatsLabel(true)
                    self.NoStatsLabel(false)
                        self.distributedOffers = global.distributedOffers
                        self.reloadShelf()
                        self.firstGrab = false
                    
                    self.getStatsForAllOffers()
                

                
            }else{
                
                self.getStatisticsTimerData()
                
            }
            //}
        } else {

            self.performSegue(withIdentifier: "toCompanyRegister", sender: self)

        }
		
		timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.getStatisticsTimerData), userInfo: nil, repeats: true)
		timer?.fire()
		
		reloadTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.reloadShelf), userInfo: nil, repeats: true)
		reloadTimer?.fire()

	}
	
	var timer: Timer?
	var reloadTimer: Timer?
    
	override func viewDidAppear(_ animated: Bool) {
		if !imageWasSet {
			setCompanyTabBarItem()
		}
	}
	
	var imageWasSet = false
	
	func setCompanyTabBarItem() {
		guard let YourCompany = YourCompany else {return}
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
				self.imageWasSet = true
			}
		}
	}
	
	@objc func getStatisticsTimerData() {
		getStatistics()
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? ViewOfferStatisticVC {
			dest.stat = statToPass
		}
	}
}
