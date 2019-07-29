//
//  YourCompany.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/2/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

protocol TransactionListener {
	func BalanceChange()
	func TransactionHistoryChanged()
}

var YourCompany: Company!

var transactionDelegate: TransactionListener?

var accountBalance: Double = 0 {
	didSet {
		transactionDelegate?.BalanceChange()
	}
}

var transactionHistory: [Transaction] = [] {
	didSet {
		transactionDelegate?.TransactionHistoryChanged()
	}
}
