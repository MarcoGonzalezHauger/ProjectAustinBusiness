//
//  UIViewExtension.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 23/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

public extension UIView {

//    @IBInspectable
//    var cornerRadius1: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//        }
//    }

//    @IBInspectable
//    var borderWidth: CGFloat {
//        get {
//            return layer.borderWidth
//        }
//        set {
//            layer.borderWidth = newValue
//        }
//    }
//
//    @IBInspectable
//    var borderColor: UIColor? {
//        get {
//            if let color = layer.borderColor {
//                return UIColor(cgColor: color)
//            }
//            return nil
//        }
//        set {
//            if let color = newValue {
//                layer.borderColor = color.cgColor
//            } else {
//                layer.borderColor = nil
//            }
//        }
//    }
//
//    @IBInspectable
//    var shadowRadius: CGFloat {
//        get {
//            return layer.shadowRadius
//        }
//        set {
//            layer.shadowRadius = newValue
//        }
//    }
//
//    @IBInspectable
//    var shadowOpacity: Float {
//        get {
//            return layer.shadowOpacity
//        }
//        set {
//            layer.shadowOpacity = newValue
//        }
//    }
//
//    @IBInspectable
//    var shadowOffset: CGSize {
//        get {
//            return layer.shadowOffset
//        }
//        set {
//            layer.shadowOffset = newValue
//        }
//    }
//
//    @IBInspectable
//    var shadowColor: UIColor? {
//        get {
//            if let color = layer.shadowColor {
//                return UIColor(cgColor: color)
//            }
//            return nil
//        }
//        set {
//            if let color = newValue {
//                layer.shadowColor = color.cgColor
//            } else {
//                layer.shadowColor = nil
//            }
//        }
//    }
}

    extension UIViewController {
    //    class func getIdentifier() -> String {
    //        let className = NSStringFromClass(self).components(separatedBy: ".").last!
    //        return className.lowercaseFirst
    //    }
        
        
        func showStandardAlertDialog(title: String = "Error", msg: String = "An unhandled error occurred.", handler: ((UIAlertAction) -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: handler))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        func showStandardAlertDialogWithMultipleAction(title: String = "Error", msg: String = "An unhandled error occurred.",titles: [String], handler: ((UIAlertAction) -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
            
            for title in titles {
                alert.addAction(UIAlertAction(title: title, style: UIAlertAction.Style.default, handler: handler))
            }
            
    //        alert.addAction(UIAlertAction.init(title: "Instagram Creator Account", style: UIAlertAction.Style.default, handler: { (action) in
    //
    //            if let url = URL(string: "https://help.instagram.com/2358103564437429") {
    //                UIApplication.shared.open(url)
    //            }
    //
    //        }))
    //        alert.addAction(UIAlertAction.init(title: "Instagram Business Account", style: UIAlertAction.Style.default, handler: { (action) in
    //
    //            if let url = URL(string: "https://help.instagram.com/502981923235522?helpref=hc_fnav") {
    //                UIApplication.shared.open(url)
    //            }
    //
    //        }))
            //alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.destructive, handler: handler))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        func performDismiss()  {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        func poptoRoot() {
            if let nav = self.navigationController {
                nav.popToRootViewController(animated: true)
            }
        }
        
        
        func toggleUserInteraction(_ enable: Bool) {
            if let activeView = navigationController?.view ?? view {
                activeView.isUserInteractionEnabled = enable
            }
        }
        
    }

