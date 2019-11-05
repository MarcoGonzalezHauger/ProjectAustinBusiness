//
//  CategoryHeaderView.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 07/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit
protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
    func selectAllSection(header: ExpandableHeaderView, section: Int, selected: Bool)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section: Int!
    var imageView: UIImageView?
    var selectAllBTN: UIButton?
    var selectAllBigBTN: UIButton?
    var bottomImage: UIImageView?
    var expandBool: Bool = false
    var selectedAll: Bool = false
    var selectedAllArray = [Int]()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    @IBAction func selectAllAction(sender: UIButton){
        
        let cell = sender.superview?.superview as! ExpandableHeaderView
        delegate?.selectAllSection(header: self, section: cell.section, selected: true)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    func customInit(title: String, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.textLabel?.text = title
        self.section = section
		
        self.backgroundColor = GetBackColor()
        self.backgroundView?.backgroundColor = GetBackColor()
        self.superview?.backgroundColor = GetBackColor()
        //        self.contentView.backgroundColor = UIColor(red: 0.0, green: 11.0/255.0, blue: 24.0/255.0, alpha: 1.0)
        
        self.contentView.backgroundColor = GetBackColor()
        
        self.delegate = delegate
    }
    
    override func layoutSubviews() {
		
        super.layoutSubviews()
        let imageName = "arrowDownExpand"
        _ = UIImage(named: imageName)
        imageView = UIImageView()
        //imageView = UIImageView(image: image!)
        if expandBool {
            let imageName = "arrowUp"
            let image = UIImage(named: imageName)
            imageView = UIImageView(image: image!)
            imageView?.frame = CGRect(x: self.contentView.frame.width-40, y: 20, width: 30, height: 26)
        }
        else {
            let imageName = "arrowDownExpand"
            let image = UIImage(named: imageName)
            imageView = UIImageView(image: image!)
            imageView?.frame = CGRect(x: self.contentView.frame.width-40, y: 20, width: 30, height: 26)
        }
        
        imageView?.backgroundColor = GetBackColor()
        //imageView?.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView!)
        
        //let image = UIImage(named: imageName)
		//selectAllBTN = (image: image!)
		if selectedAll {
			selectAllBTN = UIButton()
			selectAllBTN?.frame = CGRect(x: self.contentView.frame.width-80, y: 20, width: 25, height: 25)
			selectAllBTN?.backgroundColor = UIColor.clear
			selectAllBTN?.setBackgroundImage(UIImage(named: "tick"), for: .normal)
			selectAllBTN?.addTarget(self, action: #selector(selectAllAction(sender:)), for: .touchUpInside)
			self.contentView.addSubview(selectAllBTN!)
		}else{
			selectAllBTN = UIButton()
			selectAllBTN?.frame = CGRect(x: self.contentView.frame.width-80, y: 20, width: 25, height: 25)
			selectAllBTN?.backgroundColor = UIColor.clear
			selectAllBTN?.setBackgroundImage(UIImage(named: "square"), for: .normal)
			selectAllBTN?.addTarget(self, action: #selector(selectAllAction(sender:)), for: .touchUpInside)
			self.contentView.addSubview(selectAllBTN!)
		}
        
        if selectedAll {
            selectAllBigBTN = UIButton()
            selectAllBigBTN?.frame = CGRect(x: self.contentView.frame.width-100, y: 0, width: 45, height: self.contentView.frame.height)
            selectAllBigBTN?.backgroundColor = UIColor.clear
            //selectAllBigBTN?.setBackgroundImage(UIImage(named: "tick"), for: .normal)
            selectAllBigBTN?.addTarget(self, action: #selector(selectAllAction(sender:)), for: .touchUpInside)
            self.contentView.addSubview(selectAllBigBTN!)
        }else{
            selectAllBigBTN = UIButton()
            selectAllBigBTN?.frame = CGRect(x: self.contentView.frame.width-100, y: 0, width: 45, height: self.contentView.frame.height)
            selectAllBigBTN?.backgroundColor = UIColor.clear
            //selectAllBTN?.setBackgroundImage(UIImage(named: "square"), for: .normal)
            selectAllBigBTN?.addTarget(self, action: #selector(selectAllAction(sender:)), for: .touchUpInside)
            self.contentView.addSubview(selectAllBigBTN!)
        }
		
        bottomImage = UIImageView()
        bottomImage?.frame = CGRect(x: 0, y: self.contentView.frame.height-1, width: self.contentView.frame.width, height: 1)
        bottomImage?.alpha = 1.0
        bottomImage?.backgroundColor = GetBackColor()
        self.contentView.addSubview(bottomImage!)
        
        
        self.textLabel?.textColor = GetForeColor()
        self.textLabel?.backgroundColor = GetBackColor()
        self.backgroundColor = GetBackColor()
        //self.backgroundView?.backgroundColor = UIColor.clear
        self.backgroundView?.backgroundColor = UIColor(red: 0, green: 25.0/255.0, blue: 39.0/255.0, alpha: 0.5)
        //UIColor(red: 24.0/255.0, green: 129.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        // UIColor(red: 0, green: 25.0/255.0, blue: 39.0/255.0, alpha: 0.5) - light black
        //self.superview?.backgroundColor = UIColor.clear
        //self.contentView.backgroundColor = UIColor.clear
    }
    
    
}
