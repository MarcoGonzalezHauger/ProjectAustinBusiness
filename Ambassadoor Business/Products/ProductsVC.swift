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
		let productindex = indexPath.row - 1
		let cell = shelf.dequeueReusableCell(withIdentifier: "productCellID") as! ProductCell
		cell.productTitle.text = global.products[productindex].name == "" ? "(no name)" : global.products[productindex].name
		if let urlstring = global.products[productindex].image {
			if let imageurl = URL(string: urlstring) {
				cell.productImage.downloadedFrom(url: imageurl)
			} else {
				cell.productImage.image = UIImage.init(named: "defaultProduct")
			}
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
			global.products.insert(Product.init(image: nil, name: "", price: 0, buy_url: "", color: "", product_ID: ""), at: 0)
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
		let fakeproduct = [Product.init(image: "https://media.kohlsimg.com/is/image/kohls/2375536_Gray?wid=350&hei=350&op_sharpen=1", name: "Any Nike Shoe", price: 80, buy_url: "https://store.nike.com/us/en_us/pw/mens-shoes/7puZoi3", color: "Any", product_ID: ""),
						   Product.init(image: "https://ae01.alicdn.com/kf/HTB1_iYaljihSKJjy0Fiq6AuiFXat/Original-New-Arrival-NIKE-TEE-FUTURA-ICON-LS-Men-s-T-shirts-Long-sleeve-Sportswear.jpg_640x640.jpg", name: "Any Nike Shirt", price: 25, buy_url: "https://store.nike.com/us/en_us/pw/mens-tops-t-shirts/7puZobp", color: "Any", product_ID: ""),
						   Product.init(image: "https://s3.amazonaws.com/nikeinc/assets/60756/USOC_MensLaydown_2625x1500_hd_1600.jpg?1469461906", name: "Any Nike Product", price: 20, buy_url: "https://www.nike.com/", color: "Any", product_ID: ""),
						   Product.init(image: "https://s3.amazonaws.com/boutiika-assets/image_library/BTKA_1520271255702342_ddff2a8ce6a4e69bce5a8da0444a57.jpg", name: "Any of our shoes", price: 20, buy_url: "http://www.jmichaelshoes.com/shop/birkenstock-birkenstock-arizona-olive-bf-6991148", color: "Any", product_ID: "")
			
		]
		global.products = fakeproduct
		shelf.delegate = self
		shelf.dataSource = self
    }

}
