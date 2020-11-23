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
    @IBOutlet weak var locationFilterSwitch: UISwitch!
    
    @IBOutlet weak var commisionText: UILabel!
    @IBOutlet weak var mustBeTwentyOneSegment: UISegmentedControl!
    
    var templateOffer: TemplateOffer?
    var depositValue: Deposit?
    var increasePayVariable: IncreasePayVariable = .None
    
    
    var influencersFilter = [String: AnyObject]()
    var deductedAmount: Double = 0.00
    var ambassadoorCommision: Double = 0.00
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return global.IncreasePay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : IncreasePay = IncreasePayColl.dequeueReusableCell(withReuseIdentifier: "increasepay", for: indexPath) as! IncreasePay
        cell.payText.text = global.IncreasePay[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        UseTapticEngine()
        
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
        return CGSize(width: 70, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 2,left: 2,bottom: 2,right: 2);
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customizeNavigationBar()
        // Do any additional setup after loading the view.
        mustBeTwentyOneSegment.selectedSegmentIndex = 0
        let commission = Singleton.sharedInstance.getCommision() * 100
        if commission == floor(commission) {
            self.commisionText.text = "Ambassadoor will take \(Int(commission))%"
        } else {
            self.commisionText.text = "Ambassadoor will take \(commission)%"
        }
        self.addNavigationBarTitleView(title: "Distribute Offer", image: UIImage())
        self.addDoneButtonOnKeyboard(textField: moneyText)
        self.offerTextValue()
        self.offerName.text = templateOffer?.title
        
        self.influencersFilter["gender"] = templateOffer?.genders as AnyObject?
        self.influencersFilter["categories"] = templateOffer?.category as AnyObject?
        self.getDeepositDetails()
        
        
        if let templateOffer = templateOffer {
            GetZipsFromLocationFilter(locationFilter: templateOffer.locationFilter) { (zips1) in
                self.zips = zips1
                DispatchQueue.main.async {
                    if self.locationFilterSwitch.isOn {
                        self.influencersFilter["zipCode"] = zips1 as AnyObject?
                    }
                }
            }
        }
        
    }
    
    @objc func getDeepositDetails() {
        let user = Singleton.sharedInstance.getCompanyUser()
        //GoQjJPCnHBVRTc5PxfnjohUWcVw2
        //user.userID!
        getDepositDetails(companyUser: user.userID!) { (deposit, status, error) in
            
            if status == "success" {
                
                self.depositValue = deposit
                
            }
        }
    }
    
    func offerTextValue() {
        
        offerProducts.text = templateOffer!.GetSummary()
        
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
    
    var zips: [String]?
    
    
    @objc override func doneButtonAction() {
        self.moneyText.resignFirstResponder()
    }
    
    @IBAction func changeSwitchAction(sender: UISwitch){
        if sender.tag == 100 {
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "zipCode")
                if let zips = zips {
                    self.influencersFilter["zipCode"] = zips as AnyObject?
                }
                
            }else{
                self.influencersFilter.removeValue(forKey: "zipCode")
            }
            
        }else if sender.tag == 101 {
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "gender")
                self.influencersFilter["gender"] = templateOffer?.genders as AnyObject?
            }else{
                self.influencersFilter.removeValue(forKey: "gender")
            }
            
        }else if sender.tag == 102 {
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "categories")
                self.influencersFilter["categories"] = templateOffer?.category as AnyObject?
            }else{
                self.influencersFilter.removeValue(forKey: "categories")
            }
            
        }
        print(self.influencersFilter)
    }
    
    func canDistribute(alertUser: Bool) -> Bool {
        if self.moneyText.text?.count != 0{
            let offerAmount = Double((String((self.moneyText.text?.dropFirst())!)))!
            if offerAmount > 0 {
                if self.depositValue != nil {
                    if self.depositValue!.currentBalance != nil {
                        if (offerAmount < self.depositValue!.currentBalance!) {
                            return true
                        } else {
                            self.showAlertMessage(title: "Alert", message: "Please enter your offer amount below than deposit amount or deposit more money and try again!") {
                                
                            }
                        }
                    }
                }else {
                    
                    self.showAlertMessage(title: "Deposit", message: "You must have money in your Ambassdaoor account to pay influnecers.") {
                        
                    }
                    
                }
                
            }else{
                self.showAlertMessage(title: "Enter Amount", message: "Enter how much money you would like to spend distributing your offer.") {
                    
                }
            }
        }else{
            self.showAlertMessage(title: "Enter Amount", message: "Enter how much money you would like to spend distributing your offer.") {
                
            }
        }
        return false
        
    }
    
    @IBOutlet weak var DistributeButtonview: ShadowView!
    
    @IBAction func distributeAction(sender: UIButton){
        if canDistribute(alertUser: true) {
            //DistributeOffer()
            DistributeOfferToOfferPool()
        } else {
            YouShallNotPass(SaveButtonView: DistributeButtonview)
        }
    }
    
    var moneyAmount: Double = 0.0
    
    
    func DistributeOfferToOfferPool() {
        
		guard let offerAmount = Double((String((self.moneyText.text?.dropFirst())!))) else {
            MakeShake(viewToShake: moneyText)
            YouShallNotPass(SaveButtonView: DistributeButtonview)
            return
            
        }
        
        let originalAmount = offerAmount
        
        self.templateOffer?.money = originalAmount
        
        //self.templateOffer?.cashPower = originalAmount
        
        self.templateOffer?.commission = Singleton.sharedInstance.getCommision()
        
        //Reduce Ambassadoor Commission
        //let cashPower = self.templateOffer?.cashPower
        let ambassadoorCommission = (originalAmount * Singleton.sharedInstance.getCommision())
        self.templateOffer?.cashPower = originalAmount - ambassadoorCommission
        
        self.templateOffer?.originalAmount = originalAmount - ambassadoorCommission
        
        if let referral = Singleton.sharedInstance.getCompanyDetails().referralcode{
            
            let paycomission = originalAmount * 0.01
            self.PayReferralUser(offer: self.templateOffer!, referralAmount: paycomission, referralID: referral)
            //originalAmount * (1 - 0.01)
            self.templateOffer?.referralAmount = paycomission
        }
        self.templateOffer?.incresePay = self.increasePayVariable.rawValue
    
        self.templateOffer?.influencerFilter = self.influencersFilter
        print("mustBe=",mustBeTwentyOneSegment.selectedSegmentIndex)
        self.templateOffer?.mustBeTwentyOne = !(mustBeTwentyOneSegment.selectedSegmentIndex == 0)
        
        self.templateOffer?.companyDetails = serializeCompany(company: Singleton.sharedInstance.getCompanyDetails())
        
        let expiryDateAdded = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let dateString = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: expiryDateAdded, format: "yyyy-MM-dd'T'HH:mm:ssZ")
        
        let expiryDate = DateFormatManager.sharedInstance.getExpiryDate(dateString: dateString)
        self.templateOffer?.expiredate = expiryDate
        print(Singleton.sharedInstance.getCompanyDetails().referralcode?.count)
        if Singleton.sharedInstance.getCompanyDetails().referralcode?.count != 0 {
            self.templateOffer?.isRefferedByInfluencer = true
            self.templateOffer?.isReferCommissionPaid = false
            self.templateOffer?.commission = 0.01
            self.templateOffer?.referralID = Singleton.sharedInstance.getCompanyDetails().referralcode!
        }
        let path = Auth.auth().currentUser!.uid + "/" + self.templateOffer!.offer_ID
        sentOutOffersToOfferPool(pathString: path, templateOffer: self.templateOffer!) { (offer, status) in
            createTemplateOffer(pathString: path, edited: true, templateOffer: offer) { (tempOffer, status) in
            }
            global.post.removeAll()
            self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.popToRootViewController(animated: true)
            self.sendTransactionDetailsToBusinessUser(deductedAmount: originalAmount, ambassadoorCommision: Singleton.sharedInstance.getCommision())
            
        }
        
    }
    
    func sendTransactionDetailsToBusinessUser(deductedAmount: Double, ambassadoorCommision: Double) {
        let userCompany = Singleton.sharedInstance.getCompanyUser()
        let depositBalance = self.depositValue!.currentBalance! - deductedAmount
        let totalDeductedAmt = (self.depositValue?.totalDeductedAmount!)! + deductedAmount
        //Add Transaction Details
        
        var cardDetails = [Any]()
        
        cardDetails.append(["country":"","expireMonth":"","expireYear":"","last4":"xxxx"])
        
        let transaction = TransactionDetails.init(dictionary: ["amount":String(deductedAmount),"createdAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ssZ"),"currencyIsoCode":"USD","type":"distributed","updatedAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ssZ"),"id":self.templateOffer!.offer_ID,"status":self.templateOffer!.title,"paidDetails":cardDetails,"commission":ambassadoorCommision])
        
        let tranObj = API.serializeTransactionDetails(transaction: transaction)
        
        self.depositValue?.currentBalance = depositBalance
        self.depositValue?.totalDeductedAmount = totalDeductedAmt
        self.depositValue?.lastDeductedAmount = deductedAmount
        var depositHistory = [Any]()
        depositHistory.append(contentsOf: self.depositValue!.depositHistory!)
        depositHistory.append(tranObj)
        self.depositValue?.depositHistory = depositHistory
        self.depositValue?.lastTransactionHistory = transaction
        
        
        sendDepositAmount(deposit: self.depositValue!, companyUser: userCompany.userID!) { (deposit, status) in
            
        }
    }
    
    func DistributeOffer() {
        var error = false
        guard var offerAmount = Double((String((self.moneyText.text?.dropFirst())!))) else {
            MakeShake(viewToShake: moneyText)
            YouShallNotPass(SaveButtonView: DistributeButtonview)
            return
            
        }
        
        let originalAmount = offerAmount
        
        
        getFilteredInfluencers(category: self.influencersFilter as! [String : [AnyObject]]) { (errorStatus,userArray) in
            
            if errorStatus == "error" {
                self.showAlertMessage(title: "Error", message: "There was an error and you offer could not be distributed.") {}
                return
            }
            
            print("INFLUENCERS FILTERED:", userArray!.count)
            for user in userArray! {
                print(user.GetSummary())
            }
            
            if userArray?.count != 0 {
                
                var extractedInfluencer = [User]()
                var extractedUserID = [String]()
                
                //MARK: Deducting Ambassadoor Commission
                /*
                 if Singleton.sharedInstance.getCompanyDetails().referralcode?.count != 0 {
                 self.ambassadoorCommision = offerAmount * Singleton.sharedInstance.getCommision()
                 offerAmount -= self.ambassadoorCommision
                 }
                 */
                
                for user in userArray! {
                    
                    if user.averageLikes != 0 && user.averageLikes != nil {
                        print(user.username	+ " has likes")
                        
                        //let influcerMoneyValue = ((Double(calculateCostForUser(offer: self.templateOffer!, user: user, increasePayVariable: self.increasePayVariable.rawValue)) * 100).rounded())/100
                        //NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
                        
                        let influcerAmtWithOutCom = calculateCostForUser(offer: self.templateOffer!, user: user, increasePayVariable: self.increasePayVariable.rawValue)
                        print(user.username	+ " costs " + "\(influcerAmtWithOutCom)")
                        //var influcerMoneyValue = calculateCostForUser(offer: self.templateOffer!, user: user, increasePayVariable: self.increasePayVariable.rawValue)
                        let influcerMoneyValue = influcerAmtWithOutCom + (influcerAmtWithOutCom * Singleton.sharedInstance.getCommision())
                        self.ambassadoorCommision += influcerAmtWithOutCom * Singleton.sharedInstance.getCommision()
                        
                        if offerAmount >= influcerMoneyValue {
                            
                            print(user.username	+ " affordable")
                            
                            if (self.templateOffer?.user_IDs.contains(user.id))! == false {
                                print(user.username	+ " ADDED")
                                
                                offerAmount -= influcerMoneyValue
                                extractedInfluencer.append(user)
                                extractedUserID.append(user.id)
                                
                            }
                            
                        }
                    }
                    
                }
                
                if extractedUserID.count != 0 {
                    
                    let totalDeductedAmount = originalAmount - offerAmount
                    
                    self.DistributeOffersWithFirebase(influencer: extractedUserID, user: extractedInfluencer, deductedAmount: totalDeductedAmount, originalAmount: originalAmount)
                    
                } else {
                    error = true
                }
            } else {
                //error = true
                self.NoInfluencers()
                
            }
        }
        if error {
            YouShallNotPass(SaveButtonView: DistributeButtonview)
            self.showAlertMessage(title: "Alert", message: "Not enough influencers were found, please disable a filter or add more range to your location, category, or gender filter.") {}
        }
    }
    
    func referredByInfluencer(referralID: String, referralAmount: Double, offer: TemplateOffer) {
        
        getUserByReferralCode(referralcode: referralID) { (user) in
            
            if user != nil {
                
                let transactionHistory = ["from":Auth.auth().currentUser!.uid,"To":user?.id as Any,"type":"referral","Amount":(self.ambassadoorCommision * 0.2),"status":"success","createdAt":DateFormatManager.sharedInstance.getCurrentDateString(),"id":offer.offer_ID] as [String : Any]
                
                var amount = 0.0
    
                amount = user!.accountBalance == nil ? referralAmount : user!.accountBalance! + referralAmount
                
                offer.referralID = user?.id
                
                updateInfluencerAmountByReferral(user: user!, amount: amount)
                
                sentOutTransactionToInfluencer(pathString: (user?.id)!, transactionData: transactionHistory)
                
                let params = ["token":user!.tokenFIR!,"offer":offer.title,"influencer": user!.name!,"amount":referralAmount,"username": Singleton.sharedInstance.company.email!] as [String: AnyObject]
                NetworkManager.sharedInstance.sendPushNotificationForreferral(params: params)
                
                
            }
            
        }
        
    }
    
    func referredByCompany(referralID: String, referralAmount: Double, offer: TemplateOffer) {
        
        sentReferralAmountToBusiness(referralID: referralID) { (company) in
            
            getDepositDetails(companyUser: company!.userID!) { (deposit, status, error) in
                
                let cardDetails = ["last4":"0000","expireMonth":"00","expireYear":"0000","country":"US"] as [String : Any]
                
                var depositAmt = 0.0
                var depositHistory = [Any]()
                offer.referralID = company!.userID!
                
                depositAmt = status == "new" ? referralAmount : deposit!.currentBalance ?? 0.0 + referralAmount
                
                let transactionDict = ["id":referralID,"userName":company!.email!,"status":"success","offerName":offer.title,"type":"referral","currencyIsoCode":"USD","amount":depositAmt,"createdAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ssZ"),"updatedAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ssZ"),"transactionType":"referral","cardDetails":cardDetails] as [String : Any]
                
                let transactionObj = TransactionDetails.init(dictionary: transactionDict)
                
                let tranObj = API.serializeTransactionDetails(transaction: transactionObj)
                
                if status == "success"{
                    let currentBalance = deposit!.currentBalance! + depositAmt
                    let totalDepositAmount = deposit!.totalDepositAmount! + depositAmt
                    deposit?.totalDepositAmount = totalDepositAmount
                    deposit?.currentBalance = currentBalance
                    deposit?.lastDepositedAmount = depositAmt
                    depositHistory.append(contentsOf: (deposit!.depositHistory!))
                }
                deposit?.lastTransactionHistory = transactionObj
                depositHistory.append(tranObj)
                deposit?.depositHistory = depositHistory
                
                sendDepositAmount(deposit: deposit!, companyUser: company!.userID!) { (modifiedDeposit, status) in
                    let params = ["token":company!.deviceFIRToken!,"offer":offer.title,"influencer": company!.email!,"amount": referralAmount,"username":Singleton.sharedInstance.company.email!] as [String: AnyObject]
                    NetworkManager.sharedInstance.sendPushNotificationForreferral(params: params)
                    
                }
                
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
    
    func sentOutReferralCommision(referral: String?,offerID: String) {
        
        if referral != "" && referral != nil {
            
            if referral?.count == 6{
                
                getUserByReferralCode(referralcode: referral!) { (user) in
                    
                    if user != nil {
                        
                        let transactionHistory = ["from":Auth.auth().currentUser!.uid,"To":user?.id as Any,"type":"referral","Amount":(self.ambassadoorCommision * 0.2),"status":"success","createdAt":DateFormatManager.sharedInstance.getCurrentDateString(),"id":offerID] as [String : Any]
                        
                        var amount = 0.0
                        
                        if user?.accountBalance != nil {
                            
                            amount = user!.accountBalance! + (self.ambassadoorCommision * 0.2)
                        }else{
                            amount = (self.ambassadoorCommision * 0.2)
                        }
                        
                        updateInfluencerAmountByReferral(user: user!, amount: amount)
                        
                        sentOutTransactionToInfluencer(pathString: (user?.id)!, transactionData: transactionHistory)
                        
                        
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    func PayReferralUser(offer: TemplateOffer, referralAmount: Double, referralID: String) {
        
        
        if referralID.count == 6{
            
            referredByInfluencer(referralID: referralID, referralAmount: referralAmount, offer: offer)
            
        }else if referralID.count == 7{
            
            referredByCompany(referralID: referralID, referralAmount: referralAmount, offer: offer)
        }
    }
    
    func NoInfluencers() {
        
        self.showAlertMessage(title: "Alert", message: "0 influencers found") {
            
        }
        
    }
    
    func DistributeOffersWithFirebase(influencer: [String]?, user: [User]?, deductedAmount: Double, originalAmount: Double) {
        
        var userNotificationArray = [[String: Any]]()
        
        //self.ambassadoorCommision = originalAmount * Singleton.sharedInstance.getCommision()
        
        //self.templateOffer?.money = originalAmount - self.ambassadoorCommision
        self.templateOffer?.money = deductedAmount - self.ambassadoorCommision
        self.templateOffer?.commission = self.ambassadoorCommision
        
        let expiryDateAdded = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let dateString = DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: expiryDateAdded, format: "yyyy-MM-dd'T'HH:mm:ssZ")
        
        let expiryDate = DateFormatManager.sharedInstance.getExpiryDate(dateString: dateString)
        self.templateOffer?.expiredate = expiryDate
        
        //Record of offer sent user_IDs(Based on this user-IDs only we are fetching the Statistics Data)
        for influencerID in influencer! {
            if (self.templateOffer?.user_IDs.contains(influencerID))!{
                
            }else{
                
                self.templateOffer?.user_IDs.append(influencerID)
            }
        }
        
        let path = Auth.auth().currentUser!.uid + "/" + self.templateOffer!.offer_ID
        
        sentOutOffers(pathString: path, templateOffer: self.templateOffer!) { (template, status) in
            
            var cardDetails = [Any]()
            
            if status == true {
                //for value in influencer! {
                for (value, userValue) in zip(influencer!, user!) {
                    //(value, user) in zip(strArr1, strArr2)
                    if userValue.averageLikes != 0 && userValue.averageLikes != nil {
                        let patstring = userValue.id + "/" + template.offer_ID
                        
                        
                        template.money = Double(NumberToPrice(Value: calculateCostForUser(offer: self.templateOffer!, user: userValue, increasePayVariable: self.increasePayVariable.rawValue), enforceCents: true).dropFirst())!
                        
                        // Upadating Every Post Pay Value to offer's Post
                        let singlePostAmount = Double(template.money / Double(template.posts.count))
                        
                        for (index,_) in template.posts.enumerated() {
                            
                            template.posts[index].PayAmount = singlePostAmount
                            
                        }
                        
                        
                        
                        template.commission = Double(NumberToPrice(Value: calculateCostForUser(offer: self.templateOffer!, user: userValue, increasePayVariable: self.increasePayVariable.rawValue), enforceCents: true).dropFirst())! * Singleton.sharedInstance.getCommision()
                        
                        if Singleton.sharedInstance.getCompanyDetails().referralcode?.count != 0 {
                            
                            
                            
                            template.isRefferedByInfluencer = true
                            template.isReferCommissionPaid = false
                            template.referralAmount = template.commission! * 0.01
                            template.referralID = Singleton.sharedInstance.getCompanyDetails().referralcode!
                            
                            
                        }
                        cardDetails.append([value:["id":userValue.id,"amount":template.money,"commission":template.commission,"toOffer":template.offer_ID,"name":userValue.name!,"gender":userValue.gender!,"averageLikes":userValue.averageLikes!]])
                        //Collecting Details For sending Push Notification to Influencers
                        if userValue.tokenFIR != "" && userValue.tokenFIR != nil {
                            userNotificationArray.append(API.serializeUser(user: userValue,amount: template.money))
                        }
                        
                        UpdatePriorityValue(user: userValue)
                        completedOffersToUsers(pathString: patstring, templateOffer: template)
                        
                        
                        //Naveen Suggested - No Need this functionalities
                        //                        let transactionHistory = ["from":Auth.auth().currentUser!.uid,"To":value,"type":"offer","Amount":template.money,"status":"pending","createdAt":DateFormatManager.sharedInstance.getCurrentDateString(),"id":template.offer_ID] as [String : Any]
                        //
                        //                        sentOutTransactionToInfluencer(pathString: value, transactionData: transactionHistory)
                        
                    }
                }
                //let removeTemplatePath = Auth.auth().currentUser!.uid + "/" +  template.offer_ID
                //removeTemplateOffers(pathString: removeTemplatePath, templateOffer: template)
                let companyDetail = Singleton.sharedInstance.getCompanyDetails()
                let params = ["tokens":userNotificationArray,"Owner":companyDetail.name,"offer": self.templateOffer!.title] as [String : AnyObject]
                NetworkManager.sharedInstance.sendPushNotification(params: params)
                var userIDValue = [String]()
                var userIDDubValue = [String]()
                for uderIDs in user! {
                    userIDDubValue.append(uderIDs.id)
                }
                userIDDubValue.append(contentsOf: template.user_IDs)
                
                for uniqueID in userIDDubValue {
                    
                    if userIDValue.contains(uniqueID){
                        
                    }else{
                        userIDValue.append(uniqueID)
                    }
                    
                }
                
                let updateTemplatePath = Auth.auth().currentUser!.uid + "/" +  template.offer_ID
                updateTemplateOffers(pathString: updateTemplatePath, templateOffer: template, userID: userIDValue)
                let userCompany = Singleton.sharedInstance.getCompanyUser()
                let depositBalance = self.depositValue!.currentBalance! - deductedAmount
                let totalDeductedAmt = (self.depositValue?.totalDeductedAmount!)! + deductedAmount
                //Add Transaction Details
                
                let transaction = TransactionDetails.init(dictionary: ["amount":String(deductedAmount),"createdAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ssZ"),"currencyIsoCode":"USD","type":"paid","updatedAt":DateFormatManager.sharedInstance.getStringFromDateWithFormat(date: Date(), format: "yyyy/MMM/dd HH:mm:ssZ"),"id":self.templateOffer!.offer_ID,"status":self.templateOffer!.title,"paidDetails":cardDetails,"commission":self.ambassadoorCommision])
                
                let tranObj = API.serializeTransactionDetails(transaction: transaction)
                
                self.depositValue?.currentBalance = depositBalance
                self.depositValue?.totalDeductedAmount = totalDeductedAmt
                self.depositValue?.lastDeductedAmount = deductedAmount
                var depositHistory = [Any]()
                depositHistory.append(contentsOf: self.depositValue!.depositHistory!)
                depositHistory.append(tranObj)
                self.depositValue?.depositHistory = depositHistory
                self.depositValue?.lastTransactionHistory = transaction
                
                
                sendDepositAmount(deposit: self.depositValue!, companyUser: userCompany.userID!) { (deposit, status) in
                    self.depositValue = deposit
                }
                /*
                 if Singleton.sharedInstance.getCompanyDetails().referralcode?.count != 0 {
                 self.sentOutReferralCommision(referral: Singleton.sharedInstance.getCompanyDetails().referralcode, offerID: self.templateOffer!.offer_ID)
                 }
                 */
                self.showAlertMessage(title: "Offer Distrubuted", message: "Your offer was sent to \(influencer?.count ?? 0) influencers, totaling \(NumberToPrice(Value: deductedAmount, enforceCents: true)). If you send this Offer again, Ambassadoor will not resend the offer to influencers who already recieved it.") {
                    global.post.removeAll()
                    self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }
            
        }
        
    }
    
}
