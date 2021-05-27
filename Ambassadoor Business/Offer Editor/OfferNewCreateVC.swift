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

class OfferNewCreateVC: BaseVC, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, BusinessDelegate, NCDelegate {
    func shouldAllowBack() -> Bool {
        if checkIfEdited() && self.isSavable() {
            draftTemp!.lastEdited = Date()
            if index == nil{
               MyCompany.drafts.append(draftTemp!)
            }else{
               MyCompany.drafts[index!] = draftTemp!
            }
            
            MyCompany.UpdateToFirebase { (error) in
            }
            return true
        }else{
            return false
        }
    }
    
    
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
    
    @IBOutlet weak var backBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = self.navigationController as? StandardNC {
            nc.tempDelegate = self
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        backBtn.isUserInteractionEnabled = true
        self.setOfferData()
    }
    
    func checkIfEdited() -> Bool {
        var checkEdited = false
        if index == nil {
        if self.draftTemp != nil{
            if self.draftTemp?.basicId != nil && self.draftTemp?.basicId != ""{
               checkEdited = true
            }
            if self.draftTemp?.draftPosts.count != 0 {
                checkEdited = true
            }
        }
        }else{
            checkEdited = true
        }
        return checkEdited
    }
    
    func setOfferData() {
        
        if index != nil {
            self.backBtn.setTitle("Done", for: .normal)
            let draftOffer = MyCompany.drafts[index!]
            self.offerName.text = draftOffer.title == "" ? "Offer \((MyCompany.drafts.count))" : draftOffer.title
            self.offerName.isUserInteractionEnabled = false
            
            let company = MyCompany.basics.filter({ (basic) -> Bool in
                return basic.basicId == draftOffer.basicId
            })
            
            if let basic = company.first {
                setBasicBusinessLogo(basic: basic)
            }else{
                self.cmyName.text = "No Company Chosen"
            }
            
            self.delView.isHidden = false
            self.draftTemp = draftOffer
        }else{
            
            if self.draftTemp == nil {
                self.delView.isHidden = true
                self.offerName.text = "Offer \((MyCompany.drafts.count + 1))"
                self.cmyName.text = "No Company Chosen"
                self.draftTemp = createTempDraft()
                self.backBtn.setTitle("Back", for: .normal)
            }else{
                let company = MyCompany.basics.filter({ (basic) -> Bool in
                    return basic.basicId == self.draftTemp!.basicId
                })
                
                if let basic = company.first {
                   setBasicBusinessLogo(basic: basic)
                }
                self.backBtn.setTitle("Done", for: .normal)
            }
            
        }
        self.setPostConstraints()
        self.setTableSource()
    }
    
    func setTableSource() {
        self.postTable.delegate = self
        self.postTable.dataSource = self
        self.postTable.reloadData()
    }
    
    func setBasicBusinessLogo(basic: BasicBusiness) {
        if let url = URL.init(string: basic.logoUrl) {
            self.largeImg.downloadedFrom(url: url)
            self.logo.downloadedFrom(url: url)
            
        }
        self.cmyName.text = "Offer will appear from \(basic.name)"
    }
    
    func setPostConstraints() {
        
        if index != nil {
            tableHeight.constant = MyCompany.drafts[index!].draftPosts.count == 3 ? CGFloat((MyCompany.drafts[index!].draftPosts.count) * 45) :   CGFloat((MyCompany.drafts[index!].draftPosts.count + 1) * 45)
        }else{
            if self.draftTemp != nil {
               tableHeight.constant = self.draftTemp!.draftPosts.count == 3 ? CGFloat((self.draftTemp!.draftPosts.count) * 45) :   CGFloat((self.draftTemp!.draftPosts.count + 1) * 45)
            }else{
               tableHeight.constant = 45
            }
        }
    }
    
    func createTempDraft() -> DraftOffer {
        
        let draftID = GetNewID()
        let tempDict = ["title":self.offerName.text!,"mustBeOver21": false, "payIncrease": 1.0, "lastEdited": Date().toUString()] as [String : Any]
        let draft = DraftOffer.init(dictionary: tempDict, businessId: MyCompany.businessId, draftId: draftID)
        return draft
    }
    
    @IBAction func editOfferAction(sender: UIButton){
        self.offerName.isUserInteractionEnabled = true
        self.offerName.becomeFirstResponder()
    }
    
    @IBAction func dismissAction(sender: UIButton){
        
        if index == nil && !checkIfEdited(){
            DispatchQueue.main.async {
                self.backBtn.isUserInteractionEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
        }else{
        
        backBtn.isUserInteractionEnabled = false
        
        if self.isSavable() {
            draftTemp!.lastEdited = Date()
            if index == nil{
               MyCompany.drafts.append(draftTemp!)
            }else{
               MyCompany.drafts[index!] = draftTemp!
            }
            
            MyCompany.UpdateToFirebase { (error) in
                if !error{
                    DispatchQueue.main.async {
                        self.backBtn.isUserInteractionEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }
            }
        }else{
            DispatchQueue.main.async {
                self.backBtn.isUserInteractionEnabled = true
            }
        }
        }
    }
    
    
    
    func isSavable() -> Bool {
        if draftTemp!.basicId == ""  {
            self.showAlertMessage(title: "Alert", message: "Please choose any comapny") {
            }
            return false
        }
        
        if self.draftTemp!.draftPosts.count == 0 {
            self.showAlertMessage(title: "Alert", message: "Please add atleast one post") {
            }
            return false
        }
        return true
    }
    
    //MARK: Textfield Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.offerName.isUserInteractionEnabled = false
        if textField.text?.count != 0{
            self.draftTemp?.title = textField.text!
        }
        return true
    }
    
	@IBOutlet weak var informationalLabel: UILabel!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var numOfRows = self.draftTemp!.draftPosts.count + 1
		if numOfRows > 3 {
			numOfRows = 3
		}
		let counttext = "\(numOfRows) post \(numOfRows == 1 ? "" : "s")"
		informationalLabel.text = "When an influencer accepts this offer they will be required to post \(counttext) to Instagram following the instructions you created:"
		
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.draftTemp!.draftPosts.count < 3 {
            if indexPath.row == self.draftTemp!.draftPosts.count {
                let identifier = "addpost"
                let cell = self.postTable.dequeueReusableCell(withIdentifier: identifier) as! NewAddPostCell
                return cell
            }
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
        if self.draftTemp!.draftPosts.count <= 3 {
            if indexPath.row != self.draftTemp!.draftPosts.count{
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
        if self.isSavable() {
            draftTemp!.lastEdited = Date()
            if index == nil{
                self.index = MyCompany.drafts.count
                MyCompany.drafts.append(draftTemp!)
            }else{
               MyCompany.drafts[index!] = draftTemp!
            }
            
            MyCompany.UpdateToFirebase { (error) in
                if !error{
                    self.performSegue(withIdentifier: "toFilterOffer", sender: self.draftTemp!)
                }
            }
        }
        
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
        
        if let view = segue.destination as? OfferFilterVC {
            view.draftOffer = (sender as! DraftOffer)
        }
    }
    

}
