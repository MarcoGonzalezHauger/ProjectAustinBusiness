//
//  DistributeVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/27/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class DistributeVC: BaseVC, changedDelegate, missingMoneyDelegate, dismissSuccessVC {
    func dismissedSuccess() {
        self.tabBarController?.selectedIndex = 2
        
        global.post.removeAll()
        self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
        self.createLocalNotification(notificationName: "reloadstatics", userInfo: [:])
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
	
	func changeCashPowerAndRetry(_ newCashPower: Double) {
		amountOfMoneyInCents = Int(newCashPower * 100)
        money.moneyValue = amountOfMoneyInCents
        moneyChanged()
        attemptDistribution()
	}
	
    func RetryDistribution(deposit: Deposit) {
        self.depositValue = deposit
        attemptDistribution()
	}
	
    
    @IBOutlet weak var categorySwitch: UISwitch!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var genderSwitch: UISwitch!
    
    @IBOutlet weak var DistributeButtonview: ShadowView!
    
    
    func updateFilterApproximation() {
        ///Ram, code should be written here.
        filterApproximation(category: self.influencersFilter as! [String : [AnyObject]], users: global.allInfluencers) { (status, users) in
            self.SetAvaliableInfluencers(Double(users!.count))
        }
        ///When you get your result:
        //SetAvaliableInfluencers(_ numberOfInfluencers: Double)
    }
    
    
    ///All you need to know about the code below:
    
    //	getDesiredCashPower() -> Double
    //	getIncreasePay() -> Double
    //	getMustBe21() -> Bool
    
    //SetAvaliableInfluencers(_ numberOfInfluencers: Double)
    
    var templateOffer: TemplateOffer?
    var influencersFilter = [String: AnyObject]()
    
    var zips: [String]?
    
    var depositValue: Deposit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.addNavigationBarTitleView(title: "Distribute Offer", image: UIImage())
        getDeepositDetails()
        updateIncreasePayLabel()
        money.changedDelegate = self
        money.moneyValue = amountOfMoneyInCents
        moneyChanged()
        self.addDoneButtonOnKeyboard(textField: self.money)
        SetComissionText()
        
        influencersFilter["gender"] = templateOffer?.genders as AnyObject?
        influencersFilter["categories"] = templateOffer?.category as AnyObject?
        updateFilterApproximation()
        
		setSwitchLabels()
        
        if let templateOffer = templateOffer {
            GetZipsFromLocationFilter(locationFilter: templateOffer.locationFilter) { (zips1) in
                self.zips = zips1
                DispatchQueue.main.async {
                    if self.locationSwitch.isOn {
                        self.influencersFilter["zipCode"] = zips1 as AnyObject?
                        self.updateFilterApproximation()
                    }
                }
            }
        }
    }
	
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var genderFilter: UILabel!
	
	func setSwitchLabels() {
		//category Label
		
		categoryLabel.text = "Category Filter (\(templateOffer!.category.count) Categor\(templateOffer!.category.count == 1 ? "y" : "ies"))"
		
		//location filter
		
		let locationFilter = templateOffer!.locationFilter
		switch locationFilter.components(separatedBy: ":")[0] {
		case "nw":
			locationLabel.text = "Location Filter (Nationwide)"
		case "states":
			let stateList = GetListOfStates()
			let data = locationFilter.components(separatedBy: ":")[1]
			var returnData: [String] = []
			for stateName in data.components(separatedBy: ",") {
				returnData.append(stateList.filter { (state1) -> Bool in
					return state1.shortName == stateName
					}[0].name)
			}
			locationLabel.text = "Location Filter (\(returnData.count) State\(returnData.count == 1 ? "" : "s"))"
		case "radius":
			let data1 = locationFilter.components(separatedBy: ":")[1]
			var returnData: [String] = []
			for data in data1.components(separatedBy: ",") {
				let zip = data.components(separatedBy: "-")[0]
				let radius = Int(data.components(separatedBy: "-")[1]) ?? 0
				returnData.append("A \(radius) mile radius around \(zip)")
			}
			locationLabel.text = "Location Filter (\(returnData.count) \(returnData.count == 1 ? "radius" : "radii") selected)"
		default:
			break
		}
		
		//gender label
		
		if templateOffer!.genders.count > 1 {
			genderFilter.text = "Gender Filter (All Included)"
		} else {
			genderFilter.text = "Gender Filter (\(templateOffer!.genders.joined(separator: ", ")) only)"
		}
	}
    
    @IBOutlet weak var avaliableInfluencerLabel: UILabel!
    
    func SetAvaliableInfluencers(_ numberOfInfluencers: Double) {
        avaliableInfluencerLabel.textColor = numberOfInfluencers < 8 ? .systemRed : .systemBlue
		if numberOfInfluencers < 8 {
			MakeShake(viewToShake: avaliableInfluencerLabel, coefficient: 0.2)
		}
        avaliableInfluencerLabel.text = "\(NumberToStringWithCommas(number: numberOfInfluencers))"
    }
    
    @IBOutlet weak var comissionLabel: UILabel!
    func SetComissionText() {
        let commission = Singleton.sharedInstance.getCommision() * 100
        if commission == floor(commission) {
            comissionLabel.text = "Based on average benchmarks of nano-influencing ROI across multiple industries. Ambassadoor will take \(Int(commission))%."
        } else {
            comissionLabel.text = "Based on average benchmarks of nano-influencing ROI across multiple industries. Ambassadoor will take \(commission)%."
        }
    }
    
    @IBAction func privacyAction(sender: UIButton){
        self.performSegue(withIdentifier: "toWebVC", sender: self)
    }
    
    @IBAction func FilterSwitched(_ sender: UISwitch) {
        if sender == self.locationSwitch {
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "zipCode")
                if let zips = zips {
                    self.influencersFilter["zipCode"] = zips as AnyObject?
                }
                
            }else{
                self.influencersFilter.removeValue(forKey: "zipCode")
            }
            
        }else if sender == self.genderSwitch {
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "gender")
                self.influencersFilter["gender"] = templateOffer?.genders as AnyObject?
            }else{
                self.influencersFilter.removeValue(forKey: "gender")
            }
            
        }else if sender == self.categorySwitch {
            
            if sender.isOn {
                self.influencersFilter.removeValue(forKey: "categories")
				self.influencersFilter["categories"] = templateOffer?.category as AnyObject?
            }else{
                self.influencersFilter.removeValue(forKey: "categories")
            }
            
        }
