//
//  OfferNewCreateVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewAddPostCell: UITableViewCell {
    
}

class OfferNewCreateVC: BaseVC, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var largeImg: UIImageView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var offerName: UITextField!
    @IBOutlet weak var cmyName: UILabel!
    
    @IBOutlet weak var postTable: UITableView!
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var postShadow: ShadowView!
    
    var index: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setOfferData()
    }
    
    func setOfferData() {
        let draftOffer = MyCompany.drafts[index]
        self.offerName.text = "Offer \((index + 1))"
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
        
        tableHeight.constant = CGFloat((MyCompany.drafts[index].draftPosts.count + 1) * 45)
        self.postShadow.layoutIfNeeded()
        
        
        self.postTable.delegate = self
        self.postTable.dataSource = self
        self.postTable.reloadData()
    }
    
    @IBAction func editOfferAction(sender: UIButton){
        self.offerName.isUserInteractionEnabled = true
        self.offerName.becomeFirstResponder()
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Textfield Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.offerName.isUserInteractionEnabled = false
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyCompany.drafts[index].draftPosts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == MyCompany.drafts[index].draftPosts.count {
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
        //self.performSegue(withIdentifier: "toNewOfferCreate", sender: indexPath.row)
    }
    
    @IBAction func changeCompanyAction(sender: UIButton){
        let draftOffer = MyCompany.drafts[index]
        self.performSegue(withIdentifier: "toCompanyList", sender: draftOffer)
    }
    
    @IBAction func deleteAction(sender: UIButton){
        
        let draftOffer = MyCompany.drafts[index]
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? BasicsListVC{
            view.draftOffer = (sender as! DraftOffer)
        }
    }
    

}
