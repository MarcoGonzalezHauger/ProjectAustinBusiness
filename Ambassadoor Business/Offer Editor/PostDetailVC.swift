//
//  PostDetailVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 23/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol deletePhrase {
    func deleteThis(cell: UITableViewCell)
    func textChanged(at: UITableViewCell, to: String)
    func NotValidWord(words: [String])
}

class KeyphraseCell: UITableViewCell, UITextFieldDelegate {
    
    var addpostRef: PostDetailVC? = nil
    var delegate: deletePhrase?
    var wasTold = false
    @IBOutlet weak var phraseText: UITextField!
    @IBOutlet weak var delete: UIButton!
    @IBAction func deletePhrase(_ sender: Any) {
        delegate?.deleteThis(cell: self)
    }
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: phraseText)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: phraseText)
    }
    
    @objc func keyboardWasShown(notification : NSNotification) {
        
 //       if let key = notification.object as? UITextField {
 //           if key == phraseText {
                
                let userInfo = notification.userInfo!
                var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
                keyboardFrame = addpostRef!.view.convert(keyboardFrame, from: nil)
                
                var contentInset:UIEdgeInsets = addpostRef!.scroll.contentInset
                contentInset.bottom = keyboardFrame.size.height + 25
                addpostRef!.scroll.contentInset = contentInset
                
  //          }
  //      }
        
        
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
//        if let key = notification.object as? UITextField {
//        if key == phraseText {
            
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            addpostRef!.scroll.contentInset = contentInset
            
//            }
 //       }
    }
    
    @IBAction func returnEntered(_ sender: Any) {
        (sender as! UITextField).resignFirstResponder()
    }
    @IBAction func editingChanged(_ sender: Any) {
        
        //Contains what the current phrasetext will look like.
        var currentString: String = phraseText.text!
        
        if currentString.count > 75 {
            currentString = String(currentString.dropLast(currentString.count - 75))
            MakeShake(viewToShake: self, coefficient: 0.2, positiveCoefficient: 0)
            if !wasTold {
                delegate?.NotValidWord(words: ["Max Length Reached", "Each phrase may only have a maximum of 75 characters."])
                wasTold = true
            }
        }
        
        //hashtag positioning correction
        let index = currentString.filter{ (char) -> Bool in
            return char == "#"
        }.count
        if index != 0 {
            let beginsWithHashtag = currentString.hasPrefix("#")
            if !beginsWithHashtag {
                currentString = currentString.replacingOccurrences(of: "#", with: "")
                MakeShake(viewToShake: self, coefficient: 0.2)
            } else {
                if index > 1 {
                    currentString = String(currentString.dropFirst())
                    currentString = currentString.replacingOccurrences(of: "#", with: "")
                    currentString = "#\(currentString)"
                    MakeShake(viewToShake: self, coefficient: 0.2)
                }
            }
        }
        
        var matchFound = true
        while(matchFound) {
            for curse in swearWords {
                let check = currentString.replacingOccurrences(of: "#", with: "")
                if check.lowercased().starts(with: "\(curse.lowercased()) ") || check.lowercased().contains(" \(curse.lowercased()) ") || check.lowercased().hasSuffix(" \(curse)") || check.lowercased() == curse.lowercased() {
                    if let thisRange = currentString.range(of: curse, options: .caseInsensitive) {
                        currentString.replaceSubrange(thisRange.lowerBound ..< thisRange.upperBound, with: "")
                        MakeShake(viewToShake: self, coefficient: 0.2)
                        delegate?.NotValidWord(words: ["Text Not Permitted", "The text \"\(curse)\" is not permitted in caption."])
                        continue
                    }
                }
            }
            matchFound = false
        }
        
        phraseText.text = currentString
        delegate?.textChanged(at: self, to: currentString)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.hasPrefix("#"))! {
            
            let rawString = string
             let range = rawString.rangeOfCharacter(from: .whitespaces)
            if ((textField.text?.count)! == 0 && range  != nil)
            || ((textField.text?.count)! > 0 && range != nil)  {
                return false
            }
            
        }
    return true
    }
}


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
    
    @IBOutlet weak var backBtn: UIButton!

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
                self.backBtn.setTitle("Done", for: .normal)
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
                
            }else{
                self.backBtn.setTitle("Back", for: .normal)
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
        
        let pharse = self.phraseList.filter { (pharse) -> Bool in
            return pharse != "" && pharse != "#"
        }
        
        if postIndex == nil && pharse.count == 0 && self.postInstruction.text.count == 0{
           self.navigationController?.popViewController(animated: true)
           return 
        }
        
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
