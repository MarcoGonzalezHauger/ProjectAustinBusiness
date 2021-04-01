//
//  FilterByCityVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 31/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

@objc protocol CityCellDelegate {
    @objc optional func ZipCodeValid(zipObj: CityObject, cell: CityCell)
    @objc optional func Delete(zipObj: CityObject, cell: CityCell)
    @objc optional func SendCityObject(zipObj: [CityObject])
}

class CityCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var mappinImg: UIImageView!
    @IBOutlet weak var delBtn: UIButton!
    
    var cityDelegate: CityCellDelegate?
    
    var cityData: CityObject?{
        didSet{
            if let object = cityData{
                   self.cityText.text = object.city
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if cityText.text!.count != 0{
        let seperateData = cityText.text!.components(separatedBy: ",")
            if seperateData.count == 2 {
                self.fetchZipcodes(city: seperateData[0].trimmingCharacters(in: .whitespaces), state: seperateData[1].trimmingCharacters(in: .whitespaces))
            }else{
                self.mappinImg.tintColor = .red
            }
        }else{
            self.mappinImg.tintColor = .red
        }
        self.cityText.resignFirstResponder()
        return true
    }
    
    func fetchZipcodes(city: String, state: String) {
        GetZipCodeUsingCity(city: city, state: state) { (zipcodes) in
            
            if zipcodes != nil && zipcodes?.count != 0{
                DispatchQueue.main.async {
                    self.mappinImg.tintColor = .systemGreen
                    self.cityData?.city = "\(city),\(state)"
                    self.cityData?.zipcodes = zipcodes!
                    self.cityDelegate!.ZipCodeValid!(zipObj: self.cityData!, cell: self)
                }
            }else{
                DispatchQueue.main.async {
                self.cityText.text = ""
                MakeShake(viewToShake: self)
                self.mappinImg.tintColor = .red
                }
            }
            
        }
    }
    
    @IBAction func deleteCityAction(sender: UIButton){
        self.cityDelegate!.Delete!(zipObj: self.cityData!, cell: self)
    }
}

class FilterByCityVC: BaseVC, UITableViewDelegate, UITableViewDataSource, CityCellDelegate {
    func ZipCodeValid(zipObj: CityObject, cell: CityCell) {
        if let index = cityList.indexPath(for: cell){
            self.totalCityObjects[index.row] = zipObj
        }
        self.setTableSource()
    }
    
    func Delete(zipObj: CityObject, cell: CityCell) {
        if let index = cityList.indexPath(for: cell){
        self.totalCityObjects.remove(at: index.row)
        }
        self.setTableSource()
    }
    
    
    var totalCityObjects = [CityObject]()
    @IBOutlet weak var cityList: UITableView!
    
    var cityReturnDelegate: CityCellDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        totalCityObjects.append(CityObject.init(dictionary: [:]))
        self.setTableSource()
        // Do any additional setup after loading the view.
    }
    
    func setTableSource() {
        self.cityList.delegate = self
        self.cityList.dataSource = self
        self.cityList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCityObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "city"
        let cell = cityList.dequeueReusableCell(withIdentifier: identifier) as! CityCell
        
        let obj = self.totalCityObjects[indexPath.row]
        cell.cityData = obj
        cell.cityDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44.0
    }
    
    @IBAction func addNewCell(sender: UIButton) {
        
        for (index, city) in self.totalCityObjects.enumerated() {
            if city.city == "" {
                let indexpath = IndexPath.init(row: index, section: 0)
                if let cell = self.cityList.cellForRow(at: indexpath){
                MakeShake(viewToShake: cell)
                }
                self.showAlertMessage(title: "Alert", message: "Please add city in the empty field") {
                    
                }
                return
            }
        }
        
        totalCityObjects.append(CityObject.init(dictionary: [:]))
        self.setTableSource()
        
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func useFilterAction(sender: UIButton){
        for (index, city) in self.totalCityObjects.enumerated() {
            if city.city == "" {
                let indexpath = IndexPath.init(row: index, section: 0)
                if let cell = self.cityList.cellForRow(at: indexpath){
                MakeShake(viewToShake: cell)
                }
                self.showAlertMessage(title: "Alert", message: "Please add city in the empty field") {
                    
                }
                return
            }
        }
        
        self.cityReturnDelegate!.SendCityObject!(zipObj: self.totalCityObjects)
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
