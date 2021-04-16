//
//  FilterRadiousVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class ZipCell: UITableViewCell {
    @IBOutlet weak var locationText: UILabel!
    var zipcode: String?{
        didSet{
            self.locationText.text = "Location \(zipcode!)"
        }
    }
    
}

class FilterRadiousVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allZipCode.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "zipcode"
        let cell = locationList.dequeueReusableCell(withIdentifier: identifier) as! ZipCell
        cell.zipcode = self.allZipCode[indexPath.row]
        if self.selectedZip.contains(self.allZipCode[indexPath.row]) {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let zip = self.allZipCode[indexPath.row]
        let cell = self.locationList.cellForRow(at: indexPath) as! ZipCell
        cell.accessoryType = .checkmark
        self.selectedZip.append(zip)
        //self.locationList.reloadData()
        //self.getZipCodes(radius: Int(slider.value.rounded(.awayFromZero)), zip: zip)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let zip = self.allZipCode[indexPath.row]
        let cell = self.locationList.cellForRow(at: indexPath) as! ZipCell
        cell.accessoryType = .none
        if let index = self.selectedZip.index(of: zip){
            self.selectedZip.remove(at: index)
        }
        //self.locationList.reloadData()
    }
    
    func getZipCodes(radius: Int, zip: String) {
        self.filteredZips.removeAll()
        GetAllZipCodesInRadius(zipCode: zip, radiusInMiles: radius) { (returns, zip, radius) in
            if returns?.count != 0{
            self.filteredZips.append(contentsOf: returns!.keys)
            }
           
        }
    }
    
    @IBOutlet weak var locationList: UITableView!
    
    var allZipCode: [String] = [String]()
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var selectedMiles: UILabel!
    
    var selectedZip = [String]()
    
    var filteredZips = [String]()
    
    //var radiousFilteredDelegate: RadiousFilteredDelegate?
    
    var zipCollection: ZipcodeCollectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for basic in MyCompany.basics {
            allZipCode.append(contentsOf: basic.GetLocationZips())
        }
        allZipCode = removeDuplicates()
        self.setTableData()
        // Do any additional setup after loading the view.
    }
    
    func removeDuplicates() -> [String] {
        
        var unique = [String]()
        for zip in allZipCode {
            if !unique.contains(zip) {
                unique.append(zip)
            }
        }
        return unique
    }
    
    func setTableData() {
        self.locationList.delegate = self
        self.locationList.dataSource = self
        self.locationList.reloadData()
    }
    
    @IBAction func sliderChanged(sender: UISlider){
        self.selectedMiles.text = "\(Int(sender.value.rounded(.awayFromZero))) Miles"
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func UserFilterAction(sender: UIButton){
        var index = 0
        var returnData = [String]()
        for data in self.selectedZip {
            let zip = data
            let radius = (Int(self.slider.value.rounded(.awayFromZero)))
            GetAllZipCodesInRadius(zipCode: zip, radiusInMiles: radius) { (returns, zip, radius) in
                if let returns = returns {
                    returnData.append(contentsOf: returns.keys)
                }
                index += 1
                if index >= self.selectedZip.count {
                    //self.radiousFilteredDelegate?.radiousFilteredZipcodes(zipcodes: returnData)
                    self.zipCollection?.sendZipcodeCollection(zipcodes: returnData)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelAction(sender: UIButton){
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
