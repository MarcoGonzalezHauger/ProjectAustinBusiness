//
//  AddPostTC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol deleteDelegate {
	func delete(_ at: Int)
}

class AddPostTC: UITableViewCell {
    
    @IBOutlet weak var addPostImage: UIImageView!
    @IBOutlet weak var addPostText: UILabel!

	var delegate: deleteDelegate?
	var thisIndex = 0
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func deleteThis(_ sender: Any) {
		delegate?.delete(thisIndex)
	}
	
}
