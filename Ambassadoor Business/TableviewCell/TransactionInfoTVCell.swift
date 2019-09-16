//
//  TransactionInfoTVCell.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 12/09/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class TransactionInfoTVCell: UITableViewCell {
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var acctID: UILabel!
    @IBOutlet weak var bankType: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var arrowButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
