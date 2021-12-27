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
}

class CityCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var mappinImg: UIImageView!
    @IBOutlet weak var delBtn: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var cityDelegate: CityCellDelegate?
    
    
    /// Set value to CityCell fields
    var cityData: CityObject?{
        didSet{
            if let object = cityData{
                   self.cityText.text = object.city
            }
        }
    }
    
    func textFieldDidChange(_ textfield: UITextField) {
        self.mappinImg.tintColor = .red
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.mappinImg.tintColor = .red
    }
    
    
    /// Return cityText text field. seperate city and state. Fetch zipcodes by state and city. change mappinImg color based on valid zipcode.
    /// - Parameter textField: UITextField referrance
    /// - Returns: true or false
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if cityText.text!.count != 0{
        let seperateData = cityText.text!.components(separatedBy: ",")
            if seperateData.count == 2 {
                self.fetchZipcodes(city: seperateData[0].trimmingCharacters(in: .whitespaces), state: seperateData[1].trimmingCharacters(in: .whitespaces))
            }else{
                self.mappinImg.tintColor = .red
                self.cityText.resignFirstResponder()
            }
        }else{
            self.mappinImg.tintColor = .red
            self.cityText.resignFirstResponder()
        }
        
        return true
    }
    
    /// Fetch zipcodes based on city and state using third party API.
    /// - Parameters:
    ///   - city: entered city
    ///   - state: entered state
    func fetchZipcodes(city: String, state: String) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        GetZipCodeUsingCity(city: city, state: state) { (zipcodes) in
            
            DispatchQueue.main.async {
                self.cityText.resignFirstResponder()
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
            
            if zipcodes != nil && zipcodes?.count != 0{
                DispatchQueue.main.async {
                    self.mappinImg.tintColor = .systemGreen
                    self.cityData?.city = "\(city), \(state)"
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
    
    
    /// Delete citytext cell. send cityobject referrance to CityCellDelegate method.
    /// - Parameter sender: UIButton reffeance.
    @IBAction func deleteCityAction(sender: UIButton){
        self.cityDelegate!.Delete!(zipObj: self.cityData!, cell: self)
    }
}

class FilterByCityVC: BaseVC, UITableViewDelegate, UITableViewDataSource, CityCellDelegate {
    
    
    /// CityCellDelegate delegate method
    /// - Parameters:
    ///   - zipObj: CityObject referrance
    ///   - cell: CityCell referrance
    func ZipCodeValid(zipObj: CityObject, cell: CityCell) {
        if let index = cityList.indexPath(for: cell){
            self.totalCityObjects[index.row] = zipObj
        }
        self.setTableSource()
    }
    
    /// CityCellDelegate delegate method. delete location cell by delegate cell referrance
    /// - Parameters:
    ///   - zipObj: CityObject referrance.
    ///   - cell: CityCell referrance.
    func Delete(zipObj: CityObject, cell: CityCell) {
        if let index = cityList.indexPath(for: cell){
        self.totalCityObjects.remove(at: index.row)
        }
        self.setTableSource()
    }
    
    
    var totalCityObjects = [CityObject]()
    @IBOutlet weak var cityList: UITableView!
        
    var zipCollection: ZipcodeCollectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        totalCityObjects.append(CityObject.init(dictionary: [:]))
        self.setTableSource()
        // Do any additional setup after loading the view.
    }
    /// Initialise locationList table delegate and datasource
    func setTableSource() {
        self.cityList.delegate = self
        self.cityList.dataSource = self
        self.cityList.reloadData()
    }
    
    //MARK: - city list UITableView Delegate and Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCityObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "city"
        let cell = cityList.dequeueReusableCell(withIdentifier: identifier) as! CityCell
        
        let obj = self.totalCityObjects[indexPath.row]
        cell.activityIndicator.isHidden = true
        cell.cityData = obj
        cell.cityDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44.0
    }
    
    
    /// Check if empty field is there. if not, add new location field. reload table
    /// - Parameter sender: UIButton referrance
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
    
    /// Dismiss current viewcontroller
    /// - Parameter sender: UIButton referrance
    @IBAction func dismissAction(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Check if user entered valid location.
    /// - Parameter sender: UIButton referrance
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
        
        var selectedZipCodes = [String]()
        
        for cityObj in self.totalCityObjects {
            selectedZipCodes.append(contentsOf: cityObj.zipcodes)
        }
        self.zipCollection!.sendZipcodeCollection(zipcodes: selectedZipCodes)
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
