//
//  ViewOfferStatisticVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/19/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InfluencerStatCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionText: UILabel!
    @IBOutlet weak var shadow: ShadowView!
    
    var setPostInfo: PostInfo?{
        didSet{
            if let postInfo = setPostInfo{
                
                if let user = postInfo.userWhoPosted{
                    self.username.text = user.username
                }
                if let profileUrl = postInfo.userWhoPosted?.profilePicURL{
                    self.profilePic.sd_setImage(with: URL.init(string: profileUrl), placeholderImage: UIImage(named: "defaultProduct"))
                }else{
                    self.profilePic.image = UIImage(named: "defaultProduct")
                }
                
                if let followers = postInfo.userWhoPosted?.followerCount{
                   self.followersCount.text = String(Int(followers)) + " followers"
                }else{
                   self.followersCount.text = "No Followers"
                }
                
                if let caption = postInfo.caption{
                    self.captionText.text = caption
                }else{
                    self.captionText.text = ""
                }
                
                if let postImageUrl = postInfo.imageUrl{
                   self.postImage.sd_setImage(with: URL.init(string: postImageUrl), placeholderImage: UIImage(named: "defaultProduct"))
                }else{
                    self.postImage.image = UIImage(named: "defaultProduct")
                }
                
            }
        }
    }
    
	
}

class ViewOfferStatisticVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var saleStatsLabel: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//TVheight.constant = cellHeight * CGFloat(stat!.posted.count)
		return stat!.posted.count
	}

	let cellHeight: CGFloat = 450
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return cellHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = influencerShelf.dequeueReusableCell(withIdentifier: "infStatCell") as! InfluencerStatCell
        cell.setPostInfo = stat!.posted[indexPath.row]
		return cell
	}
	

	@IBOutlet weak var influencerShelf: UITableView!
	@IBOutlet weak var TVheight: NSLayoutConstraint!
	var stat: OfferStatistic?
    
    @IBOutlet weak var pieView: ShadowView!
    @IBOutlet weak var statMoneyText: UILabel!
    
    @IBOutlet weak var acceptedOfferCount: UILabel!
    @IBOutlet weak var postedCount: UILabel!
	@IBOutlet weak var wasVerifiedLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		influencerShelf.delegate = self
		influencerShelf.dataSource = self
		saleStatsLabel.text = "\"" + stat!.offer.title + "\" Statistics"
        self.updateTableConstraints()
        self.setPieChart()
		wasVerifiedLabel.text = stat!.posted.count == 0 ? "No posts were verifeid yet.\nYou will see them here when they are." : "Posts that were verified:"
    }
    
		func updateTableConstraints() {
        TVheight.constant = cellHeight * CGFloat(stat!.posted.count) * 2
        influencerShelf.layoutIfNeeded()
        influencerShelf.updateConstraints()
    }
    
    func setPieChart() {
        let pieChartView = StaticsPie()
        pieChartView.frame = CGRect(x: 0, y: 0, width: self.pieView.frame.size.width, height: self.pieView.frame.size.height)
		let money = self.stat!.offer.originalAmount == 0.0 ? self.stat!.offer.money : self.stat!.offer.originalAmount
        let cashPower = (money - self.stat!.offer.cashPower!)
        pieChartView.segments = [
			OfferStatusSegment(color: .lightGray, value: CGFloat(cashPower)),
            OfferStatusSegment(color: UIColor.init(red: 1, green: 227/255, blue: 35/255, alpha: 1), value: CGFloat(money)),
           
        ]
        self.pieView.addSubview(pieChartView)
        
        self.statMoneyText.text = "\(NumberToPrice(Value: cashPower)) of \(NumberToPrice(Value: money)) used so far."
        self.acceptedOfferCount.text = "\(self.stat!.acceptedCount) influencer\(self.stat!.acceptedCount == 1 ? "" : "s") have accepted so far."
        self.postedCount.text = "\(self.stat!.posted.count) influencer\(self.stat!.posted.count == 1 ? "" : "s") have posted so far."
    }
	
	@IBAction func dismissView(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	

}
