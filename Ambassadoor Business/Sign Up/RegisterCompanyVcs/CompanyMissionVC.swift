//
//  CompanyMissionVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class CompanyMissionVC: BaseVC, UITextViewDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var missionText: UITextView!
    var pageIdentifyIndexDelegate: PageIndexDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textView: missionText)
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.1) {
            let scrollPoint = CGPoint(x: 0, y: textView.superview!.frame.origin.y)
            self.scroll .setContentOffset(scrollPoint, animated: true)
        }
        
    }
    
    func checkIfMissionEntered() {
        if missionText.text?.count != 0{
            
            global.registerCompanyDetails.companyMission = missionText.text!
            self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag + 1), viewController: self)
        }else{
            self.showAlertMessage(title: "Alert", message: "Please describe about your company in few lines") {}
        }
    }
    
    override func doneButtonAction(){
        
        self.missionText.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        self.checkIfMissionEntered()
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
