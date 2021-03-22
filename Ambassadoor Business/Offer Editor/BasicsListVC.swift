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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableViewSource()
        // Do any additional setup after loading the view.
    }
    
    func setTableViewSource() {
        self.basicsList.delegate = self
        self.basicsList.dataSource = self
        self.basicsList.reloadData()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MyCompany.basics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "basic"
        let cell = self.basicsList.dequeueReusableCell(withIdentifier: identifier) as! BasicsCell
        let data = MyCompany.basics[indexPath.row]
        cell.basic = data
        if data.basicId == draftOffer?.basicId {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 110.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let data = MyCompany.basics[indexPath.row]
        draftOffer?.basicId = data.basicId
//        let cell = basicsList.cellForRow(at: indexPath) as! BasicsCell
//        cell.accessoryType = .checkmark
        self.basicsList.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
//        let cell = basicsList.cellForRow(at: indexPath) as! BasicsCell
//        cell.accessoryType = .none
//    }
    
    @IBAction func doneAction(sender: UIButton){
        
        let index = MyCompany.drafts.lastIndex { (draft) -> Bool in
            return draft.draftId == self.draftOffer?.draftId
        }
        
        MyCompany.drafts[index!] = self.draftOffer!
        
        MyCompany.UpdateToFirebase { (errorFIB) in
            if !errorFIB{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
