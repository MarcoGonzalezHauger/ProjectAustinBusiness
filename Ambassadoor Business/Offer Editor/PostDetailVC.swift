//
//  PostDetailVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 23/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PostDetailVC: BaseVC, UITableViewDelegate, UITableViewDataSource, deletePhrase {
    
    
    func deleteThis(cell: UITableViewCell) {
        if phraseList.count <= 1 {
            if let newcell = (cell as? KeyphraseCell) {
                newcell.phraseText.text = ""
                MakeShake(viewToShake: cell, coefficient: 0.2)
            } else {
                MakeShake(viewToShake: cell)
            }
            return
        }
        let ip: IndexPath = shelf.indexPath(for: cell)!
        phraseList.remove(at: ip.row)
        shelf.deleteRows(at: [ip], with: .right)
    }
    
    func textChanged(at cell: UITableViewCell, to: String) {
        let ip: IndexPath = shelf.indexPath(for: cell)!
        phraseList[ip.row] = to
    }
    
    func NotValidWord(words: [String]) {
        self.showAlertMessage(title: words.first!, message: words.last!){ }
    }
    
    
    var draftOffer: DraftOffer? = nil
    var postIndex: Int? = nil
    
    var phraseList: [String] = []
    
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var shelf: UITableView!
    
    @IBOutlet weak var largeImg: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    
    @IBOutlet weak var postName: UILabel!
    @IBOutlet weak var postInstruction: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPostDetails()
        // Do any additional setup after loading the view.
    }
    
    func setPostDetails(){
        self.postName.text = "Post \((self.postIndex == nil ? (self.draftOffer!.draftPosts.count + 1) : (self.postIndex! + 1)))"
        if let draft = self.draftOffer{
            let company = MyCompany.basics.filter({ (basic) -> Bool in
                return basic.basicId == draft.basicId
            })
            
            if let basic = company.first {
                if let url = URL.init(string: basic.logoUrl) {
                    self.logoImg.downloadedFrom(url: url)
                    self.largeImg.downloadedFrom(url: url)
                }
            }
            
            if postIndex != nil {
                let post = draftOffer?.draftPosts[postIndex!]
                phraseList.append(contentsOf: post!.requiredKeywords)
                for hashtag in post!.requiredHastags {
                    if hashtag.starts(with: "#") {
                        phraseList.append("\(hashtag)")
                    }else{
                        phraseList.append("#\(hashtag)")
                    }
                }
                
                self.postInstruction.text = post?.instructions
                
            }
            if phraseList.count == 0 {
                phraseList.append("")
            }
            shelf.reloadData()
        
        }
        self.addDoneButtonOnKeyboard(textView: postInstruction)
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height + 65
        scroll.contentInset = contentInset
        print(contentInset)
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    @objc override func doneButtonAction() {
        self.postInstruction.resignFirstResponder()
        //self.category.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phraseList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phraseCell") as! KeyphraseCell
        cell.addpostRef = self
        cell.phraseText.text = phraseList[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    @IBAction func dismissAction(sender: AnyObject){
        if self.postInstruction.text.count == 0 {
            self.showAlertMessage(title: "Alert", message: "You need to put in instructions for the influencer to follow.") {
            }
            return
        }
        for phase in self.phraseList {
            if phase == "" {
                self.showAlertMessage(title: "Alert", message: "You left a blank in your required caption items.") {
                }
                return
            }
            
            if phase == "#" {
                self.showAlertMessage(title: "Alert", message: "You left a blank hashtag in your required caption items.") {
                }
                return
            }
        }
		let tempHash = phraseList.filter { (hashtag) -> Bool in
            return hashtag.starts(with: "#")
        }
		var hash: [String] = []
		for h in tempHash {
			hash.append(String(h.dropFirst()))
		}
		if !hash.contains("ad") {
			hash.append("ad")
		}
        let phase = phraseList.filter { (hashtag) -> Bool in
            return !hashtag.starts(with: "#")
        }
        
        if self.postIndex == nil{
            let post = DraftPost.init(businessId: MyCompany.businessId, draftId: self.draftOffer!.draftId, poolId: "", hash: hash, keywords: phase, ins: self.postInstruction.text)
            self.draftOffer?.draftPosts.append(post)
        }else{
            let modified = self.draftOffer?.draftPosts[self.postIndex!]
            let postData = ["requiredHastags": hash, "requiredKeywords": phase, "instructions": self.postInstruction.text!] as [String: Any]
            let post = DraftPost.init(dictionary: postData, businessId: MyCompany.businessId, draftId: self.draftOffer!.draftId, draftPostId: modified!.draftPostId, poolId: "")
            self.draftOffer?.draftPosts[self.postIndex!] = post
        }
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPhrase(_ sender: Any) {
        addNewItem(text: "", sender: sender as! UIButton)
    }
    
    @IBAction func addHashtag(_ sender: Any) {
        addNewItem(text: "#", sender: sender as! UIButton)
        
    }
    
    func addNewItem(text: String, sender: UIButton) {
        if phraseList.count >= 5 {
            MakeShake(viewToShake: sender)
            self.showAlertMessage(title: "Max Capacity", message: "Your list of required text is at maximum capacity (5 items)"){ }
        } else {
            let ip = IndexPath(row: phraseList.count, section: 0)
            phraseList.append(text)
            shelf.insertRows(at: [ip], with: .top)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
