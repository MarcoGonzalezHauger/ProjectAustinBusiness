//
//  BaseVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 23/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import Foundation

class DeviceManager {
    static let sharedInstance = DeviceManager()
    
    // Method to get Device Width
    func getDeviceWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Method to get Device Height
    func getDeviceHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
}

class BaseVC: UIViewController {
    
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    var activityIndicator: UIActivityIndicatorView!
    var activityIndicatorView: UIView!
    
    
    //Show Activity Indicator
    func showActivityIndicator() {
        if self.activityIndicatorView == nil {
            DispatchQueue.main.async(execute: {
                let xPos = DeviceManager.sharedInstance.getDeviceWidth()/2 - 25 //  - half of image size
                let yPos = DeviceManager.sharedInstance.getDeviceHeight()/2 - 25
                self.activityIndicatorView =
                    UIView(frame: CGRect(x: xPos, y: yPos, width: 50, height: 50))
                self.activityIndicatorView.alpha = 1
                self.activityIndicatorView.backgroundColor = UIColor.white
                let layer: CALayer = self.activityIndicatorView.layer
                layer.cornerRadius = 5.0
                
                self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
                self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                let transform: CGAffineTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.activityIndicator.transform = transform
                self.activityIndicatorView.addSubview(self.activityIndicator)
                self.activityIndicator .startAnimating()
                self.activityIndicator.color = UIColor.blue
                self.activityIndicatorView.isHidden = true
                self.view.addSubview(self.activityIndicatorView)
                self.activityIndicatorView.isHidden = false
            })
        }
        else {
            self.activityIndicatorView.removeFromSuperview()
        }
        
    }
    
    //Hide Activity Indicator
    func hideActivityIndicator() {
        if  self.activityIndicatorView != nil {
            DispatchQueue.main.async(execute: {
                if self.activityIndicator == nil {
                    
                }
                else{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    self.activityIndicator = nil
                    
                    self.activityIndicatorView .removeFromSuperview()
                    self.activityIndicatorView = nil
                }
            })
            
        }
    }
    
    //Method for Alert iew Controller
    func showAlertMessage(title: String, message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: {
                
            })
            completion()
            
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Method for Alert iew Controller
    func showAlertMessageForDestruction(title: String, message: String, cancelTitle: String, destructionTitle: String, completion: @escaping () -> Void, completionDestruction: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default) { (action) in
            completion()
        }
        
        let destructionAction = UIAlertAction(title: destructionTitle, style: .default) { (action) in
            
            completionDestruction()
        }
        destructionAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        alertController.addAction(cancelAction)
        alertController.addAction(destructionAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    @IBAction func popAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func instantiateToMainScreen() {
        self.appDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async(execute: {
            let instantiateViewController = self.mainStoryBoard.instantiateInitialViewController()
            self.appDelegate?.window?.rootViewController = instantiateViewController
        })
    }
    
    
    func addDoneButtonOnKeyboard(textView: UITextView)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace,done]
        //        items.addObject(flexSpace)
        //        items.addObject(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textView.inputAccessoryView = doneToolbar
        
        
    }
    
    @objc func doneButtonAction(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWasShown(notification : NSNotification) {
        
        
        
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
