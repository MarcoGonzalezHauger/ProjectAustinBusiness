//
//  NewBasicBusinessView.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 16/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class NewBasicBusinessView: BaseVC {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var cmyName: UILabel!
    @IBOutlet weak var mission: UILabel!
    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var website: UIButton!
    
    
    var businessData: BasicBusiness? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBusinessData()
        // Do any additional setup after loading the view.
    }
    
    func setBusinessData() {
        if let basic = businessData{
            //backImage = nil
            if let url = URL.init(string: basic.logoUrl){
                self.backImage.downloadedFrom(url: url)
                self.logo.downloadedFrom(url: url, contentMode: .scaleAspectFill, makeImageCircular: true)
            }
            self.cmyName.text = basic.name
            self.mission.text = basic.mission
            self.website.setTitle(basic.website, for: .normal)
        }
    }
    
    @IBAction func openWebsite(button: UIButton){
        if let basic = businessData{
            let sharedApps = UIApplication.shared
            if let url = URL.init(string: basic.website){
                if sharedApps.canOpenURL(url) {
                sharedApps.open(url)
                }
            }
            
        }
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
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
