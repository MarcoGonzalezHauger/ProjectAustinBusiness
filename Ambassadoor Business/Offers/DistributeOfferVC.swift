//
//  DistributeOfferVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 12/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class IncreasePay: UICollectionViewCell {
    @IBOutlet weak var payText: UILabel!
}

class DistributeOfferVC: BaseVC,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate {
    
    @IBOutlet weak var IncreasePayColl: UICollectionView!
    @IBOutlet weak var offerName: UILabel!
    @IBOutlet weak var offerProducts: UILabel!
    @IBOutlet weak var increasePay: UITextField!
    @IBOutlet weak var moneyText: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    
    var templateOffer: TemplateOffer?
    var depositValue: Deposit?
    var increasePayVariable: IncreasePayVariable = .None
    
    
    var influencersFilter = [String: AnyObject]()
    var deductedAmount: Double = 0.00
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return global.IncreasePay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : IncreasePay = IncreasePayColl.dequeueReusableCell(withReuseIdentifier: "increasepay", for: indexPath) as! IncreasePay
        cell.payText.text = global.IncreasePay[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        self.increasePay.text = global.IncreasePay[indexPath.row]
        increasePayVariable = IncreasePayVariableValue(pay: global.IncreasePay[indexPath.row])
        
//        if indexPath.row == 0{
//        self.increasePay.text = global.IncreasePay[indexPath.row]
//        increasePayVariable = IncreasePayVariable.None
//        }else{
//        self.increasePay.text = String(global.IncreasePay[indexPath.row].dropFirst())
//
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 2.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 2,left: 2,bottom: 2,right: 2);
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addNavigationBarTitleView(title: "Distribute Offer", image: UIImage())
        self.addDoneButtonOnKeyboard(textField: moneyText)
        self.offerTextValue()
        self.offerName.text = templateOffer?.title
        
        self.influencersFilter["gender"] = templateOffer?.genders as AnyObject?
        self.influencersFilter["primaryCategory"] = templateOffer?.category as AnyObject?
        self.influencersFilter["zipCode"] = templateOffer?.zipCodes as AnyObject?
        
