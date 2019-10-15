//
//  ProductListCell.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 16/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ProductListCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var selectImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
		self.selectionStyle = .none	
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
