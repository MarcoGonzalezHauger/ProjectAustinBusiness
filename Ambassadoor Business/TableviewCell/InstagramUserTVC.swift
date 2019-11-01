//
//  InstagramUserTVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 09/10/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InstagramUserTVC: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var offerStatus: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