//        print(self.influencersFilter)
        updateFilterApproximation()
    }
    
    func getDesiredCashPower() -> Double {
        return Double(amountOfMoneyInCents) / 100
    }
    
    @IBOutlet weak var twentyOne: UISegmentedControl!
    func getMustBe21() -> Bool {
        return twentyOne.selectedSegmentIndex == 1
    }
    
    func getIncreasePay() -> Double {
        let val = Double(increasePaySlider.value)
        var newVal: Double = 1.0
        if val < 1 {
            newVal = 1 + (val / 10)
        } else if val > 1 {
            newVal = 1.1 + ((val - 1) * 0.9)
        } else {
            newVal = 1.1
        }
        return floor(newVal * 100) / 100
    }
    
    func updateIncreasePayLabel() {
        if getIncreasePay() == 1 {
            increasePayLabel.text = "Nothing"
        } else if getIncreasePay() == 2 {
            increasePayLabel.text = "Double"
        } else {
            increasePayLabel.text = "+\(Int(floor((getIncreasePay() - 1) * 100)))%"
        }
        updateReturnsLabels()
    }
    
    @IBOutlet weak var increasePayLabel: UILabel!
    @IBOutlet weak var increasePaySlider: UISlider!
    @IBAction func increasePayChanged(_ sender: Any) {
        updateIncreasePayLabel()
    }
    
    @IBOutlet weak var moneySlider: UISlider!
    @IBOutlet weak var ExpectedReturns: UILabel!
    @IBOutlet weak var ExpectedPROFIT: UILabel!
    var amountOfMoneyInCents: Int = 10000
	
    func changed() {
        editMode = .manual
        amountOfMoneyInCents = money.moneyValue
        moneyChanged()
    }
	
    var editMode: EditingMode = .manual
    @IBOutlet weak var money: MoneyField!
	
    override func doneButtonAction() {
        self.money.removeTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
        self.money.resignFirstResponder()
        self.money.addTarget(self, action: #selector(self.TrackBarTracked(_:)), for: .editingDidEnd)
    }
	
    func updateReturnsLabels() {
		let commission = Singleton.sharedInstance.getCommision()
        let centsToBeUsedOnLabels: Int = Int((Double(amountOfMoneyInCents) / getIncreasePay()) * (1 - commission))
		let returns = Int(Double(centsToBeUsedOnLabels) * 5.85)
        ExpectedReturns.text = "Expected Return: \(LocalPriceGetter(Value: returns))"
        ExpectedPROFIT.text = "Expected Profit: \(LocalPriceGetter(Value: returns - amountOfMoneyInCents))"
    }
    
    func moneyChanged() {
        if editMode == .manual {
            let value = amountOfMoneyInCents
            if value > 1000000 {
                moneySlider.value = 3
            } else if value >= 100000 {
                moneySlider.value = (((Float(value) - 100000) / 9) / 100000) + 2
            } else if value >= 10000 {
                moneySlider.value = (((Float(value) - 10000) / 9) / 10000) + 1
            } else {
                moneySlider.value = Float(value) / 10000
            }
        } else {
            money.moneyValue = amountOfMoneyInCents
        }
        updateReturnsLabels()
    }
	
    func LocalPriceGetter(Value: Int) -> String {
		if Value <= 0 {
			return "$0.00"
		}
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let amount = Double(Value/100) + Double(Value % 100)/100
        
        return formatter.string(from: NSNumber(value: amount))!
    }
	
    @IBAction func TrackBarTracked(_ sender: Any) {
        editMode = .slider
        let value = Double(moneySlider.value)
        if value > 2 {
            amountOfMoneyInCents = Int((((value - 2) * 9) + 1) * 100000)
        } else if value > 1 {
            amountOfMoneyInCents = Int((((value - 1) * 9) + 1) * 10000)
        } else {
            amountOfMoneyInCents = Int(10000 * value)
        }
        moneyChanged()
    }
    
    @IBAction func getPower(sender: UIButton){
        print(getDesiredCashPower())
        print(getIncreasePay())
        print(getMustBe21())
        attemptDistribution()
        
    }
	
	func attemptDistribution() {
		if canDistribute(alertUser: true) {
            //DistributeOffer()
            self.DistributeOfferToOfferPool()
        } else {
            YouShallNotPass(SaveButtonView: DistributeButtonview)
        }
	}
    
    
    func DistributeOfferToOfferPool() {
        
        //        guard let offerAmount = getDesiredCashPower() else{
        //            return
        //
        //        }
        
        let offerAmount = getDesiredCashPower()
        
        let originalAmount = offerAmount
        
        self.templateOffer?.money = originalAmount
        
        //self.templateOffer?.cashPower = originalAmount
        
        self.templateOffer?.commission = Singleton.sharedInstance.getCommision()
        
        //Reduce Ambassadoor Commission
        //let cashPower = self.templateOffer?.cashPower
        let ambassadoorCommission = (originalAmount * Singleton.sharedInstance.getCommision())
        //edited on 1 Oct by ram
        self.templateOffer?.cashPower = originalAmount - ambassadoorCommission
        
        //edited on 1 Oct by ram
        self.templateOffer?.originalAmount = originalAmount - ambassadoorCommission
        //self.templateOffer?.originalAmount = originalAmount
        
        if let referral = Singleton.sharedInstance.getCompanyDetails().referralcode{
            
            if referral != "" {
                
                let paycomission = originalAmount * 0.01
                self.PayReferralUser(offer: self.templateOffer!, referralAmount: paycomission, referralID: referral)
                //originalAmount * (1 - 0.01)
                self.templateOffer?.referralAmount = paycomission
            }
        }
        self.templateOffer?.incresePay = getIncreasePay()
        
        self.templateOffer?.influencerFilter = self.influencersFilter
        //print("mustBe=",mustBeTwentyOneSegment.selectedSegmentIndex)
        self.templateOffer?.mustBeTwentyOne = getMustBe21()
        
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
            }/*
            global.post.removeAll()
            self.createLocalNotification(notificationName: "reloadOffer", userInfo: [:])
            self.navigationController?.popToRootViewController(animated: true)
            */
            self.sendTransactionDetailsToBusinessUser(deductedAmount: originalAmount, ambassadoorCommision: Singleton.sharedInstance.getCommision())
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toSucessVC", sender: self)
            }
            
        }
        
    }
    
    @objc func getDeepositDetails() {
        let user = Singleton.sharedInstance.getCompanyUser()
        getDepositDetails(companyUser: user.userID!) { (deposit, status, error) in
            
            if status == "success" {
                
                self.depositValue = deposit
                
            }
        }
    }
    
    func canDistribute(alertUser: Bool) -> Bool {
        if getDesiredCashPower() != 0 {
            let offerAmount = getDesiredCashPower()
            if offerAmount > 0 {
                if self.depositValue != nil {
                    if self.depositValue!.currentBalance != nil {
                        if (offerAmount < self.depositValue!.currentBalance!) {
                            return true
                        } else {
							performSegue(withIdentifier: "toMissingMoney", sender: self)
                        }
                    }
                } else {
                    
					performSegue(withIdentifier: "toMissingMoney", sender: self)
                    
                }
                
            } else {
                self.showAlertMessage(title: "Enter Amount", message: "Enter how much money you would like to spend distributing your offer.") {
                    
                }
            }
        } else {
            self.showAlertMessage(title: "No Budget", message: "You did not select a budget for the offer.") {
                
            }
        }
        return false
        
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
    
    func PayReferralUser(offer: TemplateOffer, referralAmount: Double, referralID: String) {
        
        
        if referralID.count == 6{
            
            referredByInfluencer(referralID: referralID, referralAmount: referralAmount, offer: offer)
            
        }else if referralID.count == 7{
            
            referredByCompany(referralID: referralID, referralAmount: referralAmount, offer: offer)
        }
    }
    
    func referredByInfluencer(referralID: String, referralAmount: Double, offer: TemplateOffer) {
        
        getUserByReferralCode(referralcode: referralID) { (user) in
            
            if user != nil {
                
                let transactionHistory = ["from":Auth.auth().currentUser!.uid,"To":user?.id as Any,"type":"referral","Amount":(Singleton.sharedInstance.getCommision() * 0.2),"status":"success","createdAt":DateFormatManager.sharedInstance.getCurrentDateString(),"id":offer.offer_ID] as [String : Any]
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWebVC"{
            let view = segue.destination as! WebVC
            view.urlString = "https://www.ambassadoor.co/terms-of-service"
        }
		if segue.identifier == "toMissingMoney" {
			let view = segue.destination as! missingMoneyVC
			view.desiredCashPower = Double(amountOfMoneyInCents) / 100
            if self.depositValue != nil {
               view.avaliableFunds = self.depositValue!.currentBalance ?? 0
            }else{
              view.avaliableFunds = 0
            }
			
			view.delegate = self
        }else if segue.identifier == "toSucessVC"{
            let view = segue.destination as! SuccessVC
            view.delegate = self
        }
    }
    
}
