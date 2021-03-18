//
//  WithDrawNoteVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 18/02/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class WithDrawNoteVC: UIViewController {
    
    @IBOutlet weak var amt: UILabel!
    
    var withDrawAmount: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amt.text = NumberToPrice(Value: withDrawAmount)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dismisAction(sender: UIButton){
        
        if let viewTab = self.view.window?.rootViewController as? UITabBarController{
            if let viewPageNav = viewTab.viewControllers![1] as? UINavigationController{
                if let viewPage = viewPageNav.viewControllers.first as? MoneyVC{
                    viewPage.viewDidLoad()
                    viewPage.dismiss(animated: true, completion: nil)
                }
                
                //self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
