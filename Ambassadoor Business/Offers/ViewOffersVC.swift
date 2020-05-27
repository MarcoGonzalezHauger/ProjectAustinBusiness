//
//  ViewOffersVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 6/29/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage
import Firebase

class composeButtonCell: UITableViewCell {
	@IBOutlet weak var composebuttonOutline: UIView!
    @IBOutlet weak var composebutton: UIButton!
}

protocol ViewStatisticDelegate {
    func viewStatisticAction(offer: TemplateOffer)
}

class viewOfferCell: UITableViewCell {
	@IBOutlet weak var offerviewoutline: UIView!
	@IBOutlet weak var offerName: UILabel!
	@IBOutlet weak var postDetails: UILabel!
	@IBOutlet weak var incompleteLabel: UILabel!
	@IBOutlet weak var lastEditedLabel: UILabel!
    @IBOutlet weak var viewStatistics: UIButton!
    var offer: TemplateOffer?
    
    var viewStatistic: ViewStatisticDelegate? = nil
    
    @IBAction func viewStatisticAction(sender: UIButton){
        
        self.viewStatistic?.viewStatisticAction(offer: offer!)
        
    }
	
}

class ViewOffersVC: BaseVC, UITableViewDelegate, UITableViewDataSource, ViewStatisticDelegate {
    func viewStatisticAction(offer: TemplateOffer) {
        
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.OfferDrafts.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let index = indexPath.row
		if index == 0 {
			let cell = shelf.dequeueReusableCell(withIdentifier: "composeButton") as! composeButtonCell
            cell.composebutton.addTarget(self, action: #selector(self.composeAction(sender:)), for: .touchUpInside)
			return cell
		} else {
			let thisTemplate: TemplateOffer = global.OfferDrafts[indexPath.row - 1]
			let cell = shelf.dequeueReusableCell(withIdentifier: "offerButton") as! viewOfferCell
            cell.offer = thisTemplate
			cell.offerName.text = thisTemplate.title == "" ? "Untitled" : thisTemplate.title
			cell.offerName.textColor = thisTemplate.title == "" ? UIColor.gray : GetForeColor()
			cell.postDetails.text = thisTemplate.GetSummary()
			cell.incompleteLabel.isHidden = thisTemplate.isFinished() == []
            cell.viewStatistic = self
            cell.viewStatistics.isHidden = !thisTemplate.isStatistic
			cell.lastEditedLabel.text = "Last edited " + DateToAgo(date: thisTemplate.lastEdited)
			return cell
		}
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.row == 0 {
			return 74
        }
		return 276
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if indexPath.row != 0 {
            let template = global.OfferDrafts[indexPath.row - 1]
            template.offerStatistics?.getInformation()
            self.performSegue(withIdentifier: "toCreateOfferView", sender: template)
        }
    }
    
    @objc func composeAction(sender: UIButton){
        global.post.removeAll()
        self.performSegue(withIdentifier: "toCreateOfferView", sender: nil)
    }
    
    @objc func editAction(sender: UIButton){
        let template = global.OfferDrafts[sender.tag]
        self.performSegue(withIdentifier: "toCreateOfferView", sender: template)
    }
     
	@IBOutlet weak var shelf: UITableView!
    @IBOutlet weak var editButton: UIButton!
    var isEdit = false
	
	@objc func timerAction(sender: AnyObject) {
		shelf.reloadData()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
		let timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.timerAction(sender:)), userInfo: nil, repeats: true)
		timer.fire()
        //let user = Singleton.sharedInstance.getCompanyUser().userID!
        //global.OfferDrafts = GetOffers(userId: user)
        //self.customizeNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
		shelf.dataSource = self
		shelf.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: true)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.hideNavigationAction(notification:)), name: Notification.Name.init(rawValue: "hidenavigation"), object: nil)
		//self.navigationController?.navigationBar.isHidden = true
        //self.navigationController?.hidesBarsOnTap = true
		NotificationCenter.default.addObserver(self, selector: #selector(self.reloadOffer(notification:)), name: Notification.Name.init(rawValue: "reloadOffer"), object: nil)
        
        
        
		getAllTemplateOffers(userID: Auth.auth().currentUser!.uid) { (templateOffers, status) in
			if status == "success" && templateOffers.count != 0 {
				global.OfferDrafts.removeAll()
				global.OfferDrafts.append(contentsOf: templateOffers)
				DispatchQueue.main.async(execute: {
					self.shelf.reloadData()
				})
			}
		}
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func editProducts(_ sender: Any) {
        isEdit = !isEdit
        UIView.animate(withDuration: 0.5) {
            self.editButton.setTitle(self.isEdit ? "Done" : "Edit", for: .normal)
        }
        shelf.setEditing(isEdit, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row != 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let offer = global.OfferDrafts[indexPath.row - 1]
            let ref = Database.database().reference().child("TemplateOffers").child(Auth.auth().currentUser!.uid).child(offer.offer_ID)
            ref.removeValue()
            global.OfferDrafts.remove(at: indexPath.row - 1)
            shelf.deleteRows(at: [indexPath], with: .bottom)
            
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    @objc func reloadOffer(notification: Notification) {
        
        getAllTemplateOffers(userID: Auth.auth().currentUser!.uid) { (templateOffers, status) in
            if status == "success" && templateOffers.count != 0 {
                global.OfferDrafts.removeAll()
                global.OfferDrafts.append(contentsOf: templateOffers)
                DispatchQueue.main.async(execute: {
                    self.shelf.reloadData()
                })
            }else{
                global.OfferDrafts.removeAll()
                DispatchQueue.main.async(execute: {
                    self.shelf.reloadData()
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCreateOfferView"{
            let view = segue.destination as! AddOfferVC
            view.segueOffer = sender as? TemplateOffer
        }
    }
}
