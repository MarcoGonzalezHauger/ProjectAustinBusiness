//
//  TransactionListVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 12/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TransactionListVC: BaseVC,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var transactionListTV: UITableView!
    var transactionInfoList = [TransactionInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        transactionInfo { (objects, status, error) in
            
            if objects?.count != 0 {
                
                self.transactionInfoList.append(contentsOf: objects!)
                DispatchQueue.main.async {
                        self.transactionListTV.reloadData()
                }
                
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "transactionlist"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TransactionInfoTVCell
        let obj = self.transactionInfoList[indexPath.row]
        cell.acctID.text = obj.acctID
        cell.amount.text = obj.amount + " " + obj.currency
        cell.nameText.text = obj.firstName + " " + obj.lastName
        cell.bankType.text = obj.name
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 133
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let obj = self.transactionInfoList[indexPath.row]
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toTransactionDetails", sender: obj)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTransactionDetails" {
            let view = segue.destination as! TransactionDetailsVC
            view.transactionObject = sender as? TransactionInfo
        }
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
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
