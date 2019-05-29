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
	let details: String
	let time: Date
	let amount: Double
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
			
		} else if action == .withdraw {
			
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
			cell.descriptionLabel.text = ThisTransaction.description
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
		transactionDelegate = self
		shelf.delegate = self
		shelf.dataSource = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
    }

}
