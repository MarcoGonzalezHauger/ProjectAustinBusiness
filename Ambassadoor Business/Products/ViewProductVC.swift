//
//  ViewProductVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/29/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC
//

import UIKit

class ViewProductVC: UIViewController, UITextViewDelegate, ImagePickerDelegate {
	
	func imagePicked(image: UIImage?, imageUrl: String?) {
		if let image = image {
			productImage.image = image
		}
		if let imageUrl = imageUrl {
			productImageUrl = imageUrl
		}
	}
	
	
	@IBOutlet weak var visitButton: UIButton!
	var ThisProduct: Product!
	var productIndex: Int!
	var delegate: ProductDelegate?
	var productImageUrl: String?
	
	@IBOutlet weak var productName: UITextField!
	@IBOutlet weak var productImage: UIImageView!
	@IBOutlet weak var productURL: UITextView!
	@IBOutlet weak var productViewURL: UIView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		productURL.delegate = self
        if let product_ID = ThisProduct.product_ID {
            DispatchQueue.main.async {
                getImage(type: "product", id: product_ID, completed: { (image) in
                    self.productImage.image = image
                })
            }
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
                let productDictionary = ["name": productName.text!, "price": 0.0, "buy_url": productURL.text == "" ? nil : productURL.text , "color": ""] as [String : Any]
                CreateProduct(productDictionary: productDictionary, completed: { (product) in
                    uploadImage(image: self.productImage.image!, type: "product", id: product.product_ID!)
                    global.products[self.productIndex] = product
                    self.delegate?.WasSaved(index: self.productIndex)
                    self.dismissed(self)
                })
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let destination = segue.destination as? GetPictureVC {
			destination.delegate = self
		}
	}
	
	@IBAction func nextClicked(_ sender: Any) {
		productURL.becomeFirstResponder()
	}
	
	@IBAction func dismissed(_ sender: Any) {
		 self.navigationController?.popViewController(animated: true)
	}
}
