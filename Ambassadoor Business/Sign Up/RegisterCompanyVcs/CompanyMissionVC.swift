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
    @IBOutlet weak var missionShadow: ShadowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textView: missionText)
        checkIfeverthingEntered = false
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        scroll.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    @objc func dismissKeyboard() {
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        scroll.endEditing(true)
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
            MakeShake(viewToShake: self.missionShadow)
            // self.showAlertMessage(title: "Alert", message: "Please describe about your company in few lines") {}
        }
    }
    
    @IBAction func saveNextAction(sender: UIButton){
        self.checkIfMissionEntered()
    }
    
    @IBAction func backAction(sender: UIButton){
        self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag - 1), viewController: self)
    }
    
    override func doneButtonAction(){
        
        self.missionText.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        //self.checkIfMissionEntered()
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
