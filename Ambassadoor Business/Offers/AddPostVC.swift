//
//  AddPostVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 31/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class AddPostVC: BaseVC,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var desPost: UITextView!
    @IBOutlet weak var hashPost: UITextField!
    @IBOutlet weak var pharsePost: UITextField!
    //@IBOutlet weak var category: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    
    var postType: TypeofPost?
    var productCollection = [Product]()
    
    var index: Int?
    var productSelectedArray = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customizeNavigationBar()
        self.addLeftButtonText(text: "⬅︎ Back")
        if index != nil {
            let post = global.post[index!]
            self.desPost.text = post.instructions
            self.hashPost.text = post.hashCaption
            self.pharsePost.text = post.captionMustInclude
        }
        
        self.addDoneButtonOnKeyboard(textView: desPost)
        let user = Singleton.sharedInstance.getCompanyUser()
        let path = Auth.auth().currentUser!.uid + "/" + user.companyID!
        if global.products.count == 0 {
        self.showActivityIndicator()
        getAllProducts(path: path) { (product) in
            if product != nil {
            self.hideActivityIndicator()
            global.products.append(contentsOf: product!)
            self.productTable.reloadData()
            if self.index != nil {
                let post = global.post[self.index!]
            for (index,value) in global.products.enumerated() {
                
                for productValue in post.products! {
                    
                    if value.product_ID == productValue.product_ID {
                        
                       self.productCollection.append(value)
                       self.productSelectedArray.append(index)
                    }
                    
                }
                
            }
            self.productTable.reloadData()
            }
            
            }else{
                self.hideActivityIndicator()
            }

        }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return global.products.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "productlist"
        var cell = self.productTable.dequeueReusableCell(withIdentifier: cellIdentifier) as? ProductListCell
        if cell == nil {
            let nib = Bundle.main.loadNibNamed("ProductListCell", owner: self, options: nil)
            cell = nib![0] as? ProductListCell
        }
        cell?.productName.text = global.products[indexPath.row].name == "" ? "(no name)" : global.products[indexPath.row].name
        let url = URL.init(string: global.products[indexPath.row].image!)
        cell?.productImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProduct"))
        if self.productSelectedArray.contains(indexPath.row){
            cell?.selectImage.image = UIImage(named: "selectcircle")
        }else{
            cell?.selectImage.image = UIImage(named: "deselectcircle")
        }
        return cell!
        
//        let cell = productTable.dequeueReusableCell(withIdentifier: "productCell") as! ProductCell
//        cell.productTitle.text = global.products[indexPath.row].name == "" ? "(no name)" : global.products[indexPath.row].name
//        let url = URL.init(string: global.products[indexPath.row].image!)
//        cell.productImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProduct"))
//        if self.productSelectedArray.contains(indexPath.row){
//            cell.accessoryType = .checkmark
//        }else{
//            cell.accessoryType = .none
//        }
//        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.productTable.cellForRow(at: indexPath) as! ProductListCell
        cell.selectImage.image = UIImage(named: "selectcircle")
        let product = global.products[indexPath.row]
        self.productCollection.append(product)
        self.productSelectedArray.append(indexPath.row)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let cell = self.productTable.cellForRow(at: indexPath) as! ProductListCell
        cell.selectImage.image = UIImage(named: "deselectcircle")
        self.productCollection.remove(at: indexPath.row)
        let value = self.productSelectedArray.index(of: indexPath.row)
        self.productSelectedArray.remove(at: value!)
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
        self.desPost.resignFirstResponder()
        //self.category.resignFirstResponder()
    }
    
    //MARK: - Data Components
    
   @IBAction func setActionSheet() {
        
//        let controller = UIAlertController.init(title: "", message: "Selet Post Type", preferredStyle: .actionSheet)
//        controller.addAction(UIAlertAction.init(title: PostTypeToText(posttype: .SinglePost), style: .default, handler: { (action) in
//
//            self.postType = .SinglePost
//            self.category.text = PostTypeToText(posttype: .SinglePost)
//
//        }))
//        controller.addAction(UIAlertAction.init(title: PostTypeToText(posttype: .MultiPost), style: .default, handler: { (action) in
//
//            self.postType = .MultiPost
//            self.category.text = PostTypeToText(posttype: .MultiPost)
//
//        }))
//        controller.addAction(UIAlertAction.init(title: PostTypeToText(posttype: .Story), style: .default, handler: { (action) in
//
//            self.postType = .Story
//            self.category.text = PostTypeToText(posttype: .Story)
//
//        }))
//
//        controller.addAction(UIAlertAction.init(title: "Cancel", style: .destructive, handler: { (action) in
//
//        }))
//
//        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    @IBAction func savePost(sender: UIButton){
        
        if desPost.text.count != 0 {
            
            
            if hashPost.text?.count != 0 {
                
                if pharsePost.text?.count != 0 {
                    
                    if productCollection.count != 0 {
                        
                            
                        let post  = Post.init(image: "", instructions: desPost.text!, captionMustInclude: self.pharsePost.text!, products: productCollection, post_ID: "", PostType: PostTypeToText(posttype: .SinglePost) , confirmedSince: Date(), isConfirmed: false, hashCaption: hashPost.text!, status: "available")
                            self.showActivityIndicator()
                            getCreatePostUniqueID(param: post) { (postValue, error) in
                                self.hideActivityIndicator()
                                if self.index != nil {
                                    global.post[self.index!] = postValue
                                }else{
                                 global.post.append(postValue)
                                }
                                
                                self.createLocalNotification(notificationName: "reload", userInfo: [:])
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        
                    }else{
                        
                    self.showAlertMessage(title: "Alert", message: "Please choose the product") {
                            
                        }
                    }
                    
                }else{
                    
                    self.showAlertMessage(title: "Alert", message: "Please enter some pharse to include in the caption of the post.") {
                        
                    }
                    
                }
                
            }else{
                self.showAlertMessage(title: "Alert", message: "Please enter the hashtag to include in the caption of the post.") {
                    
                }
            }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter some description about your post") {
                
            }
        }
        
    }
    
    @IBAction override func addLeftAction(sender: UIBarButtonItem) {
        
        if desPost.text.count != 0 {
            
            
            if hashPost.text?.count != 0 {
                
                if pharsePost.text?.count != 0 {
                    
                    if productCollection.count != 0 {
                        
                            
                        let post  = Post.init(image: "", instructions: desPost.text!, captionMustInclude: self.pharsePost.text!, products: productCollection, post_ID: "", PostType: PostTypeToText(posttype: .SinglePost) , confirmedSince: Date(), isConfirmed: false, hashCaption: hashPost.text!, status: "available")
                            self.showActivityIndicator()
                            getCreatePostUniqueID(param: post) { (postValue, error) in
                                self.hideActivityIndicator()
                                if self.index != nil {
                                    global.post[self.index!] = postValue
                                }else{
                                 global.post.append(postValue)
                                }
                                
                                self.createLocalNotification(notificationName: "reload", userInfo: [:])
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        
                    }else{
                        
                    self.showAlertMessage(title: "Alert", message: "Please choose the product") {
                            
                        }
                    }
                    
                }else{
                    
                    self.showAlertMessage(title: "Alert", message: "Please enter some pharse to include in the caption of the post.") {
                        
                    }
                    
                }
                
            }else{
                self.showAlertMessage(title: "Alert", message: "Please enter the hashtag to include in the caption of the post.") {
                    
                }
            }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter some description about your post") {
                
            }
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
