//
//  NewOfferListVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class OfferList: UITableViewCell{
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var cmyName: UILabel!
    @IBOutlet weak var lastEdited: UILabel!
    var draftOffer: DraftOffer?{
        didSet{
            if let offer = draftOffer{
                
                let company = MyCompany.basics.filter({ (basic) -> Bool in
                    return basic.basicId == offer.basicId
                })
                
                if let basic = company.first {
                    if let url = URL.init(string: basic.logoUrl) {
                        self.companyLogo.downloadedFrom(url: url)
                    }
                }
                
                
                //self.lastEdited.text = offer.lastEdited.toUString()
                self.lastEdited.text = "Last edited " + DateToAgo(date: offer.lastEdited)
                self.cmyName.text = MyCompany.basics.first!.name
            }
        }
    }
    
}

class AddOfferCell: UITableViewCell {
    
}

class NewOfferListVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var offerList: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyCompany.drafts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == MyCompany.drafts.count {
            let identifier = "addoffer"
            let cell = self.offerList.dequeueReusableCell(withIdentifier: identifier) as! AddOfferCell
            return cell
        }
        let identifier = "offerlist"
        let cell = self.offerList.dequeueReusableCell(withIdentifier: identifier) as! OfferList
        cell.draftOffer = MyCompany.drafts[indexPath.row]
        cell.offerName.text = "Offer \((indexPath.row + 1))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index: Int? = nil
        if indexPath.row != MyCompany.drafts.count {
            index = indexPath.row
        }
        self.performSegue(withIdentifier: "toNewOfferCreate", sender: index)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setTableSource()
    }
    
    func setTableSource() {
        self.offerList.delegate = self
        self.offerList.dataSource = self
        self.offerList.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? OfferNewCreateVC{
            view.index = sender as? Int
        }
    }

}
