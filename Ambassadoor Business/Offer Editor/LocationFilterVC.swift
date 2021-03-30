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

class LocationFilterVC: BaseVC, LocationFilterDelegate, RadiousFilteredDelegate {
    func radiousFilteredZipcodes(zipcodes: [String]) {
        
    }
    
    func LocationFilterChosen(filter: String) {
        
        //let filt = self.TitleAndTagLineforLocationFilter(filter: filter)
        
        let data = filter.components(separatedBy: ":")[1]
        var returnData: [String] = []
        var index = 0
        for stateName in data.components(separatedBy: ",") {
            GetZipCodesInState(stateShortName: stateName) { (zips1) in
                returnData.append(contentsOf: zips1)
                index += 1
                if index == data.components(separatedBy: ",").count {
                   print(returnData)
                }
            }
        }
        
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = segue.destination as? SelectStatesVC {
            view.locationDelegate = self
        }
        if let view = segue.destination as? FilterRadiousVC{
            view.radiousFilteredDelegate = self
        }
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
