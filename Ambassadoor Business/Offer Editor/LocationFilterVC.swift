//
//  LocationFilterVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 30/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol RadiousFilteredDelegate {
    func radiousFilteredZipcodes(zipcodes: [String])
}


class LocationFilterVC: BaseVC, LocationFilterDelegate, RadiousFilteredDelegate, CityCellDelegate {
    
    
    func SendCityObject(zipObj: [CityObject]){
        var city = [String]()
        
        for cityObj in zipObj {
            city.append(contentsOf: cityObj.zipcodes)
        }
        selectedZipCodes.append(contentsOf: city)
    }
    
    func radiousFilteredZipcodes(zipcodes: [String]) {
        selectedZipCodes.append(contentsOf: zipcodes)
    }
    
    func LocationFilterChosen(filter: String) {
        
        //let filt = self.TitleAndTagLineforLocationFilter(filter: filter)
        
        switch filter.components(separatedBy: ":")[0] {
            
        case "states":
            self.getStateFilterZips(filter: filter)
        case "zipcode":
            self.getZipcodesradious(filter: filter)
        default:
            print("")
        }
        

        
    }
    
    func getStateFilterZips(filter: String) {
        let data = filter.components(separatedBy: ":")[1]
        var returnData: [String] = []
        var index = 0
        for stateName in data.components(separatedBy: ",") {
            GetZipCodesInState(stateShortName: stateName) { (zips1) in
                returnData.append(contentsOf: zips1)
                index += 1
                if index == data.components(separatedBy: ",").count {
                   print(returnData)
                    self.selectedZipCodes.append(contentsOf: returnData)
                }
            }
        }
    }
    
    func getZipcodesradious(filter: String) {
        let data1 = filter.components(separatedBy: ":")[1]
        var returnData: [String] = []
        var index = 0
        for data in data1.components(separatedBy: ",") {
            let zip = data.components(separatedBy: "-")[0]
            let radius = Int(data.components(separatedBy: "-")[1]) ?? 0
            GetAllZipCodesInRadius(zipCode: zip, radiusInMiles: radius) { (returns, zip, radius) in
                if let returns = returns {
                    returnData.append(contentsOf: returns.keys)
                }
                index += 1
                if index >= data1.components(separatedBy: ",").count {
                   print(returnData)
                    self.selectedZipCodes.append(contentsOf: returnData)
                }
            }
        }

    }
    
    
    var selectedZipCodes = [String]()
    
    var zipCollection: ZipcodeCollectionDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func filterByRadious(sender: Any){
        self.performSegue(withIdentifier: "toMilesFilter", sender: self)
    }
    
    @IBAction func filterByStates(sender: Any){
        self.performSegue(withIdentifier: "toFilterStates", sender: self)
    }
    
    @IBAction func fiterByCity(sender: Any){
        self.performSegue(withIdentifier: "toCityFilter", sender: self)
    }
    
    @IBAction func toZipCodeViewAction(sender: Any){
        self.performSegue(withIdentifier: "toZipCodeView", sender: self)
    }
    
    @IBAction func cancelAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? SelectStatesVC {
            view.locationDelegate = self
        }
        if let view = segue.destination as? FilterRadiousVC{
            view.radiousFilteredDelegate = self
        }
        if let view = segue.destination as? FilterByCityVC{
            view.cityReturnDelegate = self
        }
        if let view = segue.destination as? SelectRadiiVC {
           view.locationDelegate = self
        }
        
    }
    
    @IBAction func doneAction(sender: UIButton){
        self.zipCollection?.sendZipcodeCollection(zipcodes: self.selectedZipCodes)
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
