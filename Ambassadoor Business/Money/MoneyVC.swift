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

enum cellAction {
	case deposit, withdraw
}

protocol cellDelegate {
	func actionSent(action: cellAction)
}

struct Transaction {
	let description: String
	let details: AnyObject
	let time: String
	let amount: Double
    let type: String
    let status: String
    let userName: String
}

class BalanceCell: UITableViewCell {
	var delegate: cellDelegate?
	@IBOutlet weak var balanceLabel: UILabel!
	@IBAction func deposit(_ sender: Any) {
		delegate?.actionSent(action: .deposit)
	}
	@IBAction func withdraw(_ sender: Any) {
		delegate?.actionSent(action: .withdraw)
	}
}

class TransactionCell: UITableViewCell {
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var amountlabel: UILabel!
	@IBOutlet weak var shadowBox: ShadowView!
}

class MoneyVC: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionListener, cellDelegate {
	
	func actionSent(action: cellAction) {
		if action == .deposit {
			//depositVC must appear.
		} else if action == .withdraw {
			//withdraw VC must appear.
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return transactionHistory.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		if row == 0 {
			let cell = shelf.dequeueReusableCell(withIdentifier: "BalanceBox") as! BalanceCell
			cell.balanceLabel.text = NumberToPrice(Value: accountBalance, enforceCents: true)
			cell.delegate = self
			return cell
		} else {
			let cell = shelf.dequeueReusableCell(withIdentifier: "TransactionTrunk") as! TransactionCell
			let ThisTransaction = transactionHistory[row - 1]
			var isNegative = false
			let amt = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
            if ThisTransaction.type == "sale"{
				cell.descriptionLabel.text = "Deposited \(amt) into Ambassadoor"
				cell.amountlabel.text = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
            }else if ThisTransaction.type == "paid" {
                cell.descriptionLabel.text = "Spent \(amt) to distribute \"\(ThisTransaction.status)\""
				cell.amountlabel.text = "-\(NumberToPrice(Value: ThisTransaction.amount, enforceCents: true))"
				isNegative = true
            }else if ThisTransaction.type == "refund" {
				cell.descriptionLabel.text = "User Rejected \"\(ThisTransaction.status)\", You have been credited \(amt)"
				cell.amountlabel.text = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
            }else if ThisTransaction.type == "commissionrefund" {
                cell.descriptionLabel.text = "Ambassadoor Commission Refunded \"\(ThisTransaction.status)\", You have been credited \(amt)"
                cell.amountlabel.text = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
            }else if ThisTransaction.type == "postrefund" {
                cell.descriptionLabel.text = "Ambassadoor Refunded the single post, You have been credited \(amt)"
				cell.amountlabel.text = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
            }
			cell.shadowBox.borderColor = isNegative ? .systemRed : .systemGreen
			return cell
			
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		if row > 0 {
			
		}
		shelf.deselectRow(at: indexPath, animated: false)
	}
	
	func BalanceChange() {
		shelf.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
	}
	
	func TransactionHistoryChanged() {
		shelf.reloadData()
	}
	
	@IBOutlet weak var shelf: UITableView!
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let row = indexPath.row
		if row == 0 {
			return 230
		}
		if row == transactionHistory.count {
			return 90
		} else {
			return 80
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDeepositDetails), name: Notification.Name.init(rawValue: "reloadDeposit"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        if global.launchWay == "shortcut"{
//
//        //getCurrentCompanyUser(userID: (Auth.auth().currentUser?.uid)!) { (companyUser, error) in
//            getDepositDetails(companyUser: (Auth.auth().currentUser?.uid)!) { (deposit, status, error) in
//
//                transactionHistory.removeAll()
//
//
//                if status == "success" {
//                    accountBalance = deposit!.currentBalance!
//                    for value in deposit!.depositHistory! {
//
//                        if let valueDetails = value as? NSDictionary {
//
//                            transactionHistory.append(Transaction(description: "", details: valueDetails["cardDetails"] as AnyObject, time: valueDetails["updatedAt"] as! String, amount: Double(valueDetails["amount"] as! String)!, type: valueDetails["type"] as! String, status: valueDetails["status"] as? String ?? "", userName: valueDetails["userName"] as? String ?? ""))
//                        }
//                    }
//                    //transactionDelegate = self
//                    DispatchQueue.main.async(execute: {
//                        self.shelf.delegate = self
//                        self.shelf.dataSource = self
//                        self.shelf.reloadData()
//                    })
//                }
//
//            }
//
//        }else{
        
        self.getDeepositDetails()
//        }
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
