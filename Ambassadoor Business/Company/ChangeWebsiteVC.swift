//
//  ChangeWebsiteVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/22/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
import WebKit

protocol webChangedDelegate {
	func websiteChanged(_ newWebsite: String)
}

class ChangeWebsiteVC: BaseVC {

	var webChangedDelegate: webChangedDelegate?
	@IBOutlet weak var webTextView: UITextField!
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var doneButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		webTextView.text = toChangeTo
		updateBack()
		
        // Do any additional setup after loading the view.
    }
	
	var toChangeTo = ""
	
	func setDefaultUrl(_ url: String?) {
		toChangeTo = url ?? ""
		if toChangeTo.lowercased().hasPrefix("http://www.") {
			toChangeTo = String(toChangeTo.dropFirst(11))
		} else if toChangeTo.lowercased().hasPrefix("https://www.") {
			toChangeTo = String(toChangeTo.dropFirst(12))
		}
	}
	
	@IBAction func dismissButton(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func saveButtonPressed(_ sender: Any) {
        
        
        if !isGoodUrl(url: GetURL()!.absoluteString) || GetURL()!.absoluteString == "http://www.com" || GetURL()!.absoluteString == "https://www.com"{
            
           self.showAlertMessage(title: "Alert", message: "Please enter valid website") {
                          
           }
            
        }else{
            
            webChangedDelegate?.websiteChanged(GetURL()!.absoluteString)
                       dismiss(animated: true, completion: nil)
            
            
            
        }
	}
	
	@IBAction func donePressed(_ sender: Any) {
		webTextView.resignFirstResponder()
	}
	var loadedPage: String = ""
	
	@IBAction func edited(_ sender: Any) {
		updateBack()
	}
	
	func updateBack() {
		let thisUrl = GetURL()
		doneButton.isHidden = thisUrl == nil
        
		if loadedPage != thisUrl?.absoluteString {
			if let url = thisUrl {
				webView.load(URLRequest(url: url))
				loadedPage = url.absoluteString
			}
		}
        
        
        
	}
	
	func GetURL() -> URL? {
		var returnValue = webTextView.text!
		if !returnValue.lowercased().hasPrefix("http") {
			if !returnValue.lowercased().hasPrefix("www.") {
                
				returnValue = "http://www." + returnValue
            }
            else{
                returnValue = "http://" + returnValue
            }
		}
		return URL.init(string: returnValue)
	}
}
