//
//  AccountInfoVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 16/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class AccountInfoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.segueToWithdraw), name: Notification.Name("reloadbanklist"), object: nil)
        // Do any additional setup after loading the view.
		
		
    }
    
    /// Check if user already added stripe account. if true, redirect to account page otherwise connect stripe page
    /// - Parameter gesture: Gesture referrance
    @IBAction func showStripeAccount(gesture: UIGestureRecognizer){
        if MyCompany.finance.hasStripeAccount {
            self.performSegue(withIdentifier: "fromAccountInfoToWithdraw", sender: self)
        }else{
            self.performSegue(withIdentifier: "fromAccountToStripe", sender: self)
        }
        
    }
    
    @objc func segueToWithdraw(notification: Notification){
        
            DispatchQueue.main.async {
            var navigationArray = self.navigationController!.viewControllers // To get all UIViewController stack as Array
            navigationArray.remove(at: navigationArray.count - 1) // To remove previous UIViewController
            self.navigationController?.viewControllers = navigationArray
                
            self.performSegue(withIdentifier: "fromAccountInfoToWithdraw", sender: self)
            
            }
        
        
    }
    
    
    /// Dismiss current viewcontroller
    /// - Parameter _sender: UIButton referrance
    @IBAction func closeAction(_sender: Any){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
    }

}
