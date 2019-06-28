//
//  ProductsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC
//

import UIKit

protocol ProductDelegate {
	func WasSaved(index: Int) -> ()
}

class ProductCell: UITableViewCell {
	@IBOutlet weak var productTitle: UILabel!
	@IBOutlet weak var productImage: UIImageView!
}

class ProductsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, ProductDelegate {
	
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
        if let product_image = global.products[productIndex].image {
            cell.productImage.image = product_image
        } else {
            cell.productImage.image = UIImage.init(named: "defaultProduct")
        }
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
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
            global.products.insert(Product.init(dictionary: ["name": "", "price": 0.0, "buy_url": "", "color": "", "product_ID": ""]), at: 0)
			shelf.insertRows(at: [IndexPath(row: 1, section: 0)], with: .top)
			let productindex = 0
			let product = global.products[productindex]
			passProduct = product
			passIndex = productindex
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
        // let fakeproduct = GetFakeProducts()
        DispatchQueue.main.async {
            getAllProducts(completion: { (products) in
                debugPrint(products)
                for product in products {
                    getImage(type: "product", id: product.product_ID!, completed: { (image) in
                        product.image = image
                    })
                }
                global.products = products
				self.shelf.reloadData()
            })
        }
		shelf.delegate = self
		shelf.dataSource = self
    }

}
