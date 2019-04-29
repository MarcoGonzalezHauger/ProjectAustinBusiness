//
//  ProductsVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 4/26/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC
//

import UIKit

class ProductCell: UITableViewCell {
	@IBOutlet weak var productTitle: UILabel!
	@IBOutlet weak var productImage: UIImageView!
}

class ProductsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return global.products.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = shelf.dequeueReusableCell(withIdentifier: "productCellID") as! ProductCell
		cell.productTitle.text = global.products[indexPath.row].name
		if let urlstring = global.products[indexPath.row].image {
			if let imageurl = URL(string: urlstring) {
				cell.productImage.downloadedFrom(url: imageurl)
			}
		} else {
			cell.productImage = nil
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80
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
