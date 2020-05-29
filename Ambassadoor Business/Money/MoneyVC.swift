//
//  MoneyVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/8/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseInstanceID

struct Transaction {
	let description: String
	let details: AnyObject
	let time: String
	let amount: Double
    let type: String
    let status: String
    let userName: String
}

class TransactionCell: UITableViewCell {
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var amountlabel: UILabel!
	@IBOutlet weak var shadowBox: ShadowView!
}

class MoneyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionListener {
	
	@IBOutlet weak var balanceLabel: UILabel!
	@IBOutlet weak var balBox: ShadowView!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return transactionHistory.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		let cell = shelf.dequeueReusableCell(withIdentifier: "TransactionTrunk") as! TransactionCell
		let ThisTransaction = transactionHistory[row]
		
		
		
		
		
		let amt = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
		if ThisTransaction.type == "sale"{
			cell.descriptionLabel.text = "Deposited from Credit Card."
			cell.amountlabel.text = "+\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
            cell.shadowBox.borderColor = .systemGreen
		}else if ThisTransaction.type == "paid" || ThisTransaction.type == "distributed" {
			cell.descriptionLabel.text = "Distributed Offer: \"\(ThisTransaction.status)\""
			cell.amountlabel.text = "-\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
            cell.shadowBox.borderColor = .systemBlue
        }else if ThisTransaction.type == "withdraw"{
            cell.descriptionLabel.text = "Transferred to bank account."
            cell.amountlabel.text = "-\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
            cell.shadowBox.borderColor = .systemRed
        }
        else if ThisTransaction.type == "refund" {
			cell.descriptionLabel.text = "User Rejected \"\(ThisTransaction.status)\", You have been credited \(amt)"
			cell.amountlabel.text = "+\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
            cell.shadowBox.borderColor = .systemRed
		}else if ThisTransaction.type == "commissionrefund" {
			cell.descriptionLabel.text = "Ambassadoor Commission Refunded \"\(ThisTransaction.status)\", You have been credited \(amt)"
			cell.amountlabel.text = "+\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
		}else if ThisTransaction.type == "postrefund" {
			cell.descriptionLabel.text = "Ambassadoor Refunded the single post, You have been credited \(amt)"
			cell.amountlabel.text = "+\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
		}else if ThisTransaction.type == "referral" {
			cell.descriptionLabel.text = "Referral Fees from \(ThisTransaction.userName)."
            cell.amountlabel.text = "+\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
            cell.shadowBox.borderColor = .systemGreen
        }
		//cell.shadowBox.borderColor = .black // Refer to PowerPoint.
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		shelf.deselectRow(at: indexPath, animated: false)
	}
	
	func BalanceChange() {
		balanceLabel.text = NumberToPrice(Value: accountBalance, enforceCents: true)
	}
	
	func TransactionHistoryChanged() {
		shelf.reloadData()
	}
	
	@IBOutlet weak var shelf: UITableView!
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
	}
	
	let gradientLayer = CAGradientLayer()
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
		shelf.alwaysBounceVertical = false
		shelf.contentInset = UIEdgeInsets.init(top: 26, left: 0, bottom: 16, right: 0)
		
		var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

		gradientLayer.frame = CGRect(x: 0, y: shelf.frame.origin.y - 26.0, width: shelf.bounds.width - 5, height: 26.0)
		var backColor = GetBackColor()
		if #available(iOS 13.0, *) {
			backColor = .secondarySystemBackground
		}
		backColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		let toColor = UIColor.init(red: red, green: green, blue: blue, alpha: 0)
		
		gradientLayer.colors = [backColor.cgColor, toColor.cgColor]
		
		view.layer.addSublayer(gradientLayer)
		
		gradientLayer.zPosition = 1000
		balBox.layer.zPosition = 1001
        
        if transactionHistory.count != 0{
            transactionDelegate = self
            shownBefore = true
            accountBalance = global.accountBalance
            DispatchQueue.main.async(execute: {
                self.shelf.delegate = self
                self.shelf.dataSource = self
                self.shelf.reloadData()
            })
            
        }else{
            getDeepositDetails()
            
        }
		
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDeepositDetails), name: Notification.Name.init(rawValue: "reloadDeposit"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.getDeepositDetails()
    }
	
	var shownBefore = false
    
    @objc func getDeepositDetails() {
        
		if !shownBefore {
			accountBalance = 0.0
			shownBefore = true
		}
        let user = Singleton.sharedInstance.getCompanyUser()
        self.getDepositDetailsByUser(user: user)
    
    }
    
    func getDepositDetailsByUser(user: CompanyUser) {
        
        getDepositDetails(companyUser: (Auth.auth().currentUser?.uid)!) { (deposit, status, error) in
            
            if status == "success" {
                
                transactionHistory.removeAll()
                accountBalance = deposit!.currentBalance!
                setHapticMenu(companyUserID: (Auth.auth().currentUser?.uid)!, amount: accountBalance)
                for value in deposit!.depositHistory! {
                    
                    if let valueDetails = value as? NSDictionary {
                        
                        transactionHistory.append(Transaction(description: "", details: valueDetails["cardDetails"] as AnyObject, time: valueDetails["updatedAt"] as! String, amount: Double(valueDetails["amount"] as! String)!, type: valueDetails["type"] as! String, status: valueDetails["status"] as? String ?? "", userName: valueDetails["userName"] as? String ?? ""))
                    }
                }
                transactionDelegate = self
                DispatchQueue.main.async(execute: {
                    self.shelf.delegate = self
                    self.shelf.dataSource = self
                    self.shelf.reloadData()
                })
            }else{
                
                transactionDelegate = self
                DispatchQueue.main.async(execute: {
                    self.shelf.delegate = self
                    self.shelf.dataSource = self
                    self.shelf.reloadData()
                })
                
            }
            
        }

        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
    }

}
