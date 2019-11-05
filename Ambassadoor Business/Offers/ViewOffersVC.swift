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

class viewOfferCell: UITableViewCell {
	@IBOutlet weak var offerviewoutline: UIView!
	@IBOutlet weak var offerName: UILabel!
	@IBOutlet weak var postDetails: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
}

class ViewOffersVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
	
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
			cell.offerName.text = thisTemplate.title
            cell.editButton.addTarget(self, action: #selector(self.editAction(sender:)), for: .touchUpInside)
            cell.editButton.tag = indexPath.row - 1
            if thisTemplate.posts.count >= 3 {
                let offerOne = thisTemplate.posts[0]
                let offerTwo = thisTemplate.posts[1]
                let offerThree = thisTemplate.posts[2]
                /*- Post one features 5 products
                 - Post two features 1 possible product
                 - Post three features 9 possible products
                 */
                cell.postDetails.text = "- Post one features \(String(describing: offerOne.products!.count)) possible \(self.getProductContent(count: offerOne.products!.count)) \n- Post two features \(String(describing: offerTwo.products!.count)) possible \(self.getProductContent(count: offerTwo.products!.count)) \n- Post three features \(String(describing: offerThree.products!.count)) possible \(self.getProductContent(count: offerThree.products!.count))"
                
            }else if thisTemplate.posts.count == 2 {
                let offerOne = thisTemplate.posts[0]
                let offerTwo = thisTemplate.posts[1]
                cell.postDetails.text = "- Post one features \(String(describing: offerOne.products!.count))  possible \(self.getProductContent(count: offerOne.products!.count)) \n- Post two features \(String(describing: offerTwo.products!.count)) possible \(self.getProductContent(count: offerTwo.products!.count))"
                
            }else if thisTemplate.posts.count == 1 {
                let offerOne = thisTemplate.posts[0]
                cell.postDetails.text = "- Post one features \(String(describing: offerOne.products!.count))  possible \(self.getProductContent(count: offerOne.products!.count))"
                
            }
			return cell
		}
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.row == 0 {
			return 66
        }
		return 276.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if indexPath.row != 0 {
            let template = global.OfferDrafts[indexPath.row - 1]
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
    
    func getProductContent(count: Int) -> String {
        
        if count > 1 {
            
            return "products"
            
        }else{
            return "product"
        }
        
        
    }
	

	@IBOutlet weak var shelf: UITableView!
    @IBOutlet weak var editButton: UIButton!
    var isEdit = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        //let user = Singleton.sharedInstance.getCompanyUser().userID!
        //global.OfferDrafts = GetOffers(userId: user)
        //self.customizeNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        shelf.dataSource = self
        shelf.delegate = self
        self.navigationController?.navigationBar.isHidden = true
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
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
