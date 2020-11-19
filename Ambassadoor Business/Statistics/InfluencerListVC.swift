//
//  InfluencerListVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 19/11/20.
//  Copyright © 2020 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class InfluencerListCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
}

class InfluencerListVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    
    var acceptedUserList = [User]()
    @IBOutlet weak var influencerListTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acceptedUserList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "influencer"
        let cell = influencerListTable.dequeueReusableCell(withIdentifier: identifier) as! InfluencerListCell
        let user = acceptedUserList[indexPath.row]
        cell.name.text = user.name
        cell.userName.text = "@\(user.username)" 
        if let profileUrl = user.profilePicURL{
            cell.userImage.sd_setImage(with: URL.init(string: profileUrl), placeholderImage: UIImage(named: "defaultProduct"))
        }else{
            cell.userImage.image = UIImage(named: "defaultProduct")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.influencerListTable.deselectRow(at: indexPath, animated: true)
        let ThisUser = acceptedUserList[indexPath.row]
        let user = ThisUser.username //Whatever you want // open user instagram page
        let instaURL = URL(string: "instagram://user?username=\(user)")!
        let sharedApps = UIApplication.shared
        if sharedApps.canOpenURL(instaURL) {
        sharedApps.open(instaURL) } else {
        sharedApps.open(URL(string: "https://instagram.com/\(user)")!) }
    }
    
    @IBAction func dismissAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
