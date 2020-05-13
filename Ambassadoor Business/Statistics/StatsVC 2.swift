//
//  StatsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage

class StatsVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var pieView: ShadowView!
    @IBOutlet weak var statisticDataView: UIView!
    
    var paid: Int = 0
    var allVerified: Int = 0
    var accepted: Int = 0
    var available: Int = 0
    var rejected: Int = 0
    
    @IBOutlet weak var paidText: UILabel!
    @IBOutlet weak var allVerifiedText: UILabel!
    @IBOutlet weak var acceptedText: UILabel!
    @IBOutlet weak var availableText: UILabel!
    @IBOutlet weak var rejectedText: UILabel!
    @IBOutlet weak var noneInfluencers: UIView!
    @IBOutlet weak var totalPosts: UILabel!
    @IBOutlet weak var userTable: UITableView!
    
    var succeedOffers = [Statistics]()
    var instagramDataUserArray = [String]()
    var instagramOfferArray = [String: instagramOfferDetails]()
    
    let stats: StatisticsStruct? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
		view.bringSubviewToFront(statisticDataView)
		self.statisticDataView.isHidden = false
        
        if Singleton.sharedInstance.getCompanyUser().isCompanyRegistered == false {
            self.performSegue(withIdentifier: "toCompanyRegister", sender: self)
        }else{
            
            let user = Singleton.sharedInstance.getCompanyUser().companyID!
            
            getCompany(companyID: user) { (company, error) in
                
                Singleton.sharedInstance.setCompanyDetails(company: company!)
            }
            
        }
        
        self.getStatisticsTimerData()

	}
    
	override func viewDidAppear(_ animated: Bool) {
		if showTutorialVideoOnShow {
			playTutorialVideo(sender: self)
			showTutorialVideoOnShow = false
		}
	}
	
    @objc func getStatisticsTimerData(){
        
        //print("GetSTatisticsTimerData() ran.")
        
        
        getStatisticsData { (statistics, status, error) in
            
            if error == nil {
                self.succeedOffers.removeAll()
                self.totalPosts.text = "Total Number Of Posts:  \(statistics?.count ?? 0)"
                self.accepted = 0
                self.rejected = 0
                self.paid = 0
                self.allVerified = 0
                self.available = 0
                
                if statistics!.count == 0 {
                    self.statisticDataView.isHidden = false
                }else{
                    self.statisticDataView.isHidden = true
                }
                
                for statisticsData in statistics! {
                    
                    if let offer = statisticsData.offer {
						
						let status = offer["status"] as! String
                        
                        if status == "accepted" {
                            
                            self.accepted = self.accepted + 1
                            self.succeedOffers.append(statisticsData)
                            
                        }else if status == "rejected" {
                            
                            self.rejected = self.rejected + 1
                            
                        }else if status == "paid" {
                            
                            self.paid = self.paid + 1
                            
                        }else if status == "allverified" || status == "verified" {
                            
                            self.allVerified = self.allVerified + 1
                            
                        }else if status == "available" {
                            
                            self.available = self.available + 1
						} else {
							self.rejected = self.rejected + 1
						}
                        
                    }else{
                        self.rejected = self.rejected + 1
                        
                    }
                    
                }
                
                let acceptData = 		CGFloat(self.accepted)
                let rejectData = 		CGFloat(self.rejected)
                let paidData = 			CGFloat(self.paid)
                let allverifiedData = 	CGFloat(self.allVerified)
                let availableData = 	CGFloat(self.available)
                
				self.acceptedText.text = 	String(self.accepted) + " Post" + (self.accepted != 1 ? "s" : "")
                self.rejectedText.text = 	String(self.rejected) + " Post" + (self.rejected != 1 ? "s" : "")
                self.paidText.text = 		String(self.paid) + " Post" + (self.paid != 1 ? "s" : "")
                self.allVerifiedText.text = String(self.allVerified) + " Post" + (self.allVerified != 1 ? "s" : "")
                self.availableText.text = 	String(self.available) + " Post" + (self.available != 1 ? "s" : "")
                
                let pieChartView = StaticsPie()
                pieChartView.frame = CGRect(x: 0, y: 0, width: self.pieView.frame.size.width, height: self.pieView.frame.size.height)
                pieChartView.segments = [
                    OfferStatusSegment(color: .red, value: CGFloat(rejectData)),
                    OfferStatusSegment(color: .yellow, value: CGFloat(paidData)),
                    OfferStatusSegment(color: UIColor.init(red: 0.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0), value: CGFloat(acceptData)),
                    OfferStatusSegment(color: .green, value: CGFloat(allverifiedData)),
                    OfferStatusSegment(color: .gray, value: CGFloat(availableData))
                ]
                self.pieView.addSubview(pieChartView)
                
                getInstagramPosts(statisticsData: self.succeedOffers) { (InstagramData, status, error) in
                    
                    if error == nil {
                        
                        if InstagramData?.count != 0 {
                            self.noneInfluencers.isHidden = true
                            self.instagramOfferArray.removeAll()
                            self.instagramOfferArray = InstagramData!
                            self.instagramDataUserArray.removeAll()
                            self.instagramDataUserArray.append(contentsOf: InstagramData!.keys)
                            self.userTable.reloadData()
                            
                        }else{
                            self.noneInfluencers.isHidden = false
                        }
                        
                    }
                    
                }
                
            }else{
                
                self.statisticDataView.isHidden = false
                
            }
            
        }
		
		if !timercreated {
			Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.getStatisticsTimerData), userInfo: nil, repeats: true)
			timercreated = true
		}
        
        
    }
	
	var timercreated = false
    
    
    //MARK: UITableview Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instagramDataUserArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return nil
        
        let cellIdentifier = "instagramuser"
        let cell = userTable.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InstagramUserTVC
        
        let instaUser =  self.instagramOfferArray[instagramDataUserArray[indexPath.row]]
        cell.likesCount.text = String(instaUser!.likesCount)
        cell.userName.text = (instaUser?.userInfo!["full_name"] as! String)
        cell.userImage.sd_setImage(with: URL.init(string: (instaUser?.userInfo!["profile_picture"] as! String)), placeholderImage: UIImage(named: "defaultProduct"))
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let instaUser =  self.instagramOfferArray[instagramDataUserArray[indexPath.row]]
        let user = (instaUser?.userInfo!["username"] as! String)
        let instaURL = URL(string: "instagram://user?username=\(user)")!
        debugPrint(instaURL)
        let sharedApps = UIApplication.shared
        
        if sharedApps.canOpenURL(instaURL) {
            sharedApps.open(instaURL)
        } else {
            sharedApps.open(URL(string: "https://instagram.com/\(user)")!)
        }
        
    }
    
    /*
     let instaURL = URL(string: "instagram://user?username=\(user)")!
     debugPrint(instaURL)
     let sharedApps = UIApplication.shared
     
     if sharedApps.canOpenURL(instaURL) {
         sharedApps.open(instaURL)
     } else {
         sharedApps.open(URL(string: "https://instagram.com/\(user)")!)
     }
     */
    
//    func sentOutReferralCommision(referral: String?) {
//
//        if referral != "" && referral != nil {
//
//          getUserByReferralCode(referralcode: referral!) { (user) in
//
//        }
//
//        }
//
//    }
	
//	override func awakeFromNib() {
//		if Auth.auth().currentUser == nil {
//			debugPrint("User not signed in!")
//			self.performSegue(withIdentifier: "toSignUp", sender: self)
//		}
//	}
}