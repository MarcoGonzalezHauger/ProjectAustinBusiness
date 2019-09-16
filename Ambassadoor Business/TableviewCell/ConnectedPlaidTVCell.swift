//
//  ConnectedPlaidTVCell.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 07/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ConnectedPlaidTVCell: UITableViewCell {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var acctIDText: UILabel!
    @IBOutlet weak var withdrawButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
