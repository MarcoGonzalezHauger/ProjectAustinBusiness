//
//  LocationSelectorVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 24/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol LocationDelegate {
    func sendLocationObject(cell: LocationCell, index: Int)
}

class LocationCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var close: UIButton!
    
    var locationDelegate: LocationDelegate?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        locationDelegate?.sendLocationObject(cell: self, index: self.close.tag)
        return true
    }
}

class LocationSelectorVC: BaseVC, UITableViewDelegate, UITableViewDataSource, LocationDelegate {
    func sendLocationObject(cell: LocationCell, index: Int) {
        self.locations[index] = cell.locationText.text!
        self.locationList.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (locations.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "location"
        let cell = locationList.dequeueReusableCell(withIdentifier: identifier) as! LocationCell
        cell.locationText.text = locations[indexPath.row]
        cell.close.tag = indexPath.row
        cell.locationDelegate = self
        cell.close.addTarget(self, action: #selector(self.removelocation(sender:)), for: .touchUpInside)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 57.0
    }
    
    @IBOutlet weak var locationList: UITableView!
    
    var basicBusiness: BasicBusiness? = nil
    
    var locations = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        locations.append(contentsOf: basicBusiness!.locations)
        self.setTableData()
        // Do any additional setup after loading the view.
    }
    
    func setTableData() {
        self.locationList.delegate = self
        self.locationList.dataSource = self
        self.locationList.reloadData()
    }

    @IBAction func removelocation(sender: UIButton){
        let index = IndexPath.init(row: sender.tag, section: 0)
        self.locations.remove(at: sender.tag)
        locationList.deleteRows(at: [index], with: .right)
    }
    
    @IBAction func addLocationAction(sender: UIButton){
        self.locations.append("")
        self.locationList.reloadData()
    }
    
    @IBAction func backAction(sender: UIButton){
        for location in locations {
            if location == ""{
                let index = IndexPath.init(row: sender.tag, section: 0)
                let cell = self.locationList.cellForRow(at: index) as! LocationCell
                MakeShake(viewToShake: cell)
                return
            }
        }
        basicBusiness?.locations = locations
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
