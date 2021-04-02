//
//  OfferNewCreateVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol BusinessDelegate {
    func reloadBusiness()
}

class NewAddPostCell: UITableViewCell {
}

class OfferNewCreateVC: BaseVC, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BusinessDelegate {
    
    func reloadBusiness() {
        self.setOfferData()
    }
    
    @IBOutlet weak var largeImg: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var offerName: UITextField!
    @IBOutlet weak var cmyName: UILabel!
    
    @IBOutlet weak var postTable: UITableView!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postShadow: ShadowView!
    
    @IBOutlet weak var delView: ShadowView!
    
    var index: Int? = nil
    
    var draftTemp: DraftOffer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setOfferData()
    }
    
    func setOfferData() {
        
        if index != nil {
            let draftOffer = MyCompany.drafts[index!]
            self.offerName.text = "Offer \((index! + 1))"
            self.offerName.isUserInteractionEnabled = false
            
            let company = MyCompany.basics.filter({ (basic) -> Bool in
                return basic.basicId == draftOffer.basicId
            })
            
            if let basic = company.first {
                if let url = URL.init(string: basic.logoUrl) {
                    self.largeImg.downloadedFrom(url: url)
                    self.logo.downloadedFrom(url: url)
                    
                }
                self.cmyName.text = "Offer will appear from \(basic.name)"
            }
            
            tableHeight.constant = CGFloat((MyCompany.drafts[index!].draftPosts.count + 1) * 45)
            self.postShadow.layoutIfNeeded()
            self.delView.isHidden = false
            self.draftTemp = draftOffer
        }else{
            if self.draftTemp == nil {
                self.delView.isHidden = true
                self.offerName.text = "Offer \((MyCompany.drafts.count + 1))"
                self.cmyName.text = "No Company Chosen"
                self.draftTemp = createTempDraft()
            }else{
                let company = MyCompany.basics.filter({ (basic) -> Bool in
                    return basic.basicId == self.draftTemp!.basicId
                })
                
                if let basic = company.first {
                    if let url = URL.init(string: basic.logoUrl) {
                        self.largeImg.downloadedFrom(url: url)
                        self.logo.downloadedFrom(url: url)
                        
                    }
                    self.cmyName.text = "Offer will appear from \(basic.name)"
                }
            }
            
        }
        
        self.postTable.delegate = self
        self.postTable.dataSource = self
        self.postTable.reloadData()
    }
    
    func createTempDraft() -> DraftOffer {
        
        let draftID = GetNewID()
        let tempDict = ["title":"","mustBeOver21": false, "payIncrease": 1.0, "lastEdited": Date().toUString()] as [String : Any]
        let draft = DraftOffer.init(dictionary: tempDict, businessId: MyCompany.businessId, draftId: draftID)
        return draft
    }
    
    @IBAction func editOfferAction(sender: UIButton){
        self.offerName.isUserInteractionEnabled = true
        self.offerName.becomeFirstResponder()
    }
    
    @IBAction func dismissAction(sender: UIButton){
        draftTemp!.lastEdited = Date()
        if index == nil {
            if draftTemp!.basicId == ""  {
                self.showAlertMessage(title: "Alert", message: "Please choose any comapny") {
                }
                return
            }
            
            if self.draftTemp!.draftPosts.count == 0 {
                self.showAlertMessage(title: "Alert", message: "Please add atleast one post") {
                }
                return
            }
            
            MyCompany.drafts.append(draftTemp!)
        }else{
            MyCompany.drafts[index!] = draftTemp!
        }
        
        MyCompany.UpdateToFirebase { (error) in
            if !error{
               self.navigationController?.popViewController(animated: true)
            }
        }
        
        
    }
    
    //MARK: Textfield Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.offerName.isUserInteractionEnabled = false
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.draftTemp!.draftPosts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == self.draftTemp!.draftPosts.count {
            let identifier = "addpost"
            let cell = self.postTable.dequeueReusableCell(withIdentifier: identifier) as! NewAddPostCell
            return cell
        }
        let identifier = "postlist"
        let cell = self.postTable.dequeueReusableCell(withIdentifier: identifier) as! AddPostTC
        cell.addPostText.text = "Post \((indexPath.row + 1))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var postIndex: Int? = nil
        
        if index != nil {
            if self.draftTemp!.draftPosts.count != indexPath.row {
                postIndex = indexPath.row
            }
        }
        
        self.performSegue(withIdentifier: "toPostDetail", sender: postIndex)
        
    }
    
    @IBAction func changeCompanyAction(sender: UIButton){
        let draftOffer = self.draftTemp
        self.performSegue(withIdentifier: "toCompanyList", sender: draftOffer)
    }
    
    @IBAction func deleteAction(sender: UIButton){
        
        self.showAlertMessageForDestruction(title: "Alert", message: "Are you sure to delete the offer?", cancelTitle: "No", destructionTitle: "Yes", completion: {
            
        }, completionDestruction: {
            self.deleteOffer()
        })
        

        
    }

    func deleteOffer() {
        let draftOffer = MyCompany.drafts[index!]
        let index = MyCompany.drafts.lastIndex { (draft) -> Bool in
            return draft.draftId == draftOffer.draftId
        }
        
        MyCompany.drafts.remove(at: index!)
        
        MyCompany.UpdateToFirebase { (errorFIB) in
            if !errorFIB{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func filterOffer(sender: UIButton){
        self.performSegue(withIdentifier: "toFilterOffer", sender: self)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? BasicsListVC{
            view.reloadBusiness = self
            view.draftOffer = (sender as! DraftOffer)
        }
        if let view = segue.destination as? PostDetailVC {
            view.draftOffer =  self.draftTemp
            view.postIndex = sender as? Int
        }
    }
    

}
