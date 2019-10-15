//
//  PostDetailTableViewCell.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PostDetailTC: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var postTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
