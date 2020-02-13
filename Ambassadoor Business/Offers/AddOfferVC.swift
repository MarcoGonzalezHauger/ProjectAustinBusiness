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

class AddOfferVC: BaseVC, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, PickerDelegate, selectedCategoryDelegate, NCDelegate, LocationFilterDelegate {
	
	func LocationFilterChosen(filter: String) {
		locationFilter = filter
	}

	func shouldAllowBack() -> Bool {
		SaveThisOffer() {_,_ in }
		return true
	}
    
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
    
	@IBOutlet weak var saveandSendView: ShadowView!
	@IBOutlet weak var editButton: UIButton!
	@IBOutlet weak var locationInfo: UILabel!
	
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet var tabCategory: UITapGestureRecognizer!
    var dobPickerView:UIDatePicker = UIDatePicker()
    var pickedUserArray = [User]()
    var genderPicker: String = ""
    
    var selectedCategoryArray = [String]()
    var segueOffer: TemplateOffer?
    var isEdit = false
	var locationFilter = "" {
		didSet {
			let codes = TitleAndTagLineforLocationFilter(filter: locationFilter)
			zipCode.text = codes[0]
			locationInfo.text = codes[1]
		}
	}
    
	override func viewDidAppear(_ animated: Bool) {
		if let nc = self.navigationController as? StandardNC {
			nc.tempDelegate = self
		}
	}
	
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
        
