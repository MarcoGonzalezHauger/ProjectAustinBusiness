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

class BasicBusinessCell: UICollectionViewCell {
    
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var cmyName: UILabel!
    @IBOutlet weak var delBtn: UIButton!
    
}

class AddProfileCell: UICollectionViewCell {
    
}

class ProfilePickerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, reloadMyCompanyDelegate {
    func reloadMyCompany() {
        self.setCollectionDataSource()
    }
    
    @IBOutlet weak var basicBusinessList: UICollectionView!
    
    @IBOutlet weak var removeBtn: UIButton!
    
    var isDeleteHidden = true
    
    var filteredArray = [BasicBusiness]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setCompanyTabBarItem()
        self.setCollectionDataSource()
        // Do any additional setup after loading the view.
    }
    
    func setCollectionDataSource() {
        filteredArray = MyCompany.basics.filter { (basic) -> Bool in
            return !basic.flags.contains("isDeleted") && !basic.flags.contains("isInvisible")
        }
        self.basicBusinessList.delegate = self
        self.basicBusinessList.dataSource = self
        self.basicBusinessList.reloadData()
    }
    
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
            cell.companyLogo.downloadedFrom(url: url)
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
        if indexPath.row == (filteredArray.count) {
            self.performSegue(withIdentifier: "toAddBasicVC", sender: self)
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
    
    @IBAction func removeBusinessAction(sender: UIButton){
        if !isDeleteHidden{
            isDeleteHidden = true
            self.basicBusinessList.reloadData()
            self.removeBtn.setTitle("Remove a Business", for: .normal)
        }else{
            isDeleteHidden = false
            self.basicBusinessList.reloadData()
            self.removeBtn.setTitle("Done Editing", for: .normal)
        }
    }
    
    func reloadCollection() {
        self.basicBusinessList .performBatchUpdates({
            self.basicBusinessList.reloadData()
        }) { (status) in
            
        }
    }
    
    @IBAction func updateBasicBusiness(button: UIButton) {
        
        let basic = self.filteredArray[button.tag]
        
        let index = MyCompany.basics.lastIndex { (basicData) -> Bool in
            return basic.basicId == basicData.basicId
        }
        
        if index == nil {
           return
        }
        
        MyCompany.basics[index!].AddFlag("isDeleted")
        MyCompany.basics[index!].AddFlag("isInvisible")
        
        MyCompany.UpdateToFirebase { (error) in
            DispatchQueue.main.async {
                self.basicBusinessList.reloadData()
            }
        }
                
    }
    
    func setCompanyTabBarItem() {
        guard let myCompany = MyCompany.basics.first else {return}
        let logo = myCompany.logoUrl
        downloadImage(logo) { (image) in
            DispatchQueue.main.async {
                let size = CGSize.init(width: 32, height: 32)
                
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                
                UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
                image?.draw(in: rect)
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if var image = newImage {
                    print(image.scale)
                    image = makeImageCircular(image: image)
                    print(image.scale)
                    self.tabBarController?.viewControllers?.first?.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
                }
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? AddBasicBusinessVC{
            view.reloadDelegate = self
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
