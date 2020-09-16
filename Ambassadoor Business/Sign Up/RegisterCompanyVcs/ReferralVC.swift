//
//  ReferralVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ReferralVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var referralText: UITextField!
    
    var pageIdentifyIndexDelegate: PageIndexDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textField: self.referralText)
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.checkIfReferralApplied()
        return true
    }
    
    func checkIfReferralApplied() {
        
            global.registerCompanyDetails.referralCode = referralText.text!
            self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag + 1), viewController: self)
        
    }
    
    @IBAction func skipAction(sender: UIButton) {
        global.registerCompanyDetails.referralCode = referralText.text!
        self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag + 1), viewController: self)
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scroll.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scroll.contentInset = contentInset
        
    }
    

    override func doneButtonAction(){
        
        self.referralText.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        
        self.checkIfReferralApplied()
        
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
