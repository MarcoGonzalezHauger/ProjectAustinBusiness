//
//  NewDistributeVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/04/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewDistributeVC: BaseVC, changedDelegate {
    func changed() {
        //money.moneyValue = amountOfMoneyInCents
        amountOfMoneyInCents = money.moneyValue
    }
    
    
    @IBOutlet weak var money: MoneyField!
    
    var amountOfMoneyInCents: Int = 10000

    override func viewDidLoad() {
        super.viewDidLoad()
        money.changedDelegate = self
        money.moneyValue = amountOfMoneyInCents
        self.addDoneButtonOnKeyboard(textField: self.money)
        // Do any additional setup after loading the view.
    }
    
    func getDesiredCashPower() -> Double {
        return Double(amountOfMoneyInCents) / 100
    }
    
    @IBAction func DistributeOfferAction(sender: UIButton){
        if getDesiredCashPower() != 0 {
            let offerAmount = getDesiredCashPower()
                if offerAmount > 0 {
                    
                }
                
            }
    }
    
    override func doneButtonAction() {
        self.money.resignFirstResponder()
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