        if let segueOffer = segueOffer {
            
            self.offerName.text = segueOffer.title
			locationFilter = segueOffer.locationFilter
			if segueOffer.genders.count > 1 {
				self.gender.text = "All"
			} else {
				self.gender.text = segueOffer.genders.joined(separator: ", ")
			}
            
            setCategoryLabels()
			
            global.post = segueOffer.posts
			reloadTableViewHeight()
		} else {
			locationFilter = "nw"
			self.gender.text = "All"
			setCategoryLabels()
			global.post = []
			reloadTableViewHeight()
		}
        
    }
	
	//used to set the textifield text and the label below it on location fitler information.
	func TitleAndTagLineforLocationFilter(filter: String) -> [String] {
		switch filter.components(separatedBy: ":")[0] {
		case "nw":
			return ["Nationwide", "Offer will be sent to influencers in the USA."]
		case "states":
			let stateList = GetListOfStates()
			let data = locationFilter.components(separatedBy: ":")[1]
			var returnData: [String] = []
			for stateName in data.components(separatedBy: ",") {
				returnData.append(stateList.filter { (state1) -> Bool in
					return state1.shortName == stateName
					}[0].name)
			}
			return ["Filtered by State", "This offer will be sent to influencers in " + returnData.joined(separator: ", ") + "."]
		case "radius":
			let data1 = locationFilter.components(separatedBy: ":")[1]
			var returnData: [String] = []
			if data1.components(separatedBy: ",").count == 1 {
				let zip = data1.components(separatedBy: "-")[0]
				let radius = Int(data1.components(separatedBy: "-")[1]) ?? 0
				return ["Filtered by Radius", "This offer will be sent to influencers in a \(radius) mile radius around \(zip)." + returnData.joined(separator: ", or\n")]
			}
			for data in data1.components(separatedBy: ",") {
				let zip = data.components(separatedBy: "-")[0]
				let radius = Int(data.components(separatedBy: "-")[1]) ?? 0
				returnData.append("A \(radius) mile radius around \(zip)")
			}
			return ["Filtered by Radii", "This offer will be sent to influencers in...\n" + returnData.joined(separator: ", or\n") + "."]
		default:
			return ["", ""]
		}
	}
	
	func setCategoryLabels() {
		if let segueOffer = segueOffer {
			selectedCategoryArray.append(contentsOf: segueOffer.category)
			var cats = segueOffer.category
			cats.sort { $0 > $1 }
			let selectedCategory  = cats.joined(separator: ", ")
			self.selectedCategoryText.text = selectedCategory
		} else {
			self.selectedCategoryText.text = "Choose Categories"
		}
		
	}
	
	let postCellHeight: Int = 90
	let addCellHeight: CGFloat = 60
    
	@objc func reloadProduct(notification: Notification) {
		print("Post edited.")
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
        if global.post.count == 3 {
			return 3
        }else{
			return global.post.count + 1
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
				let post = global.post[indexPath.row - 1]
				cell?.SetCell(number: indexPath.row , hash: post.GetSummary(maxItems: 5), incomplete: post.isFinished() != [])
				return cell!
			}
		} else {
			
			let cellIdentifier = "productdetail"
			var cell = self.postTableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PostDetailTC
			if cell == nil {
				let nib = Bundle.main.loadNibNamed("PostDetailTC", owner: self, options: nil)
				cell = nib![0] as? PostDetailTC
			}
			let post = global.post[indexPath.row]
			cell?.postTitle.text = post.PostType
			cell?.SetCell(number: indexPath.row + 1, hash: post.GetSummary(maxItems: 5), incomplete: post.isFinished() != [])
			//cell?.postTitle.text = PostTypeToText(posttype: post.PostType)
			return cell!
			
		}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if global.post.count == 3 {
			self.performSegue(withIdentifier: "toAddPost", sender: indexPath.row)
        }else{
			if indexPath.row == 0 {
                self.performSegue(withIdentifier: "toAddPost", sender: nil)
            }else{
                self.performSegue(withIdentifier: "toAddPost", sender: indexPath.row - 1)
            }
        }
		postTableView.deselectRow(at: indexPath, animated: false)
        
    }
	
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		switch textField {
		case gender:
			return true
		case zipCode:
			performSegue(withIdentifier: "toZipPicker", sender: self)
			return false
		default:
			return true
		}
	}
    
    @IBAction func editProducts(_ sender: Any) {
        isEdit = !isEdit
		self.editButton.setTitle(self.isEdit ? "Done" : "Edit", for: .normal)
        postTableView.setEditing(isEdit, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if global.post.count == 3 ? true : indexPath.row != 0 {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if global.post.count == 3 {
				global.post.remove(at: indexPath.row)
				if let rows = postTableView.indexPathsForVisibleRows {
					postTableView.reloadRows(at: rows, with: .fade)
				}
			} else {
				global.post.remove(at: indexPath.row - 1)
				postTableView.deleteRows(at: [indexPath], with: .right)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					if let rows = self.postTableView.indexPathsForVisibleRows {
						self.postTableView.reloadRows(at: rows, with: .fade)
					}
				}
			}
            
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return global.post.count == 3 ? true : indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return global.post.count == 3 ? true : indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		if global.post.count == 3 {
			return CGFloat(postCellHeight)
		} else {
			if indexPath.row == 0 {
				return addCellHeight
			} else {
				return CGFloat(postCellHeight)
			}
		}
    }
    
    //MARK: - Data Components
    
    func setBasicComponents() {
        self.addLeftButtonText(text: "Back")
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
        self.zipCode.resignFirstResponder()
    }
    
    @IBAction func saveOffer(sender: UIButton){
		if isSavable(alertUser: true) {
			SaveThisOffer { (template, bool1) in
				self.segueOffer = template
				self.performSegue(withIdentifier: "toDistributeOffer", sender: template)
			}
		} else {
			YouShallNotPass(SaveButtonView: saveandSendView)
		}
    }
	
	func SaveThisOffer(completion: @escaping (TemplateOffer, Bool) -> ()) {
		var genderArray = [String]()
		
		if (self.gender.text?.contains("All"))!{
			genderArray.append(contentsOf: ["Male","Female","Other"])
		}else{
			genderArray = self.gender.text!.components(separatedBy: ",")
		}
		
		let expiryDateAdded = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
		let dateString = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: expiryDateAdded, format: "yyyy-MM-dd'T'HH:mm:ss")
		
		let expiryDate = DateFormatManager.sharedInstance.getExpiryDate(dateString: dateString)
		
        var offer = ["offer_ID":"","money":0.0,"commission":0.0,"isCommissionPaid": false,"company":Singleton.sharedInstance.getCompanyDetails(),"posts":global.post,"offerdate":Date(),"user_ID":[],"expiredate":expiryDate,"allPostsConfirmedSince":nil,"allConfirmed":false,"isAccepted":false,"isExpired":false,"ownerUserID":Auth.auth().currentUser!.uid,"category":self.selectedCategoryArray,"locationFilter":locationFilter,"genders":genderArray,"title":self.offerName.text!,"targetCategories":["Other"],"user_IDs":[],"status":"available", "lastEditDate": DateToFirebase(date: Date()),"isAllPaid":false,"isRefferedByInfluencer":false,"isReferCommissionPaid":false,"referralAmount":0.0,"referralID":""] as [String : AnyObject]
        
        //self.isRefferedByInfluencer = dictionary["isRefferedByInfluencer"] as? Bool ?? false
        //self.isReferCommissionPaid = dictionary["isReferCommissionPaid"] as? Bool ?? false
        //self.referralAmount = dictionary["referralAmount"] as? Double ?? 0.0
		
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
		
		createTemplateOffer(pathString: path, edited: edited, templateOffer: template, completion: completion)
	}
	
	func isSavable(alertUser: Bool) -> Bool {
		if !alertUser {
			return self.offerName.text?.count != 0 && locationFilter != "" && locationFilter != "" && self.gender.text?.count != 0 && self.selectedCategoryArray.count != 0
		}
		if self.offerName.text?.count != 0 {
			if locationFilter != "" {
				if self.gender.text?.count != 0 {
					if self.selectedCategoryArray.count != 0 {
						var postsNotOkay = 0
						for p in global.post {
							if p.isFinished() != [] {
								postsNotOkay += 1
							}
						}
						if postsNotOkay > 0 {
							self.showAlertMessage(title: "Alert", message: "Posts are not complete."){ }
						} else {
							if global.post.count == 0 {
								self.showAlertMessage(title: "Alert", message: "You don't have any posts."){ }
							} else {
								return true
							}
						}
					} else {
						self.showAlertMessage(title: "Alert", message: "Please Choose prefered categories"){ }
					}
				}else{
					self.showAlertMessage(title: "Alert", message: "Please Choose genders to filter prefered influencers"){ }
				}
			}else{
				self.showAlertMessage(title: "Alert", message: "Set desired location."){ }
			}
		}else{
			self.showAlertMessage(title: "Alert", message: "Please enter your offer name") {
			}
		}
		return false
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
	
	@IBAction override func addLeftAction(sender: UIBarButtonItem) {
		SaveThisOffer { (template, bool1) in
			self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
				global.post.removeAll()
            self.navigationController?.setNavigationBarHidden(true, animated: false)
			self.navigationController?.popViewController(animated: true)
		}
	}
	
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
			view.templateOffer = sender as? TemplateOffer
            
		} else if segue.identifier == "toZipPicker" {
			let view = segue.destination as! LocationPicker
			view.locationString = locationFilter
			view.locationDelegate = self
		}
    }
    

}
