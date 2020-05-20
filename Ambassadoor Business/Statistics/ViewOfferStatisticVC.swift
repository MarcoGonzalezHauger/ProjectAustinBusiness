//
//  ViewOfferStatisticVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/19/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InfluencerStatCell: UITableViewCell {
	
}

class ViewOfferStatisticVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var saleStatsLabel: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		TVheight.constant = cellHeight * CGFloat(stat!.posted.count)
		return stat!.posted.count
	}

	let cellHeight: CGFloat = 350
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return cellHeight
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = influencerShelf.dequeueReusableCell(withIdentifier: "infStatCell") as! InfluencerStatCell
		
		return cell
	}
	

	@IBOutlet weak var influencerShelf: UITableView!
	@IBOutlet weak var TVheight: NSLayoutConstraint!
	var stat: OfferStatistic?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		influencerShelf.delegate = self
		influencerShelf.dataSource = self
		saleStatsLabel.text = "\"" + stat!.offer.title + "\" Statistics"
    }
	
	@IBAction func dismissView(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	

}
