//
//  PostDetailTableViewCell.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PostDetailTC: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
	@IBOutlet weak var postIndex: UILabel!
	@IBOutlet weak var colorBubble: ShadowView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func SetCell(number: Int, hash: String?) {
		postIndex.text = "\(number)"
		if let hash = hash {
			if hash == "" {
				postTitle.text = "Post \(number)"
			} else {
				postTitle.text = "#\(hash)"
			}
		} else {
			postTitle.text = "Post \(number)"
		}
		switch number {
		case 1: colorBubble.backgroundColor = .systemBlue
		case 2: colorBubble.backgroundColor = .systemYellow
		case 3: colorBubble.backgroundColor = .systemRed
		default: colorBubble.backgroundColor = .systemBlue
		}
	}

}
