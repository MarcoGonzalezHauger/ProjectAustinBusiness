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

class AddOfferVC: BaseVC,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,PickerDelegate,selectedCategoryDelegate {
    
    
    
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
        self.setBasicComponents()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProduct(notification:)), name: Notification.Name.init(rawValue: "reload"), object: nil)
        let picker = self.addPickerToolBar(textField: gender, object: ["Male","Female","Other","All"])
        picker.pickerDelegate = self

        //self.setInputField()
        self.tableViewHeight.constant = 80
        self.postTableView.updateConstraints()
        self.postTableView.layoutIfNeeded()
        

        
        self.fillEditedInfo()
    }
    
    func fillEditedInfo() {
        
        if segueOffer != nil {
            
            self.offerName.text = segueOffer?.title
            //self.offerRate.text = "$" + String(segueOffer!.money)
//            self.expiryDate.text = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: segueOffer!.expiredate, format: "yyyy/MMM/dd HH:mm:ss")
            self.zipCode.text = segueOffer?.zipCodes.joined(separator: ",")
            self.gender.text = segueOffer?.genders.joined(separator: ",")
            selectedCategoryArray.append(contentsOf: segueOffer!.category)
            let selectedCategory  = segueOffer?.category.joined(separator: ",")
            self.selectedCategoryText.text = selectedCategory
            
            global.post.removeAll()
            global.post.append(contentsOf: segueOffer!.posts)
            let count = global.post.count
            if count < 3 {
                self.tableViewHeight.constant = (CGFloat(80 * count) + 80)
                self.postTableView.updateConstraints()
                self.postTableView.layoutIfNeeded()
                self.postTableView.reloadData()
            }else{
                self.tableViewHeight.constant = (CGFloat(global.post.count) * 80)
                self.postTableView.updateConstraints()
                self.postTableView.layoutIfNeeded()
                self.postTableView.reloadData()
            }
        }
        
    }
    
    @objc func reloadProduct(notification: Notification) {
        
        let count = global.post.count
        if count < 3 {
        self.tableViewHeight.constant = (CGFloat(80 * count) + 80)
        self.postTableView.updateConstraints()
        self.postTableView.layoutIfNeeded()
        self.postTableView.reloadData()
        }else{
        self.tableViewHeight.constant = (CGFloat(global.post.count) * 80)
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
            
            let post = global.post[(indexPath.row - 1)]
            cell?.postTitle.text = post.PostType
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 80.0
    }
    
//    //MARK: - Collectionview Delegates
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int{
//        if collectionView == pickedInfluencer{
//        return  1
//        }else{
//        return  1
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == pickedInfluencer{
//            return  pickedUserArray.count
//        }else{
//        return global.influencers.count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView == pickedInfluencer{
//            let cell : PickUserCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "pickuser", for: indexPath) as! PickUserCVC
//            let user = pickedUserArray[indexPath.item]
//            let url = URL.init(string: user.profilePicURL!)
//            cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProduct"))
//            cell.pickText.text = user.name!
//            return cell
//        }else{
//        let cell : PickUserCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "influencer", for: indexPath) as! PickUserCVC
//        let user = global.influencers[indexPath.item]
//        let url = URL.init(string: user.profilePicURL!)
//        cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProduct"))
//        cell.pickText.text = user.name!
//        return cell
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
//
//        if collectionView == pickedInfluencer{
//
//            let obj = pickedUserArray[indexPath.item]
//            global.influencers.append(obj)
//            pickedUserArray.remove(at: indexPath.item)
//            let count = (Float(global.influencers.count) / 3.0).rounded(.up)
//            self.influencerHeight.constant = CGFloat(95 * count)
//            self.influencerCollection.updateConstraints()
//            self.influencerCollection.layoutIfNeeded()
//            self.influencerCollection.reloadData()
//
//            let countPicked = (Float(self.pickedUserArray.count) / 3.0).rounded(.up)
//            self.pickedInfluencerHeight.constant = CGFloat(90 * countPicked)
//            self.pickedInfluencer.updateConstraints()
//            self.pickedInfluencer.layoutIfNeeded()
//            self.pickedInfluencer.reloadData()
//
//            if pickedUserArray.count == 0 {
//            self.pickedIT.constant = 0.0
//            self.pickedText.updateConstraints()
//            self.pickedText.layoutIfNeeded()
//
//            }
//        }else{
//
//            let obj = global.influencers[indexPath.item]
//            self.pickedUserArray.append(obj)
//            global.influencers.remove(at: indexPath.item)
//            let count = (Float(global.influencers.count) / 3.0).rounded(.up)
//            self.influencerHeight.constant = CGFloat(95 * count)
//            self.influencerCollection.updateConstraints()
//            self.influencerCollection.layoutIfNeeded()
//            self.influencerCollection.reloadData()
//
//            let countPicked = (Float(self.pickedUserArray.count) / 3.0).rounded(.up)
//            self.pickedInfluencerHeight.constant = CGFloat(90 * countPicked)
//            self.pickedInfluencer.updateConstraints()
//            self.pickedInfluencer.layoutIfNeeded()
//            self.pickedInfluencer.reloadData()
//
//            self.pickedIT.constant = 17.0
//            self.pickedText.updateConstraints()
//            self.pickedText.layoutIfNeeded()
//        }
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == pickedInfluencer{
//
//        let Width = collectionView.bounds.width/3.0
//        _ = Width
//        return CGSize(width: Width - 3, height: 90)
//
//        }else{
//
//        let Width = collectionView.bounds.width/3.0
//        _ = Width
//        return CGSize(width: Width - 4, height: 90)
//
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//
//        return 2.0
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 2.0
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
//        return UIEdgeInsets(top: 2,left: 2,bottom: 2,right: 2);
//    }
    
    //MARK: - Data Components
    
    func setBasicComponents() {
        self.customizeNavigationBar()
        self.textFieldChangeNotification(textField: self.zipCode)
        //self.addDoneButtonOnKeyboard(textField: self.offerRate)
        self.addDoneButtonOnKeyboard(textField: self.zipCode)
        //self.customizeNavigationBar()
        self.addRightButtonText(text: "Save")
        self.customizeNavigationBar()
    }
    
//    func setInputField() {
//        let newDateComponents = NSDateComponents()
//        newDateComponents.month = 1
//        newDateComponents.day = 0
//        newDateComponents.year = 0
//        dobPickerView.minimumDate = Date()
//        dobPickerView.maximumDate = NSCalendar.current.date(byAdding: newDateComponents as DateComponents, to: NSDate() as Date)
//
//        dobPickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
//
//        self.expiryDate.inputView = dobPickerView
//        dobPickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
//        self.addDoneButtonOnKeyboard(textField: expiryDate)
//    }
    
//    @objc func datePickerValueChanged(sender:UIDatePicker) {
//
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateStyle = DateFormatter.Style.medium
//
//        dateFormatter.timeStyle = DateFormatter.Style.none
//        // NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"EN"];
//        let locale = NSLocale.init(localeIdentifier: "en_US")
//        print(locale)
//        //"MM/dd/YYYY HH:mm:ss",yyyy/MMM/dd HH:mm:ss
//        //dateFormatter.dateFormat = "dd/MM/YYYY"
//        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ss"
//        //        dateFormatter.dateFormat = "mm/dd/yyyy HH:mm:ss"
//        dateFormatter.locale = Locale.current
//        expiryDate.text = dateFormatter.string(from: sender.date)
//
//
//    }
    
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
        
//        UIApplication.shared.open(URL.init(string: "https://amassadoor.firebaseapp.com")!, options: [:], completionHandler: nil)
//        UIApplication.shared.open(URL.init(string: "http://localhost:5000/pay")!, options: [:], completionHandler: nil)
        
//        var influencerFilter = ["primaryCategory":["Other"],"followerCount":[845]]
//
//
//
        if self.offerName.text?.count != 0{

            //if self.offerRate.text?.count != 0{

//            if self.expiryDate.text?.count != 0{

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
//
                                //DateFormatManager.sharedInstance.getDateFromStringWithFormat(dateString: self.expiryDate.text!, format: "yyyy/MMM/dd HH:mm:ss")
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

                                //}


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

//            }
//            else{
//                self.showAlertMessage(title: "Alert", message: "Enter the expiry date"){
//
//                }
//            }

            //                }else{
            //
            //                    self.showAlertMessage(title: "Alert", message: "Enter the offer rate") {
            //                    }
            //                }

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
//        if gender.text!.count != 0 {
//            if (gender.text?.contains("All"))!{
//
//                let stringCount = self.genderPicker.components(separatedBy: ",")
//
//                if stringCount.count == 0 {
//
//                    gender.text = self.genderPicker
//
//                }else{
//
//                    var stringSepArray = stringCount
//
//                    for value in stringCount {
//                        if value == "All" {
//
//                            if let index = stringSepArray.firstIndex(of: "All") {
//                                stringSepArray.remove(at: index)
//                            }
//
//                        }
//                    }
//
//                    gender.text = stringSepArray.joined(separator: ",")
//
//                }
//
//            }else{
//
//                if self.genderPicker == "All" {
//                    gender.text = "All"
//                }else{
//                    let stringCount = self.genderPicker.components(separatedBy: ",")
//                    if stringCount.count == 0 {
//                        gender.text = self.genderPicker
//                    }else{
//                        gender.text = gender.text! + "," + self.genderPicker
//                    }
//                }
//
//        }
//        }else{
//            gender.text = self.genderPicker
//        }
        
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
//        else if textField == self.offerRate {
//            if string == "" {
//                if self.offerRate.text!.count == 2 {
//                   self.offerRate.text = ""
//                }
//
//            }else{
//                if (self.offerRate.text?.first == "$"){
//                //self.offerRate.text = self.offerRate.text!
//                }else{
//                  self.offerRate.text = "$" + self.offerRate.text!
//                }
//
//            }
//            return true
//
//        }
        else{
          return true
        }
        
        
    }
    
    @IBAction func addTabGestureAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toCategoryTVC", sender: self)
        
    }
    
    func selectedArray(array: [String]) {
        if array.count != 0 {
            selectedCategoryArray.removeAll()
            selectedCategoryArray.append(contentsOf: array)
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
                            
                            var offer = ["offer_ID":"","money":0.0,"company":Singleton.sharedInstance.getCompanyDetails(),"posts":global.post,"offerdate":Date(),"user_ID":[],"expiredate":expiryDate,"allPostsConfirmedSince":nil,"allConfirmed":false,"isAccepted":false,"isExpired":false,"ownerUserID":Auth.auth().currentUser!.uid,"category":self.selectedCategoryArray,"zipCodes":self.zipCode.text!.components(separatedBy: ","),"genders":genderArray,"title":self.offerName.text!,"targetCategories":[Category.Actor],"user_IDs":[],"status":"available"] as [String : AnyObject]
                            
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
			let backItem = UIBarButtonItem()
			backItem.title = "Back"
			navigationItem.backBarButtonItem = backItem
        }else if segue.identifier == "toAddPost" {
            let view = segue.destination as! AddPostVC
            view.index = sender as? Int
			let backItem = UIBarButtonItem()
			backItem.title = "Don't Save"
			navigationItem.backBarButtonItem = backItem
        }else if segue.identifier == "toDistributeOffer" {
            let view = segue.destination as! DistributeOfferVC
            view.templateOffer = sender as! TemplateOffer
			let backItem = UIBarButtonItem()
			backItem.title = "Back"
			navigationItem.backBarButtonItem = backItem
        }
    }
    

}
