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
        
    }
    
    /// UITableView primary action. resign text field
    /// - Parameter sender: UITextField referrance
    @IBAction func returnEntered(_ sender: Any) {
        (sender as! UITextField).resignFirstResponder()
    }
    
    /// UITextField edit changed action. Check if user entered keyword or hashtag not more than 75 characters. check if user entered hashtag that should contain # before the text. Check if hash and keyword is not swearWords.
    /// - Parameter sender: UITextField referrance
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
    
//    Disallow if user enters # in between hashtag field.
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


class PostDetailVC: BaseVC, UITableViewDelegate, UITableViewDataSource, deletePhrase, NCDelegate {
	
    
    ///  NCDelegate Method. check if user entered valid keywords or hashtags
    /// - Returns: true if entered valid keywords or hashtags otherwise false
	func shouldAllowBack() -> Bool {
		return tryDismiss()
	}
    
    /// Delete keywords or hashtags. check if user entered more than one keywords or hashtags. get index and remove data.
    /// - Parameter cell: UITableViewCell referrance
    func deleteThis(cell: UITableViewCell) {
        if phraseList.count <= 1 {
            if let newcell = (cell as? KeyphraseCell) {
                newcell.phraseText.text = ""
                if let index = self.shelf.indexPath(for: newcell){
                    phraseList[index.row] = ""
                }
                self.shelf.reloadData()
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
    
    /// deletePhrase delegate method. Call back if kewords or hashtags cell edited
    /// - Parameters:
    ///   - cell: KeyphraseCell cell referrance
    ///   - to: edited text
    func textChanged(at cell: UITableViewCell, to: String) {
        let ip: IndexPath = shelf.indexPath(for: cell)!
        print("tick =",ip.row)
        phraseList[ip.row] = to
    }
    
    /// deletePhrase delegate method. Call back if keword or hashtag is invalid.
    /// - Parameter words: error words
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
		(self.navigationController as! StandardNC).tempDelegate = self
        // Do any additional setup after loading the view.
    }
    
    /// Set post details to all fields if the user edited already created post otherwise initialise all fields
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
					if hashtag != "ad" && hashtag != "#ad" {
						if hashtag.starts(with: "#") {
							phraseList.append("\(hashtag)")
						}else{
							phraseList.append("#\(hashtag)")
						}
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
    /// Adjust scroll view as per Keyboard Height if the keyboard hides textfiled.
    /// - Parameter notification: keyboardWillShowNotification reference
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height + 65
        scroll.contentInset = contentInset
        print(contentInset)
        
    }
    ///   Getback scroll view to normal state
    /// - Parameter notification: keyboardWillHideNotification reference
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    /// Custom textfield done button. resign first responder UITextView
    @objc override func doneButtonAction() {
        self.postInstruction.resignFirstResponder()
        //self.category.resignFirstResponder()
    }
    //MARK: -Post list UITableView Delegate and Datasource
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
	
    
    /// Check If user does not edit anythig. Check if user entered valid instruction. Check if user entered valid keywords or hashtags.Form valid hashtags and keywords. update changes to firebase.
    /// - Returns: return true if user entered valid data otherwise false.
	func tryDismiss() -> Bool {
        
        let pharse = self.phraseList.filter { (pharse) -> Bool in
            return pharse != "" && pharse != "#"
        }
        
        if postIndex == nil && pharse.count == 0 && self.postInstruction.text.count == 0{
           self.navigationController?.popViewController(animated: true)
           return false
        }
        
        
        
		if self.postInstruction.text.count == 0 {
			self.showAlertMessage(title: "Post not complete", message: "Add instruction for how you post should come on instagram"){ }
            return false
		}
        let phaseCheck = self.phraseList.filter{$0 != "" && $0.starts(with: "#") ? $0.count > 1 : $0.count > 0}
		if phaseCheck.count == 0 {
			self.showAlertMessage(title: "Post not complete", message: "Add at least one phrase in Caption Requirements to save."){ }
			return false
		}
        
        self.phraseList = self.phraseList.filter { (pharse) -> Bool in
            return pharse != "" && pharse != "#"
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
		return true
	}
    
    
    /// Dismiss current viewcontroller if tryDismiss() method returns true.
    /// - Parameter sender: UIButton referrance
    @IBAction func dismissAction(sender: AnyObject){
		if tryDismiss() {
			self.navigationController?.popViewController(animated: true)
		}
    }
    
    
    /// Add new pharse text field
    /// - Parameter sender: UIButton referrance
    @IBAction func addPhrase(_ sender: Any) {
        addNewItem(text: "", sender: sender as! UIButton)
    }
    /// Add new hashtag text field
    /// - Parameter sender: UIButton referrance
    @IBAction func addHashtag(_ sender: Any) {
        addNewItem(text: "#", sender: sender as! UIButton)
        
    }
    
    
    /// reload post cells. Check if the user not added more than five field. Insert cell and reload the post data.
    /// - Parameters:
    ///   - text: pharse or hashtag text
    ///   - sender: UIButton referrance
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
