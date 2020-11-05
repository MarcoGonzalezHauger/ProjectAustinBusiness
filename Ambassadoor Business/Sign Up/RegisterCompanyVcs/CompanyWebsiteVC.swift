//
//  CompanyWebsiteVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/09/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import WebKit

class CompanyWebsiteVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var websiteText: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var websiteShadow: ShadowView!
    
    var pageIdentifyIndexDelegate: PageIndexDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addDoneButtonOnKeyboard(textField: self.websiteText)
        
        // Do any additional setup after loading the view.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        scroll.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    @objc func dismissKeyboard() {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scroll.contentInset = contentInset
        scroll.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        self.checkIfWebsiteEntered()
        return true
    }
    
    func checkIfWebsiteEntered() {
        
        let thisUrl = GetURL()
        
        if thisUrl != nil{
            
            if thisUrl!.absoluteString == "http://www.com" || thisUrl!.absoluteString == "https://www.com"{
                
                MakeShake(viewToShake: self.websiteShadow)
                
            }else{
                
                if isGoodUrl(url: thisUrl?.absoluteString ?? "") && websiteText.text?.count != 0{
                    
                    global.registerCompanyDetails.companyWebsite = thisUrl!.absoluteString
                    self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag + 1), viewController: self)
                }else{
                    
                    MakeShake(viewToShake: self.websiteShadow)
                    //self.showAlertMessage(title: "Alert", message: "Please enter a valid website") {}
                }
                
            }
        
            
        }else{
            
            MakeShake(viewToShake: self.websiteShadow)
//            self.showAlertMessage(title: "Alert", message: "Please enter a valid website") {}
            
        }
        
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
        
        self.websiteText.resignFirstResponder()
        let scrollPoint = CGPoint(x: 0, y: 0)
        self.scroll .setContentOffset(scrollPoint, animated: true)
        
        //self.checkIfWebsiteEntered()
        
    }
    
    @IBAction func saveNextAction(sender: UIButton){
        self.checkIfWebsiteEntered()
    }
    
    @IBAction func backAction(sender: UIButton){
        self.pageIdentifyIndexDelegate?.PageIndex(index: (self.view.tag - 1), viewController: self)
    }
    
    @IBAction func edited(_ sender: Any) {
        updateBack()
    }
    
    func updateBack() {
        let thisUrl = GetURL()
        if global.registerCompanyDetails.companyWebsite != thisUrl?.absoluteString {
            if let url = thisUrl {
                webView.load(URLRequest(url: url))
                global.registerCompanyDetails.companyWebsite = url.absoluteString
            }
        }
    }
    
    func GetURL() -> URL? {
        var returnValue = websiteText.text!
        if !returnValue.lowercased().hasPrefix("http") {
            if !returnValue.lowercased().hasPrefix("www.") {
                returnValue = "http://www." + returnValue
			} else {
				returnValue = "http://" + returnValue
			}
        }
        return URL.init(string: returnValue)
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
