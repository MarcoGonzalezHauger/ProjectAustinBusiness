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

class StatsVC: BaseVC,UITableViewDataSource,UITableViewDelegate {
    
    
    
	let stats: StatisticsStruct? = nil
	
    @IBOutlet weak var pieView: ShadowView!
    @IBOutlet weak var statisticDataView: UIView!
    
    var paid: Int = 0
    var allVerified: Int = 0
    var accepted: Int = 0
    var available: Int = 0
    var rejected: Int = 0
    
	@IBOutlet var boxes: [UILabel]!
	
	@IBOutlet weak var noWorkLabel: UILabel!
	@IBOutlet weak var paidText: UILabel!
    @IBOutlet weak var allVerifiedText: UILabel!
    @IBOutlet weak var acceptedText: UILabel!
    @IBOutlet weak var availableText: UILabel!
    @IBOutlet weak var rejectedText: UILabel!
    
    @IBOutlet weak var totalPosts: UILabel!
    
    @IBOutlet weak var userTable: UITableView!
    
    var succeedOffers = [Statistics]()
    var instagramDataUserArray = [String]()
    var instagramOfferArray = [String: instagramOfferDetails]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
		view.bringSubviewToFront(noWorkLabel)
		self.statisticDataView.isHidden = false
		//Temporary measure
        
        //self.sentOutReferralCommision(referral: "NJ200919HWE6")
        
		for l in boxes {
			l.layer.cornerRadius = 5
			l.clipsToBounds = true
		}
		
//        YourCompany = Company.init(dictionary: ["name": "KRILL GROUP", "logo": "", "mission": "Turn a profit.", "website": "https://www.google.com/", "account_ID": "0", "instagram_name": "marcogonzalezhauger", "description": "No description to see here!", "accountBalance": 1000.0])
//		accountBalance = 610.78
//		transactionHistory = [Transaction(description: "Despotied $620.77 into Ambassadoor", details: "Order processed.", time: Date.init(timeIntervalSinceNow: -10000), amount: 620.77),Transaction(description: "You paid $9.99", details: "Processed.", time: Date.init(timeIntervalSinceNow: 0), amount: -9.99)]
        if Singleton.sharedInstance.getCompanyUser().isCompanyRegistered == false {
            self.performSegue(withIdentifier: "toCompanyRegister", sender: self)
        }else{
            
            let user = Singleton.sharedInstance.getCompanyUser().companyID!
            
            getCompany(companyID: user) { (company, error) in
                
                Singleton.sharedInstance.setCompanyDetails(company: company!)
            }
            
            getStatisticsData { (statistics, status, error) in
                
                if error == nil {
                    self.succeedOffers.removeAll()
                    self.totalPosts.text = "Total Number Of Posts:  \(statistics?.count ?? 0)"
                    
                    if statistics!.count == 0 {
                        self.statisticDataView.isHidden = false
						self.noWorkLabel.text = "No Statistics Yet"
                    } else {
                        self.statisticDataView.isHidden = true
                    }
                    
                    for statisticsData in statistics! {
                        
                        if statisticsData.offer != nil {
                            
                            if statisticsData.offer!["status"] as! String == "accepted" {
                                
                                self.accepted = self.accepted + 1
                                self.succeedOffers.append(statisticsData)
                                
                            }else if statisticsData.offer!["status"] as! String == "rejected" {
                                
                                self.rejected = self.rejected + 1
                                
                            }else if statisticsData.offer!["status"] as! String == "paid" {
                                
                                self.paid = self.paid + 1
                                
                            }else if statisticsData.offer!["status"] as! String == "allverified" {
                                
                                self.allVerified = self.allVerified + 1
                                
                            }else if statisticsData.offer!["status"] as! String == "available" {
                                
                                self.available = self.available + 1
                            }
                            
                        }else{
                            
                            self.rejected = self.rejected + 1
                            
                        }
                        
                    }
                    
                    let acceptData = ((CGFloat(self.accepted)/CGFloat(statistics!.count) * 100)/100) * 154.0
                    let rejectData = ((CGFloat(self.rejected)/CGFloat(statistics!.count) * 100)/100) * 154.0
                    let paidData = ((CGFloat(self.paid)/CGFloat(statistics!.count) * 100)/100) * 154.0
                    let allverifiedData = ((CGFloat(self.allVerified)/CGFloat(statistics!.count) * 100)/100) * 154.0
                    let availableData = ((CGFloat(self.available)/CGFloat(statistics!.count) * 100)/100) * 154.0
                    
                    self.acceptedText.text = String(self.accepted) + " Posts"
                    self.rejectedText.text = String(self.rejected) + " Posts"
                    self.paidText.text = String(self.paid) + " Posts"
                    self.allVerifiedText.text = String(self.allVerified) + " Posts"
                    self.availableText.text = String(self.available) + " Posts"
                    
                    let pieChartView = StaticsPie()
                    pieChartView.frame = CGRect(x: 0, y: 0, width: self.pieView.frame.size.width, height: self.pieView.frame.size.height)
                    pieChartView.segments = [
						OfferStatusSegment(color: UIColor(named: "expiredColor")!, value: CGFloat(rejectData)),
                        OfferStatusSegment(color: .yellow, value: CGFloat(paidData)),
                        OfferStatusSegment(color: UIColor.init(red: 0.0, green: 128.0/255.0, blue: 0.0, alpha: 1.0), value: CGFloat(acceptData)),
                        OfferStatusSegment(color: .green, value: CGFloat(allverifiedData)),
                        OfferStatusSegment(color: .gray, value: CGFloat(availableData))
                    ]
                    self.pieView.addSubview(pieChartView)
                    
                    getInstagramPosts(statisticsData: self.succeedOffers) { (InstagramData, status, error) in
                        
                        if error == nil {
                            
                            if InstagramData?.count != 0 {
                                self.instagramOfferArray.removeAll()
                                self.instagramOfferArray = InstagramData!
                                self.instagramDataUserArray.append(contentsOf: InstagramData!.keys)
                                self.userTable.reloadData()
                                
                            }
                            
                        }
                        
                    }
                    
                }else{
                    
                    self.statisticDataView.isHidden = false
                    
                }
                
            }
            
        }
            
		
		
	}
    
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
