//
//  ProfilePickerVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 15/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol reloadMyCompanyDelegate {
    func reloadMyCompany()
}


/// Feature of the function is set company logo to image of profile tab.
/// - Parameter tab: UITabBarController referrance
func setCompanyTabBarItem(tab: UITabBarController) {
    
    let filtered = MyCompany.basics.filter { (basic) -> Bool in
        return !basic.flags.contains("isDeleted") && !basic.flags.contains("isInvisible")
    }
    
    if filtered.count == 0 {
        setTabImage(image: UIImage.init(named: "default")!, tab: tab)
        return
    }
    
    guard let myCompany = filtered.first else {return}
    let logo = myCompany.logoUrl
    downloadImage(logo) { (image) in
        if image != nil{
            setTabImage(image: image!, tab: tab)
        }else{
            setTabImage(image: UIImage.init(named: "default")!, tab: tab)
        }
    }
}

func setTabImage(image: UIImage, tab: UITabBarController) {
    DispatchQueue.main.async {
        let size = CGSize.init(width: 32, height: 32)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if var image = newImage {
            print(image.scale)
            image = makeImageCircular(image: image)
            print(image.scale)
            tab.viewControllers?.first?.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
        }
    }
}

class BasicBusinessCell: UICollectionViewCell {
    
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var cmyName: UILabel!
    @IBOutlet weak var delBtn: UIButton!
    
}

class AddProfileCell: UICollectionViewCell {
    
}

class ProfilePickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, reloadMyCompanyDelegate {
    func reloadMyCompany() {
        setCompanyTabBarItem(tab: self.tabBarController!)
        self.setCollectionDataSource()
    }
    
    @IBOutlet weak var basicBusinessList: UICollectionView!
    
    @IBOutlet weak var removeBtn: UIButton!
    
    var isDeleteHidden = true
    
    var filteredArray = [BasicBusiness]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setCompanyTabBarItem(tab: self.tabBarController!)
        self.setCollectionDataSource()
        
        // Do any additional setup after loading the view.
    }
    
    /// Filter valid campanies and reload basicBusinessList table.
    func setCollectionDataSource() {
        filteredArray = MyCompany.basics.filter { (basic) -> Bool in
            return !basic.flags.contains("isDeleted") && !basic.flags.contains("isInvisible")
        }
        self.basicBusinessList.delegate = self
        self.basicBusinessList.dataSource = self
        self.basicBusinessList.reloadData()
    }
    //MARK: - UICollectionview Delegate and Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                
        return (filteredArray.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == (filteredArray.count) {
            let cell : AddProfileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath) as! AddProfileCell
            return cell
        }
        
        let cell : BasicBusinessCell = collectionView.dequeueReusableCell(withReuseIdentifier: "basic", for: indexPath) as! BasicBusinessCell
        let basic = filteredArray[indexPath.row]
        if let url = URL.init(string: basic.logoUrl){
            cell.companyLogo.downloadedFrom(url: url, contentMode: .scaleAspectFill, makeImageCircular: true)
        }
        cell.cmyName.text = basic.name
        UIView.animate(withDuration: 1) {
            cell.delBtn.isHidden = self.isDeleteHidden
        }
        cell.delBtn.tag = indexPath.row
        cell.delBtn.addTarget(self, action: #selector(self.updateBasicBusiness(button:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isDeleteHidden{
            if indexPath.row == (filteredArray.count) {
                self.performSegue(withIdentifier: "toAddBasicVC", sender: nil)
            }else{
                let basic = filteredArray[indexPath.row]
                self.performSegue(withIdentifier: "toAddBasicVC", sender: basic)
            }
        }else{
            self.showStandardAlertDialog(title: "Alert", msg: "Please complete your editing") { (action) in
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let width = ((self.basicBusinessList.frame.size.width) / 2)
        return CGSize.init(width: width, height: 222.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0.0
    }
    
    
    /// Remove a business action. If isDeleteHidden is false, modification of the company list is done. so set first company basic id to activeBasicId of the user. update changes to firebase. reload tabbar and collectionview
    /// - Parameter sender: UIButton referrance
    @IBAction func removeBusinessAction(sender: UIButton){
        if !isDeleteHidden{
            isDeleteHidden = true
            self.removeBtn.setTitle("Remove a Business", for: .normal)
            setCompanyTabBarItem(tab: self.tabBarController!)
            //MyCompany.activeBasicId =
            MyCompany.activeBasicId = MyCompany.basics.filter { (basic) -> Bool in
                return !basic.checkFlag("isDeleted") || !basic.checkFlag("isInvisible")
                }.first!.basicId
            MyCompany.UpdateToFirebase { (error) in
                DispatchQueue.main.async {
                    self.setCollectionDataSource()
                }
            }
                        
        }else{
            isDeleteHidden = false
            self.basicBusinessList.reloadData()
            self.removeBtn.setTitle("Done Editing", for: .normal)
        }
    }
    
    /// reload collection view with animation
    func reloadCollection() {
        self.basicBusinessList .performBatchUpdates({
            self.basicBusinessList.reloadData()
        }) { (status) in
            
        }
    }
    
    
    /// Company delete action .Check if user has only one company (Because user must have atleast one company). If more than one company, Add isDeleted and isInvisible flags to that company.
    /// - Parameter button: UIButton referrance
    @IBAction func updateBasicBusiness(button: UIButton) {
        
        if self.filteredArray.count == 1 {
            self.showStandardAlertDialog(title: "Alert", msg: "Sorry!. You can delete if you have more than one company") { (action) in
                
            }
            return
        }
        
        let basic = self.filteredArray[button.tag]
        
        let index = MyCompany.basics.lastIndex { (basicData) -> Bool in
            return basic.basicId == basicData.basicId
        }
        
        if index == nil {
           return
        }
        
        MyCompany.basics[index!].AddFlag("isDeleted")
        MyCompany.basics[index!].AddFlag("isInvisible")
        
        self.setCollectionDataSource()
        
//        MyCompany.UpdateToFirebase { (error) in
//            DispatchQueue.main.async {
//                self.setCollectionDataSource()
//            }
//        }
                
    }
    
    
    
    /// Log out current user. remove all local data of the user. Redirect to sign in page.
    /// - Parameter sender: UIButton referrance
    @IBAction func signOutAction(sender: UIButton){
        
        MyCompany = nil
        UserDefaults.standard.removeObject(forKey: "userid")
        UserDefaults.standard.removeObject(forKey: "userPass")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UIApplication.shared.shortcutItems?.removeAll()
        let signInStoryBoard = UIStoryboard(name: "Onboarding", bundle: nil)
        let loginVC = signInStoryBoard.instantiateInitialViewController()
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDel.window?.rootViewController = loginVC
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? AddBasicBusinessVC{
            view.reloadDelegate = self
            view.isProfileSegue = true
            view.basicBusiness = sender == nil ? nil : (sender as! BasicBusiness)
        }
    }
    
//toAddBasicVC
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
