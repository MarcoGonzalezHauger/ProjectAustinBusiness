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
                
                self.offerName.text = offer.title
                
                let company = MyCompany.basics.filter({ (basic) -> Bool in
                    return basic.basicId == offer.basicId
                })
				
				self.companyLogo.image = nil
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
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var addBtn: UIButton!
    
    var isEditOffer = false
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addBtn.isHidden = GetSortedList().count == 0 ? true : false
        return GetSortedList().count + 1
        //return MyCompany.drafts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == GetSortedList().count {
            let identifier = "addoffer"
            let cell = self.offerList.dequeueReusableCell(withIdentifier: identifier) as! AddOfferCell
            return cell
        }
        
        let identifier = "offerlist"
        let cell = self.offerList.dequeueReusableCell(withIdentifier: identifier) as! OfferList
        let draft = GetSortedList()[indexPath.row]
        cell.draftOffer = draft
        cell.offerName.text = draft.title == "" ? "Offer \((indexPath.row + 1))" : draft.title
        return cell
    }
	
	func GetSortedList() -> [DraftOffer] {
        let filtered = MyCompany.drafts.sorted{$0.lastEdited > $1.lastEdited}
        MyCompany.drafts = filtered
		return filtered
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index: Int? = nil
        if indexPath.row != MyCompany.drafts.count {
            index = indexPath.row
        }else{
            index = nil
        }
        self.performSegue(withIdentifier: "toNewOfferCreate", sender: index)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return indexPath.row != MyCompany.drafts.count ? .delete : .none
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        let draft = GetSortedList()[indexPath.row]
        print("draftID=",draft.draftId)
        draft.getDraftFromPool { isExist in
            if isExist{
                self.showAlertMessage(title: "Alert", message: "You cannot delete offers you have already distributed") {
                    
                }
            }else{
                self.deleteOffer(index: indexPath.row)
            }
        }
    }
    
    func deleteOffer(index: Int) {
        let draftOffer = MyCompany.drafts[index]
        let index = MyCompany.drafts.lastIndex { (draft) -> Bool in
            return draft.draftId == draftOffer.draftId
        }
        
        MyCompany.drafts.remove(at: index!)
        
        MyCompany.UpdateToFirebase { (errorFIB) in
            if !errorFIB{
                DispatchQueue.main.async {
                    self.offerList.reloadData()
                }
            }
        }
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
    
    @IBAction func newOfferAction(sender: UIButton){
        self.performSegue(withIdentifier: "toNewOfferCreate", sender: nil)
    }
    
    @IBAction func editOffers(sender: UIButton){
        self.offerList .setEditing(!self.isEditOffer ? true : false, animated: true)
        self.editBtn.setTitle(!self.isEditOffer ? "Done" : "Edit", for: .normal)
        self.isEditOffer = !self.isEditOffer
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? OfferNewCreateVC{
            view.index = sender as? Int
        }
    }

}
