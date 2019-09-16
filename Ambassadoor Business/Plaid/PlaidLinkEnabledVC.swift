//
//  PlaidLinkEnabledVC.swift
//  Ambassadoor
//
//  Created by K Saravana Kumar on 22/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import LinkKit


class PlaidLinkEnabledVC: BaseVC, PLKPlaidLinkViewDelegate {
    
    func handleSuccessWithToken(_ publicToken:String, institutionName:String, institutionID:String, acctID:String, acctName:String, metadata:[String:Any]?){
        
        NSLog("metadata: \(metadata ?? [:])")
        
    }
    
    

    func handleError(_ error:Error?, metadata:[String:Any]?){
        
//        self.showStandardAlertDialog(title: "Error", msg: (error?.localizedDescription)!)
        
    }
    
    func handleExitWithMetadata(_ metadata:[String:Any]?){
        
        let alert = UIAlertController(title: "Alert", message: "Sorry, We could not process your bank connection at this time. Please try again later.", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
        }))
        
        if let status = metadata!["status"] as? String {
            
            if status == "connected" {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func presentPlaid(animated:Bool = true){
        // With custom configuration
        let linkConfiguration = PlaidHelper.linkConfiguration
        
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: self)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        DispatchQueue.main.async(execute: {
        self.present(linkViewController, animated: animated)
        })
    }
    
    //MARK: Plaid Delegates Method
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            var acctID: String = ""
            var acctName: String = ""
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            let institutionObject = metadata!["institution"] as! NSDictionary
            let institutionName = institutionObject["name"] as! String
            let institutionID = institutionObject["institution_id"] as! String
            if let accountArray = metadata!["accounts"] as? NSArray{
                if let accountDictionary = accountArray[0] as? NSDictionary{
                    acctID = accountDictionary["id"] as! String
                    acctName = accountDictionary["name"] as! String
                    
                }
                
            }
            self.handleSuccessWithToken(publicToken,institutionName: institutionName,institutionID: institutionID, acctID: acctID, acctName: acctName, metadata: metadata)
        }
    }
    
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                self.handleError(error, metadata: metadata)
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
                self.handleExitWithMetadata(metadata)
            }
        }
    }

}
