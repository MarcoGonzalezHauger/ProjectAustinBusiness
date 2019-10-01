//
//  ViewProductVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/29/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC
//

import UIKit
import Firebase
import FirebaseAuth
import SDWebImage

class ViewProductVC: BaseVC, UITextViewDelegate, ImagePickerDelegate {
	
	func imagePicked(image: UIImage?, imageUrl: String?) {
		if  image != nil {
			productImage.image = image
            self.productURLstring = ""
//            self.showActivityIndicator()
//            uploadImageToFIR(image: self.productImage.image!, childName: "productImage", path: Auth.auth().currentUser!.uid) { (url, error) in
//                self.hideActivityIndicator()
//                if error == false {
//                  self.productURLstring = url
//                }
//            }
		}
//		if let imageUrl = imageUrl {
//			productImageUrl = imageUrl
//		}
	}
	
	
	@IBOutlet weak var visitButton: UIButton!
	var ThisProduct: Product!
	var productIndex: Int!
	var delegate: ProductDelegate?
	var productImageUrl: String?
    var productURLstring = ""
    
	
	@IBOutlet weak var productName: UITextField!
	@IBOutlet weak var productImage: UIImageView!
	@IBOutlet weak var productURL: UITextView!
	@IBOutlet weak var productViewURL: UIView!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		productURL.delegate = self
//        if let product_ID = ThisProduct.product_ID {
//            DispatchQueue.main.async {
//                getImage(id: product_ID, completed: { (image) in
//                    self.productImage.image = image
//                })
//            }
//		} else {
//			productImage.image = UIImage.init(named: "defaultProduct")
//		}
        if let url = URL.init(string: ThisProduct.image!) {
           self.productImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProduct"))
            self.productURLstring = ThisProduct.image!
        }else{
            self.productURLstring = ""
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
			if !isGoodUrl(url: productURL.text) {
				var newText = "http://" + productURL.text
				if isGoodUrl(url: newText) {
					productURL.text = newText
					return false
				}
				newText = "http://www." + productURL.text
				if isGoodUrl(url: newText) {
					productURL.text = newText
					return false
				}
			}
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
				//let imageID = uploadImage(image: self.productImage.image!)
                //uploadImageToFIR(image: self.productImage.image!, childName: , path: <#T##String#>, completion: <#T##(String, Bool) -> ()#>)
                if self.productImage.image != nil {
                if ThisProduct.product_ID == "" {
                    
                    self.showActivityIndicator()
                    let productDictionary = ["name": productName.text!, "price": 0.0, "buy_url": productURL.text == "" || productURL.text == nil ? nil : productURL.text! as Any! , "color": "", "image": self.productURLstring] as [String : Any]
                    CreateProduct(productDictionary: productDictionary, completed: { (product) in
                        let path = Auth.auth().currentUser!.uid + "/" + product.product_ID!
                        uploadImageToFIR(image: self.productImage.image!, childName: "products", path: path) { (url, error) in
                            self.hideActivityIndicator()
                            if error == false {
                                updateProductDetails(dictionary: ["image":url], productID: product.product_ID!)
                                let productDetails = product
                                productDetails.image = url
                                //global.products[self.productIndex] = productDetails
                                global.products.append(productDetails)
                                //self.delegate?.WasSaved(index: self.productIndex)
                                self.dismissed(self)
                            }
                        }
                        
                    })
                    
                }else{
                    
                    if self.productURLstring == "" {
                        
                        let path = Auth.auth().currentUser!.uid + "/" + ThisProduct.product_ID!
                        uploadImageToFIR(image: self.productImage.image!, childName: "products", path: path) { (url, error) in
                            self.hideActivityIndicator()
                            if error == false {
                                let productDictionary = ["name": self.productName.text!, "price": 0.0, "buy_url": self.productURL.text , "color": "", "image": url,"product_ID":self.ThisProduct.product_ID!] as [String : Any]
                                updateProductDetails(dictionary: productDictionary, productID: self.ThisProduct.product_ID!)
                                let productDetails = Product.init(dictionary: productDictionary)
                                global.products[self.productIndex] = productDetails
                                //global.products.append(productDetails)
                                self.delegate?.WasSaved(index: self.productIndex)
                                self.dismissed(self)
                            }
                        }
                        
                    }else{
                        let productDictionary = ["name": self.productName.text!, "price": 0.0, "buy_url": self.productURL.text, "color": "", "image": self.productURLstring,"product_ID":self.ThisProduct.product_ID!] as [String : Any]
                        updateProductDetails(dictionary: productDictionary, productID: self.ThisProduct.product_ID!)
                        let productDetails = Product.init(dictionary: productDictionary)
                        global.products[self.productIndex] = productDetails
                        //global.products.append(productDetails)
                        self.delegate?.WasSaved(index: self.productIndex)
                        self.dismissed(self)
                    }
                    
                    //updateProductDetails(dictionary: , productID: product.product_ID!)
                    
                }
            }else{
                
                    self.showAlertMessage(title: "Alert", message: "Please add your company logo") {
                        
                    }
            }

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
