//
//  StandardNC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import UIKit

protocol NCDelegate {
	func shouldAllowBack() -> Bool
}

/// Custom UINavigationController
class StandardNC: UINavigationController, UIGestureRecognizerDelegate {
	
	var tempDelegate: NCDelegate?
	
    
    /// set interactivePopGestureRecognizer delegate
	override func viewDidLoad() {
		super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
//  UIGestureRecognizerDelegate method. if view controller more than one. check if NCDelegate instance created. if created, return shouldAllowBack method(returnd true or false based on user intraction). otherwise dismiss current view controller.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool{
        if(self.viewControllers.count > 1){
            if let td = tempDelegate {
                return td.shouldAllowBack()
            }
            return true
        } else {
            self.dismiss(animated: true, completion: nil)
            return false
        }
        
    }
    
    
}
