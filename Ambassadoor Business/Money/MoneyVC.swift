//
//  MoneyVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/8/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC.
//

import UIKit

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
			cell.amountlabel.text = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
            if ThisTransaction.type == "sale"{
                let amt = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
			cell.descriptionLabel.text = "Despotied \(amt) into Ambassadoor"
            }else if ThisTransaction.type == "paid" {
                let amt = NumberToPrice(Value: ThisTransaction.amount, enforceCents: true)
                cell.descriptionLabel.text = "Paid \(amt) to \(ThisTransaction.status)"
            }
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
        self.getDeepositDetails()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDeepositDetails), name: Notification.Name.init(rawValue: "reloadDeposit"), object: nil)
    }
    
    @objc func getDeepositDetails() {
        let user = Singleton.sharedInstance.getCompanyUser()
        getDepositDetails(companyUser: user.userID!) { (deposit, status, error) in
            
            if status == "success" {
                
                transactionHistory.removeAll()
                accountBalance = deposit!.currentBalance!
                for value in deposit!.depositHistory! {
                    
                    if let valueDetails = value as? NSDictionary {
                        
                        transactionHistory.append(Transaction(description: "", details: valueDetails["cardDetails"] as AnyObject, time: valueDetails["updatedAt"] as! String, amount: Double(valueDetails["amount"] as! String)!, type: valueDetails["type"] as! String, status: "pending"))
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
