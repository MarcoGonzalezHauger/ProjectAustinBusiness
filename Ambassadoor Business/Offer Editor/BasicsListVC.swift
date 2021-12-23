//
//  BasicsListVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class BasicsCell: UITableViewCell {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var cmyName: UILabel!
    
    /// set basic business details to BasicsCell cell fields.
    var basic: BasicBusiness?{
        didSet{
            if let basicBusiness = basic{
                if let url = URL.init(string: basicBusiness.logoUrl){
                    self.logo.downloadedFrom(url: url)
                }
                self.cmyName.text = basicBusiness.name
            }
            
        }
    }
}

class BasicsListVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var basicsList: UITableView!
    
    var draftOffer: DraftOffer?
    
    var reloadBusiness: BusinessDelegate?
    
    var currentCompanies = [BasicBusiness]()

    
    /// Viewcontroller life cycle. Filter valid businesses
    override func viewDidLoad() {
        super.viewDidLoad()
        let filtered = MyCompany.basics.filter { (basic) -> Bool in
            return !basic.flags.contains("isDeleted") && !basic.flags.contains("isInvisible")
        }
        self.currentCompanies.append(contentsOf: filtered)
        self.setTableViewSource()
        // Do any additional setup after loading the view.
    }
    
    /// Initialise basicsList table datasource and delegate
    func setTableViewSource() {
        self.basicsList.delegate = self
        self.basicsList.dataSource = self
    }
    //MARK: - Comapny list UITableView Delegate and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentCompanies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "basic"
        let cell = self.basicsList.dequeueReusableCell(withIdentifier: identifier) as! BasicsCell
        let data = self.currentCompanies[indexPath.row]
        cell.basic = data
        if data.basicId == draftOffer?.basicId {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
		return 86.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let data = self.currentCompanies[indexPath.row]
        draftOffer?.basicId = data.basicId
        self.basicsList.reloadData()
    }
    
    
    /// Check user if selected any business. Dismiss Current View Controller
    /// - Parameter sender: UIButton referrance
    @IBAction func doneAction(sender: UIButton){
        if draftOffer?.basicId == nil || draftOffer?.basicId == "" {
            self.showAlertMessage(title: "Alert", message: "Please choose the company") {
            }
            return
        }
        self.reloadBusiness!.reloadBusiness()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /// Dismiss current viewcontroller
    /// - Parameter sender: UIButton referrance
    @IBAction func dismissAction(sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
    }

}
