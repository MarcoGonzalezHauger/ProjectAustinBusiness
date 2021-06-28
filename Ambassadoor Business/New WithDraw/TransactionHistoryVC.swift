//
//  TransactionHistoryVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 18/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TransactionHistoryVC: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var shelf: UITableView!
    
    @IBOutlet weak var errorShadow: ShadowView!

    override func viewDidLoad() {
        super.viewDidLoad()
        if MyCompany.finance.log.count == 0 {
            errorShadow.isHidden = false
        }else{
            errorShadow.isHidden = true
            self.setTableData()
        }
        // Do any additional setup after loading the view.
    }
    
    func setTableData() {
        self.shelf.delegate = self
        self.shelf.dataSource = self
        self.shelf.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyCompany.finance.log.count
        //return GetTransactionHistory().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = shelf.dequeueReusableCell(withIdentifier: "TransactionTrunk") as! TransactionCell
        let log = MyCompany.finance.log[row]
        if log.type == "withdraw" {
            
            cell.amountlabel.text = "- \(NumberToPrice(Value: log.value))"
            cell.shadowBox.borderColor = .red
            cell.descriptionLabel.text = "Withdraw from Ambassadoor"
            
            
        }else if log.type == "creditCardDeposit"{
            cell.amountlabel.text = "+ \(NumberToPrice(Value: log.value))"
            cell.shadowBox.borderColor = .green
            cell.descriptionLabel.text = "Deposited with Stripe"
        }else if log.type == "admin"{
            cell.amountlabel.text = "\(NumberToPrice(Value: log.value))"
            cell.descriptionLabel.text = "Ambassadoor made through AMBVER"
            cell.shadowBox.borderColor = UIColor.init(named: "appcolor")!
        }else if log.type == "adminDeposit"{
            cell.amountlabel.text = "\(NumberToPrice(Value: log.value))"
            cell.descriptionLabel.text = "Ambassadoor Deposited with AMBVER"
            cell.shadowBox.borderColor = .green
        }else if log.type == "adminWithdraw"{
            cell.amountlabel.text = "\(NumberToPrice(Value: log.value))"
            cell.descriptionLabel.text = "Ambassadoor Withdraw from AMBVER"
            cell.shadowBox.borderColor = .red
        }else if log.type == "offer"{
            cell.amountlabel.text = "- \(NumberToPrice(Value: log.value))"
            cell.descriptionLabel.text = "Offer Distributed"
            cell.shadowBox.borderColor = .red
        }
        
        cell.dateText.text = log.time.toUString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
    
    @IBAction func cancelAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
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
