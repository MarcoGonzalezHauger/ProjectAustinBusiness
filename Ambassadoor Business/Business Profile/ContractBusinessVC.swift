//
//  ContractBusinessVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 16/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ContractBusinessVC: BaseVC {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var cmyName: UILabel!
    @IBOutlet weak var mission: UILabel!
    
    var businessData: BasicBusiness? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBusinessData()
        // Do any additional setup after loading the view.
    }
    
    func setBusinessData() {
        if let basic = businessData{
            if let url = URL.init(string: basic.logoUrl){
                self.logo.downloadedFrom(url: url, contentMode: .scaleAspectFill, makeImageCircular: true)
            }
            self.cmyName.text = basic.name
            self.mission.text = basic.mission
        }
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.performDismiss()
    }

    @IBAction func expandAction(sender: UIButton){
        self.performSegue(withIdentifier: "toExpandView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? NewBasicBusinessView{
            view.businessData = self.businessData
        }
    }
    

}