        self.getDeepositDetails()
    }
    
    @objc func getDeepositDetails() {
        let user = Singleton.sharedInstance.getCompanyUser()
        getDepositDetails(companyUser: user.userID!) { (deposit, status, error) in
            
            if status == "success" {
                
                self.depositValue = deposit
                
            }
        }
    }
    
    func offerTextValue() {
        
        if templateOffer!.posts.count >= 3 {
            let offerOne = templateOffer!.posts[0]
            let offerTwo = templateOffer!.posts[1]
            let offerThree = templateOffer!.posts[2]
            /*- Post one features 5 products
             - Post two features 1 possible product
             - Post three features 9 possible products
             */
            offerProducts.text = "- Post one features \(String(describing: offerOne.products!.count)) possible \(self.getProductContent(count: offerOne.products!.count)) \n- Post two features \(String(describing: offerTwo.products!.count)) possible \(self.getProductContent(count: offerTwo.products!.count)) \n- Post three features \(String(describing: offerThree.products!.count)) possible \(self.getProductContent(count: offerThree.products!.count))"
        
            }else if templateOffer!.posts.count == 2 {
            let offerOne = templateOffer!.posts[0]
            let offerTwo = templateOffer!.posts[1]
            offerProducts.text = "- Post one features \(String(describing: offerOne.products!.count))  possible \(self.getProductContent(count: offerOne.products!.count)) \n- Post two features \(String(describing: offerTwo.products!.count)) possible \(self.getProductContent(count: offerTwo.products!.count))"
        
            }else if templateOffer!.posts.count == 1 {
            let offerOne = templateOffer!.posts[0]
            offerProducts.text = "- Post one features \(String(describing: offerOne.products!.count))  possible \(self.getProductContent(count: offerOne.products!.count))"
        
            }
        
    }
    
    func getProductContent(count: Int) -> String {
        
        if count > 1 {
            
            return "products"
            
        }else{
            return "product"
        }
        
        
    }
    
    //MARK: -Textfield Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if textField == self.moneyText {
            if string == "" {
                if self.moneyText.text!.count == 2 {
                    self.moneyText.text = ""
                }
                
            }else{
                if (self.moneyText.text?.first == "$"){
                    //self.offerRate.text = self.offerRate.text!
                }else{
                    self.moneyText.text = "$" + self.moneyText.text!
                }
                
            }
            return true
            
        }else{
            return true
        }
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
        self.moneyText.resignFirstResponder()
    }
    
    @IBAction func changeSwitchAction(sender: UISwitch){
        if sender.tag == 100 {
            
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "zipCode")
                self.influencersFilter["zipCode"] = templateOffer?.zipCodes as AnyObject?
                
            }else{
                self.influencersFilter.removeValue(forKey: "zipCode")
            }
            
        }else if sender.tag == 101 {
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "gender")
                self.influencersFilter["gender"] = templateOffer?.zipCodes as AnyObject?
            }else{
                self.influencersFilter.removeValue(forKey: "gender")
            }
            
        }else if sender.tag == 102 {
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "primaryCategory")
                self.influencersFilter["primaryCategory"] = templateOffer?.zipCodes as AnyObject?
            }else{
                self.influencersFilter.removeValue(forKey: "primaryCategory")
            }
            
        }
        print(self.influencersFilter)
    }
    
    @IBAction func distributeAction(sender: UIButton){
        
        if self.moneyText.text?.count != 0 {
            
            if self.depositValue!.currentBalance != nil {
            
            var offerAmount = Double((String((self.moneyText.text?.dropFirst())!)))!
            
            if (offerAmount < self.depositValue!.currentBalance!) {
            
            let influencerFilter = ["primaryCategory":["Other"],"username":["brunogonzalezhauger"]]
            
                getFilteredInfluencers(category: self.influencersFilter as! [String : [AnyObject]]) { (influencer, errorStatus,user) in
                
                if influencer?.count != 0 {
                    
                    var extractedInfluencer = [User]()
                    var extractedUserID = [String]()
                    
                    
                    for (value,user) in zip(influencer!, user!) {
                        
                        let influcerMoneyValue = calculateCostForUser(offer: self.templateOffer!, user: user, increasePayVariable: self.increasePayVariable.rawValue).rounded()
                        
                        if offerAmount >= influcerMoneyValue {
                            
                            offerAmount -= influcerMoneyValue
                            extractedInfluencer.append(user)
                            extractedUserID.append(value)
                            
                        }else{
                            break
                        }
                        
                    }
                    
                    if extractedUserID.count != 0 {
                        
                        let totalDeductedAmount = (Double((String((self.moneyText.text?.dropFirst())!)))! - offerAmount)
                        
                        self.sendOutOffers(influencer: extractedUserID, user: extractedInfluencer, deductedAmount: totalDeductedAmount)
                        
                    }else{
                        self.showAlertMessage(title: "Alert", message: "Not enough influencers were found, please disable a filter for better results or increase the number of categories, zip codes, or genders you have set") {
                            
                        }
                    }
                    
                    
                }else{
                    
                    self.showAlertMessage(title: "Alert", message: "Not enough influencers were found, please disable a filter for better results or increase the number of categories, zip codes, or genders you have set") {
                        
                    }
                    
                }
                
            }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter your offer amount below than deposit amount or deposit more money and try again!") {
                    
                }
        }
        }else {
            
                self.showAlertMessage(title: "Alert", message: "Please Deposit some amount to account") {
                    
                }
                
        }
            
        }else{
            self.showAlertMessage(title: "Alert", message: "Please enter your offer rate") {
                
            }
        }
        
    }
    
    @IBAction func privacyAction(gesture: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "toWebVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebVC"{
           let view = segue.destination as! WebVC
            view.urlString = "https://www.ambassadoor.co/terms-of-service"
        }
    }
    
    func sendOutOffers(influencer: [String]?,user: [User]?,deductedAmount: Double) {
        
        self.templateOffer?.money = Double((String((self.moneyText.text?.dropFirst())!)))!
        self.templateOffer?.user_IDs = influencer!
        let path = Auth.auth().currentUser!.uid + "/" + self.templateOffer!.offer_ID
        sentOutOffers(pathString: path, templateOffer: self.templateOffer!) { (template, status) in
            
            var cardDetails = [Any]()
            
            
            if status == true {
                //for value in influencer! {
                for (value, userValue) in zip(influencer!, user!) {
                    //(value, user) in zip(strArr1, strArr2)
                    
                    let patstring = value + "/" + template.offer_ID
                    template.money = calculateCostForUser(offer: self.templateOffer!, user: userValue, increasePayVariable: self.increasePayVariable.rawValue).rounded()
                    cardDetails.append([value:["id":value,"amount":template.money,"toOffer":template.offer_ID,"name":userValue.name!,"gender":userValue.gender!,"averageLikes":userValue.averageLikes!]])
                    completedOffersToUsers(pathString: patstring, templateOffer: template)
                }
                let removeTemplatePath = Auth.auth().currentUser!.uid + "/" +  template.offer_ID
                removeTemplateOffers(pathString: removeTemplatePath, templateOffer: template)
                let user = Singleton.sharedInstance.getCompanyUser()
                let depositBalance = self.depositValue!.currentBalance! - deductedAmount
                let totalDeductedAmt = (self.depositValue?.totalDeductedAmount!)! + deductedAmount
                //Add Transaction Details
                
                
                
                let transaction = TransactionDetails.init(dictionary: ["amount":String(deductedAmount),"createdAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ss"),"currencyIsoCode":"USD","type":"paid","updatedAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ss"),"id":self.templateOffer!.offer_ID,"status":self.templateOffer!.title,"paidDetails":cardDetails])
                
                let tranObj = API.serializeTransactionDetails(transaction: transaction)
                
                self.depositValue?.currentBalance = depositBalance
                self.depositValue?.totalDeductedAmount = totalDeductedAmt
                self.depositValue?.lastDeductedAmount = deductedAmount
                var depositHistory = [Any]()
                depositHistory.append(contentsOf: self.depositValue!.depositHistory!)
                depositHistory.append(tranObj)
                self.depositValue?.depositHistory = depositHistory
                self.depositValue?.lastTransactionHistory = transaction
                
                
                sendDepositAmount(deposit: self.depositValue!, companyUser: user.userID!) { (deposit, status) in
                    self.depositValue = deposit
                }
                global.post.removeAll()
                self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
                self.navigationController?.popToRootViewController(animated: true)
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