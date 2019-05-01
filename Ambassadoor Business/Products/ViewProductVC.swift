//
//  ViewProductVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/29/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC
//

import UIKit

class ViewProductVC: UIViewController, UITextViewDelegate {
	
	@IBOutlet weak var visitButton: UIButton!
	var ThisProduct: Product!
	var productIndex: Int!
	var delegate: ProductDelegate?
	
	@IBOutlet weak var productName: UITextField!
	@IBOutlet weak var productImage: UIImageView!
	@IBOutlet weak var productURL: UITextView!
	@IBOutlet weak var productViewURL: UIView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if let thisUrl = URL(string: ThisProduct.image ?? "") {
			productImage.downloadedFrom(url: thisUrl)
		} else {
			productImage.image = UIImage.init(named: "defaultProduct")
		}
		productName.text = ThisProduct.name
		if ThisProduct.name	== "" {
			productName.becomeFirstResponder()
		}
		productURL.text = ThisProduct.buy_url
		productURL.layer.borderColor = UIColor.gray.cgColor
		productURL.layer.borderWidth = 1
		productURL.layer.cornerRadius = 5
    }
	
	func isGoodUrl(url: String) -> Bool {
		if url == "" { return true }
		if let url = URL(string: url) {
			return UIApplication.shared.canOpenURL(url)
		} else {
			return false
		}
	}
	
	@IBAction func clicked(_ sender: Any) {
		productName.selectAll(nil)
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		}
		if text == " " {
			return false
		}
		return true
	}
	
	@IBAction func save(_ sender: Any) {
		if !isGoodUrl(url: productURL.text) {
			MakeShake(viewToShake: productViewURL)
			if productName.text == "" {
				MakeShake(viewToShake: productName, coefficient: -1)
			}
		} else {
			if productName.text == "" {
				MakeShake(viewToShake: productName, coefficient: -1)
			} else {
				let NewProduct = Product(image: ThisProduct.image, name: productName.text!, price: 0, buy_url: productURL.text == "" ? nil : productURL.text , color: "", product_ID: "")
				global.products[productIndex] = NewProduct
				delegate?.WasSaved(index: productIndex)
				dismissed(self)
			}
		}
	}
	
	@IBAction func visitWebPage(_ sender: Any) {
		let good = isGoodUrl(url: productURL.text)
		if let url = URL(string: productURL.text) {
			if good && productURL.text != "" {
				UIApplication.shared.open(url, options: [:])
			} else {
				MakeShake(viewToShake: productViewURL)
			}
		} else {
			MakeShake(viewToShake: productViewURL)
		}
	}
	
	func MakeShake(viewToShake thisView: UIView, coefficient: Float = 1) {
		let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
		animation.timingFunction = CAMediaTimingFunction(name: .linear)
		animation.duration = 0.6
		animation.values = [-20.0 * coefficient, 20.0 * coefficient, -20.0 * coefficient, 20.0 * coefficient, -10.0 * coefficient, 10.0 * coefficient, -5.0 * coefficient, 5.0 * coefficient, 0 ]
		thisView.layer.add(animation, forKey: "shake")
	}
	
	@IBAction func nextClicked(_ sender: Any) {
		productURL.becomeFirstResponder()
	}
	
	@IBAction func dismissed(_ sender: Any) {
		 self.navigationController?.popViewController(animated: true)
	}
}
