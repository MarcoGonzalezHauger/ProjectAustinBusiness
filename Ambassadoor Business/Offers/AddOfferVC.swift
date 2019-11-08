//
//  AddOfferVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth

class AddOfferVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, PickerDelegate, selectedCategoryDelegate {
    
    
    
    @IBOutlet weak var postTableView: UITableView!
    //@IBOutlet weak var expiryDate: UITextField!
    //@IBOutlet weak var influencerCollection: UICollectionView!
    //@IBOutlet weak var pickedInfluencer: UICollectionView!
    @IBOutlet weak var scroll: UIScrollView!
    //@IBOutlet weak var pickedText: UILabel!
    @IBOutlet weak var offerName: UITextField!
    //@IBOutlet weak var offerRate: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var selectedCategoryText: UILabel!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet var tabCategory: UITapGestureRecognizer!
    var dobPickerView:UIDatePicker = UIDatePicker()
    var pickedUserArray = [User]()
    var genderPicker: String = ""
    
    var selectedCategoryArray = [String]()
    var segueOffer: TemplateOffer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProduct(notification:)), name: Notification.Name.init(rawValue: "reload"), object: nil)
        let picker = self.addPickerToolBar(textField: gender, object: ["Male","Female","Other","All"])
        picker.pickerDelegate = self

        //self.setInputField()
        self.tableViewHeight.constant = 80
        self.postTableView.updateConstraints()
        self.postTableView.layoutIfNeeded()
        
        self.setBasicComponents()
        
        self.fillEditedInfo()
    }
    
    func fillEditedInfo() {
        
        if segueOffer != nil {
            
            self.offerName.text = segueOffer?.title
            //self.offerRate.text = "$" + String(segueOffer!.money)
//            self.expiryDate.text = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: segueOffer!.expiredate, format: "yyyy/MMM/dd HH:mm:ss")
            self.zipCode.text = segueOffer?.zipCodes.joined(separator: ",")
            self.gender.text = segueOffer?.genders.joined(separator: ", ")
            
            setCategoryLabels()
			
            global.post = segueOffer!.posts
			reloadTableViewHeight()
        }
        
    }
	
	func setCategoryLabels() {
		selectedCategoryArray.append(contentsOf: segueOffer!.category)
		var cats = segueOffer?.category
		cats?.sort { $0 > $1 }
		let selectedCategory  = cats?.joined(separator: ", ")
		self.selectedCategoryText.text = selectedCategory
	}
	
	let postCellHeight: Int = 90
	let addCellHeight: CGFloat = 60
    
	@objc func reloadProduct(notification: Notification) {
		reloadTableViewHeight()
	}
	
	func reloadTableViewHeight() {
		let count = global.post.count
		if count < 3 {
			self.tableViewHeight.constant = CGFloat(postCellHeight * count) + addCellHeight
			self.postTableView.updateConstraints()
			self.postTableView.layoutIfNeeded()
			self.postTableView.reloadData()
		}else{
			self.tableViewHeight.constant = CGFloat(global.post.count * postCellHeight)
			self.postTableView.updateConstraints()
			self.postTableView.layoutIfNeeded()
			self.postTableView.reloadData()
		}
	}
	
	
	
	//MARK: -Table Delegates
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if global.post.count < 3 {
			return global.post.count + 1
        }else{
			return global.post.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if global.post.count < 3 {
        if indexPath.row == 0 {
        let cellIdentifier = "addpost"
        var cell = self.postTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AddPostTC
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("AddPostTC", owner: self, options: nil)
            cell = nib![0] as? AddPostTC
        }
        return cell!
        }else{
            
            let cellIdentifier = "productdetail"
            var cell = self.postTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PostDetailTC
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("PostDetailTC", owner: self, options: nil)
                cell = nib![0] as? PostDetailTC
            }
            
			cell?.SetNumber(number: indexPath.row)
            //cell?.postTitle.text = PostTypeToText(posttype: post.PostType)
            return cell!
        }
        }else {
            
            let cellIdentifier = "productdetail"
            var cell = self.postTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PostDetailTC
            if cell == nil {
                let nib = Bundle.main.loadNibNamed("PostDetailTC", owner: self, options: nil)
                cell = nib![0] as? PostDetailTC
            }
            let post = global.post[indexPath.row]
            cell?.postTitle.text = post.PostType
            //cell?.postTitle.text = PostTypeToText(posttype: post.PostType)
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if global.post.count < 3 {
            
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "toAddPost", sender: nil)
                
            }else{
                let index = indexPath.row - 1
                self.performSegue(withIdentifier: "toAddPost", sender: index)
            }
            
        }else{
            self.performSegue(withIdentifier: "toAddPost", sender: indexPath.row)
        }
        
        
    }
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		switch textField {
		case gender:
			return false
		case zipCode:
			performSegue(withIdentifier: "toZipPicker", sender: self)
			return false
		default:
			return true
		}
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		if indexPath.row == 0 {
			return addCellHeight
		} else {
			return CGFloat(postCellHeight)
		}
    }
    
    //MARK: - Data Components
    
    func setBasicComponents() {
        self.textFieldChangeNotification(textField: self.zipCode)
        self.addDoneButtonOnKeyboard(textField: self.zipCode)
        self.addRightButtonText(text: "Save")
        self.customizeNavigationBar()
    }
    
    //MARK: -Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scroll.contentInset = contentInset
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    @objc override func doneButtonAction() {
        //self.expiryDate.resignFirstResponder()
        //self.offerRate.resignFirstResponder()
        self.zipCode.resignFirstResponder()
    }
    
    @IBAction func saveOffer(sender: UIButton){
        if self.offerName.text?.count != 0{
                if self.zipCode.text?.count != 0{
                    if self.zipCode.text!.components(separatedBy: ",").last?.count == 5 {
                        if self.gender.text?.count != 0 {
                            if self.selectedCategoryArray.count != 0 {
                                let timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.timerAction(sender:)), userInfo: nil, repeats: false)
                                var genderArray = [String]()
                                
                                if (self.gender.text?.contains("All"))!{
                                    genderArray.append(contentsOf: ["Male","Female","Other"])
                                }else{
                                    genderArray = self.gender.text!.components(separatedBy: ",")
                                }
								
                                let expiryDateAdded = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                                let dateString = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: expiryDateAdded, format: "yyyy-MM-dd'T'HH:mm:ss")
                                
                                let expiryDate = DateFormatManager.sharedInstance.getExpiryDate(dateString: dateString)
                                
                                var offer = ["offer_ID":"","money":0.0,"company":Singleton.sharedInstance.getCompanyDetails(),"posts":global.post,"offerdate":Date(),"user_ID":[],"expiredate":expiryDate,"allPostsConfirmedSince":nil,"allConfirmed":false,"isAccepted":false,"isExpired":false,"ownerUserID":Auth.auth().currentUser!.uid,"category":self.selectedCategoryArray,"zipCodes":self.zipCode.text!.components(separatedBy: ","),"genders":genderArray,"title":self.offerName.text!,"targetCategories":["Other"],"user_IDs":[],"status":"available"] as [String : AnyObject]
                                
                                if segueOffer != nil {
                                    
                                    offer["user_IDs"] = segueOffer?.user_IDs as AnyObject?
                                            
                                }
                                
                                let template = TemplateOffer.init(dictionary: offer)
                                var edited = false
                                var path = Auth.auth().currentUser!.uid

                                if self.segueOffer != nil {
                                    edited = true
                                    path = path + "/" + self.segueOffer!.offer_ID
                                    template.offer_ID = self.segueOffer!.offer_ID
                                }
								
                                createTemplateOffer(pathString: path, edited: edited, templateOffer: template) { (offer, response) in
                                    timer.invalidate()
                                    self.hideActivityIndicator()
                                    self.segueOffer = template
                                    self.performSegue(withIdentifier: "toDistributeOffer", sender: offer)
                                }
								
                            } else {
                                self.showAlertMessage(title: "Alert", message: "Please Choose prefered categories"){ }
                            }
                        }else{
                            self.showAlertMessage(title: "Alert", message: "Please Choose genders to filter prefered influencers"){ }
                        }
                    }else{
                        self.showAlertMessage(title: "Alert", message: "Enter the valid Zipcode"){ }
                    }
                }else{
                    self.showAlertMessage(title: "Alert", message: "Enter the expiry date"){ }
                }
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter your offer name") {
            }
        }
        
    }
    
    //MARK: -Picker Delagate
    
    func PickerValue(value: String) {
        self.genderPicker = value
        self.gender.text = value
    }
    
    @objc override func doneClickPicker() {
        self.gender.resignFirstResponder()
    }
    
    @objc override func cancelClickPicker() {
        self.gender.resignFirstResponder()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        if textField == self.zipCode {
            
            let component = self.zipCode.text!.components(separatedBy: ",")
            
                if component.last!.count >= 5 && string != "," {
                    if string == "" {
                    return true
                    }else{
                    self.zipCode.text = self.zipCode.text! + ","
                    return true
                        
                    }
                }else if component.last!.count < 5 {
                    if string != "," {
                        return true
                    }else{
                        return false
                    }
                }else {
                    return true
                }

           
        }
        else{
          return true
        }
        
        
    }
    
    @IBAction func addTabGestureAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toCategoryTVC", sender: self)
        
    }
    
    func selectedArray(array: [String]) {
        if array.count != 0 {
            selectedCategoryArray = array
            let selectedCategory  = array.joined(separator: ", ")
            self.selectedCategoryText.text = selectedCategory
        }else{
            selectedCategoryArray.removeAll()
            self.selectedCategoryText.text = ""
        }
    }
    
    @objc func timerAction(sender: AnyObject){
        self.showActivityIndicator()
    }
    
    @IBAction override func addRightAction(sender: UIBarButtonItem) {
        
        
        
        
        if self.offerName.text?.count != 0{
            
            
            if self.zipCode.text?.count != 0{
                
                if self.zipCode.text!.components(separatedBy: ",").last?.count == 5 {
                    
                    if self.gender.text?.count != 0 {
                        
                        if self.selectedCategoryArray.count != 0 {
                            let timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.timerAction(sender:)), userInfo: nil, repeats: false)
                            //                            getFilteredInfluencers(category: influencerFilter as [String : [AnyObject]]) { (influencer, errorStatus) in
                            
                            var genderArray = [String]()
                            
                            if (self.gender.text?.contains("All"))!{
                                
                                genderArray.append(contentsOf: ["Male","Female","Other"])
                                
                            }else{
                                genderArray = self.gender.text!.components(separatedBy: ",")
                            }
                            
                            let expiryDateAdded = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                            let dateString = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: expiryDateAdded, format: "yyyy-MM-dd'T'HH:mm:ss")
                            
                            let expiryDate = DateFormatManager.sharedInstance.getExpiryDate(dateString: dateString)
                            
                            var offer = ["offer_ID":"","money":0.0,"company":Singleton.sharedInstance.getCompanyDetails(),"posts":global.post,"offerdate":Date(),"user_ID":[],"expiredate":expiryDate,"allPostsConfirmedSince":nil,"allConfirmed":false,"isAccepted":false,"isExpired":false,"ownerUserID":Auth.auth().currentUser!.uid,"category":self.selectedCategoryArray,"zipCodes":self.zipCode.text!.components(separatedBy: ","),"genders":genderArray,"title":self.offerName.text!,"targetCategories":["Other"],"user_IDs":[],"status":"available"] as [String : AnyObject]
                            
                            if segueOffer != nil {
                                
                                offer["user_IDs"] = segueOffer?.user_IDs as AnyObject?
                                
                            }
                            
                            let template = TemplateOffer.init(dictionary: offer)
                            var edited = false
                            var path = Auth.auth().currentUser!.uid
                            
                            if self.segueOffer != nil {
                                edited = true
                                path = path + "/" + self.segueOffer!.offer_ID
                                template.offer_ID = self.segueOffer!.offer_ID
                            }
                            
                            createTemplateOffer(pathString: path, edited: edited, templateOffer: template) { (offer, response) in
                                timer.invalidate()
                                self.hideActivityIndicator()
                                self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
                                global.post.removeAll()
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            
                        }else{
                            self.showAlertMessage(title: "Alert", message: "Please Choose prefered categories"){
                                
                            }
                        }
                        
                    }else{
                        
                        self.showAlertMessage(title: "Alert", message: "Please Choose genders to filter prefered influencers"){
                            
                        }
                        
                    }
                    
                }else{
                    self.showAlertMessage(title: "Alert", message: "Enter the valid Zipcode"){
                        
                    }
                }
                
            }else{
                self.showAlertMessage(title: "Alert", message: "Enter the expiry date"){
                    
                }
            }
            
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter your offer name") {
            }
        }
        
        
        
        
        
        
}
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCategoryTVC"{
            let view = segue.destination as! CategoryTVC
            view.selectedValues = selectedCategoryArray
            view.delegateCategory = self
        }else if segue.identifier == "toAddPost" {
            let view = segue.destination as! AddPostVC
            view.index = sender as? Int
        }else if segue.identifier == "toDistributeOffer" {
            let view = segue.destination as! DistributeOfferVC
            view.templateOffer = sender as! TemplateOffer
            
        }
    }
    

}
