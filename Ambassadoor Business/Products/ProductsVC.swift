//
//  ProductsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC
//

import UIKit
import FirebaseAuth
import SDWebImage
import Firebase

protocol ProductDelegate {
	func WasSaved(index: Int) -> ()
}

class ProductCell: UITableViewCell {
	@IBOutlet weak var productTitle: UILabel!
	@IBOutlet weak var productImage: UIImageView!
}

class ProductsVC: BaseVC, UITableViewDelegate, UITableViewDataSource, ProductDelegate {
	
	@IBOutlet weak var loadingProducts: UIActivityIndicatorView!
	
	func WasSaved(index: Int) {
		shelf.reloadRows(at: [IndexPath(row: index + 1, section: 0)], with: .fade)
	}
	
	@IBOutlet weak var editButton: UIButton!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.products.count + 1
	}
	
	var passProduct: Product!
	var passIndex: Int!
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = shelf.dequeueReusableCell(withIdentifier: "newCell")!
			return cell
		}
        let productIndex = indexPath.row - 1
		let cell = shelf.dequeueReusableCell(withIdentifier: "productCellID") as! ProductCell
        debugPrint(global.products[productIndex])
		cell.productTitle.text = global.products[productIndex].name == "" ? "(no name)" : global.products[productIndex].name
        let url = URL.init(string: global.products[productIndex].image!)
        cell.productImage.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultProduct"))
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return 80 // + New Product
		}
		return 100
	}
	
	var isEdit = false
	
	@IBAction func editProducts(_ sender: Any) {
		isEdit = !isEdit
		UIView.animate(withDuration: 0.5) {
			self.editButton.setTitle(self.isEdit ? "Done" : "Edit", for: .normal)
		}
		shelf.setEditing(isEdit, animated: true)
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		if indexPath.row != 0 {
			return .delete
		} else {
			return .none
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let user = Singleton.sharedInstance.getCompanyUser()
			let ref = Database.database().reference().child("products").child(Auth.auth().currentUser!.uid).child(user.companyID!).child(global.products[indexPath.row - 1].product_ID!)
			ref.removeValue()
			global.products.remove(at: indexPath.row - 1)
			shelf.deleteRows(at: [indexPath], with: .bottom)
			
		}
	}
	
	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		return indexPath.row != 0
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return indexPath.row != 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 0 {
//            global.products.insert(Product.init(dictionary: ["name": "", "price": 0.0, "buy_url": "", "color": "", "product_ID": "","image":""]), at: 0)
			//shelf.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
//			let productindex = 0
			//let product = global.products[productindex]
            let product = Product.init(dictionary: ["name": "", "price": 0.0, "buy_url": "", "color": "", "product_ID": "","image":""])
			passProduct = product
			//passIndex = productindex
			performSegue(withIdentifier: "toProductView", sender: self)
		} else {
			let productindex = indexPath.row - 1
			let product = global.products[productindex]
			passProduct = product
			passIndex = productindex
			performSegue(withIdentifier: "toProductView", sender: self)
		}
		shelf.deselectRow(at: indexPath, animated: true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "toProductView" {
			if let destination = segue.destination as? ViewProductVC {
				destination.ThisProduct = passProduct
				destination.productIndex = passIndex
				destination.delegate = self
			}
		}
	}

	@IBOutlet weak var shelf: UITableView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        shelf.delegate = self
        shelf.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let user = Singleton.sharedInstance.getCompanyUser()
        let path = Auth.auth().currentUser!.uid + "/" + user.companyID!
        getAllProducts(path: path) { (product) in
			self.loadingProducts.isHidden = true
            if product != nil {
				global.products.removeAll()
				global.products.append(contentsOf: product!)
				self.shelf.reloadData()
			}
            
        }
        
    }

}
