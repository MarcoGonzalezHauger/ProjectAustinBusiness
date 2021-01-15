//
//  AddPostVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 31/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol deletePhrase {
    func deleteThis(cell: UITableViewCell)
    func textChanged(at: UITableViewCell, to: String)
    func NotValidWord(words: [String])
}

class KeyphraseCell: UITableViewCell, UITextFieldDelegate {
    
    var addpostRef: AddPostVC? = nil
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

class AddPostVC: BaseVC, NCDelegate, UITableViewDelegate, UITableViewDataSource, deletePhrase {
    
    
    func NotValidWord(words: [String]) {
        self.showAlertMessage(title: words.first!, message: words.last!){ }
    }
    
    @IBOutlet weak var captionInstructionsLabel: UILabel!
    
    func textChanged(at cell: UITableViewCell, to: String) {
        let ip: IndexPath = shelf.indexPath(for: cell)!
        phraseList[ip.row] = to
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phraseList.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phraseCell") as! KeyphraseCell
        cell.addpostRef = self
        cell.phraseText.text = phraseList[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func shouldAllowBack() -> Bool {
        SaveThisPost(andDismiss: false)
        return true
    }
    
    @IBOutlet weak var noHate: UILabel!
    @IBOutlet weak var shelf: UITableView!
    @IBOutlet weak var InstructionsTextView: UITextView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var saveView: ShadowView!
	@IBOutlet weak var navItem: UINavigationItem!
	
    var postType: TypeofPost?
    var productCollection = [Product]()
    
    var index: Int?
    var productSelectedArray = [Int]()
    var phraseList: [String] = []
    
    var buttonClickTag = 0;
    
    @IBOutlet weak var colorBubble: ShadowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.customizeNavigationBar()
        //self.addLeftButtonText(text: "Back")
//        addleftBarButtonAction()
        SetNumber(number: (index ?? global.post.count) + 1)
        if index != nil {
            let post = global.post[index!]
            self.InstructionsTextView.text = post.instructions
            phraseList.append(contentsOf: post.keywords)
            for hashtag in post.hashtags {
                phraseList.append("#\(hashtag)")
            }
        }
        if phraseList.count == 0 {
            phraseList.append("")
        }
        shelf.reloadData()
        self.addDoneButtonOnKeyboard(textView: InstructionsTextView)
        let user = Singleton.sharedInstance.getCompanyUser()
        //let path = Auth.auth().currentUser!.uid + "/" + user.companyID!
        captionInstructionsLabel.text = "The influencer will need to put all of the phrases and hastags below into the text that goes along with their post on Instagram.\nFor example, if you list \"#sale\" and \"buy one get one free\" the influencer could use the caption: \"buy one get one free at \(YourCompany.name)!! #sale #ad\""
        
        
        // Do any additional setup after loading the view.
        
    }
    
	
    @IBOutlet weak var PostTitle: UILabel!
    
    func SetNumber(number: Int) {
        PostTitle.text = "Post \(number)"
		navItem.title = "Post \(number)"
        switch number {
        case 1: colorBubble.backgroundColor = .systemBlue
        case 2: colorBubble.backgroundColor = .systemYellow
        case 3: colorBubble.backgroundColor = .systemRed
        default: colorBubble.backgroundColor = .systemBlue
        }
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height + 25
        scroll.contentInset = contentInset
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    @objc override func doneButtonAction() {
        self.InstructionsTextView.resignFirstResponder()
        //self.category.resignFirstResponder()
    }
    
    //MARK: - Data Components
    
    @IBAction func savePost(sender: UIButton){
        if canSaveIncomplete() {
        buttonClickTag = 1
        SaveThisPost(andDismiss: true)
        }else{
        self.showAlertMessage(title: "Alert", message: "Please enter the instructions or add pharses") {
            
        }
        }
    }
    
    func canSaveIncomplete() -> Bool {
        if InstructionsTextView.text.count == 0 && phraseList.count == 1{
            if phraseList.first == ""{
            return false
            }else{
            return true
            }
           
        }else{
           return true
        }
    }
    
    func SaveThisPost(andDismiss: Bool) {
        var hashes: [String] = []
        var phrases: [String] = []
        var newList = phraseList
        for i in 0...(newList.count - 1) {
            var thisItem = newList[i]
            while thisItem.hasPrefix(" ") {
                thisItem = String(thisItem.dropFirst())
            }
            while thisItem.hasSuffix(" ") {
                thisItem = String(thisItem.dropLast())
            }
            newList[i] = thisItem
        }
        for p in newList {
            if p != "" {
                if p.hasPrefix("#") {
                    hashes.append(String(p.dropFirst()))
                } else {
                    phrases.append(p)
                }
            }
        }
        var post  = Post.init(image: "", instructions: InstructionsTextView.text!, captionMustInclude: "", products: [], post_ID: "", PostType: PostTypeToText(posttype: .SinglePost), confirmedSince: Date(), isConfirmed: false, hashCaption: "", status: "available", hashtags: hashes, keywords: phrases, isPaid: false, PayAmount: 0.0)
        
        if self.index != nil{
            
            let editedPost = global.post[self.index!]
            post.post_ID = editedPost.post_ID
            global.post[self.index!] = post
            self.createLocalNotification(notificationName: "reload", userInfo: [:])
            if andDismiss {
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            
            getCreatePostUniqueID(param: post) { (postValue, error) in
                global.post.append(postValue)
                self.createLocalNotification(notificationName: "reload", userInfo: [:])
                if andDismiss {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }
    }
    //    @IBAction override func addLeftAction(sender: UIBarButtonItem) {
    //		SaveThisPost(andDismiss: true)
    //	}
	
	override func willMove(toParent parent: UIViewController?) {
		super.willMove(toParent: parent)
		if parent == nil {
            
            if canSaveIncomplete(){
            if buttonClickTag == 0{
			//SaveThisPost(andDismiss: false)
            }
            }else{
                
            }
		}
	}
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: noHate, duration: 2, options: .transitionCrossDissolve, animations: {
            self.noHate.textColor = GetForeColor()
        }, completion: nil)
        if let nc = self.navigationController as? StandardNC {
            nc.tempDelegate = self
        }
    }
    
}
