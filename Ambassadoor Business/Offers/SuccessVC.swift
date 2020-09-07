//
//  SuccessVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 01/06/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol dismissSuccessVC {
    func dismissedSuccess()
}

class SuccessVC: BaseVC {
    
    var delegate: dismissSuccessVC?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneAction(sender: UIButton){
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        setDepositDetails(userID: (Auth.auth().currentUser?.uid)!)
        self.dismiss(animated: true, completion: nil)
        delegate?.dismissedSuccess()
        //self.navigationController?.popToRootViewController(animated: true)
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
