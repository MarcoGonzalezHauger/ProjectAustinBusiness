//
//  LocationSelectorVC.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 24/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol LocationDelegate {
    func sendLocationObject(cell: LocationCell, index: Int, isEditing: Bool)
}

class LocationCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var close: UIButton!
    
    var locationDelegate: LocationDelegate?
    
    @IBAction func textDidChange(sender: UITextField){
        locationDelegate?.sendLocationObject(cell: self, index: self.close.tag, isEditing: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        locationDelegate?.sendLocationObject(cell: self, index: self.close.tag, isEditing: false)
        return true
    }
}

//MARK: Location Class

class LocationSelectorVC: BaseVC, UITableViewDelegate, UITableViewDataSource, LocationDelegate {
    func sendLocationObject(cell: LocationCell, index: Int, isEditing: Bool) {
        self.locations[index] = cell.locationText.text!
        if !isEditing{
            self.locationList.reloadData()
        }
    }
    
    @objc override func keyboardWasShown(notification : NSNotification) {
        
 //       if let key = notification.object as? UITextField {
 //           if key == phraseText {
                
                let userInfo = notification.userInfo!
                var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
                keyboardFrame = self.view.convert(keyboardFrame, from: nil)
                
                var contentInset:UIEdgeInsets = locationList.contentInset
                contentInset.bottom = keyboardFrame.size.height + 25
                locationList.contentInset = contentInset
                
  //          }
  //      }
        
        
        
    }
    
    @objc override func keyboardWillHide(notification:NSNotification){
        
//        if let key = notification.object as? UITextField {
//        if key == phraseText {
            
            let contentInset:UIEdgeInsets = UIEdgeInsets.zero
            locationList.contentInset = contentInset
            
//            }
 //       }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (locations.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "location"
        let cell = locationList.dequeueReusableCell(withIdentifier: identifier) as! LocationCell
        cell.locationText.text = locations[indexPath.row] != "" ? locations[indexPath.row] : nil
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
    
    var locationRetrive: LocationretriveDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTableData()
        // Do any additional setup after loading the view.
    }
    
    func setTableData() {
        self.locationList.delegate = self
        self.locationList.dataSource = self
        self.locationList.reloadData()
    }

    @IBAction func removelocation(sender: UIButton){
        if self.locations.count > sender.tag{
            let index = IndexPath.init(row: sender.tag, section: 0)
            self.locations.remove(at: sender.tag)
            locationList.deleteRows(at: [index], with: .right)
            locationList.reloadData()
        }
        
    }
    
    @IBAction func addLocationAction(sender: UIButton){
        self.locations.append("")
        self.locationList.reloadData()
    }
    
    @IBAction func backAction(sender: UIButton){
		locations = locations.filter{$0 != ""}
//        for (index,location) in locations.enumerated() {
//            if location == "" {
//                let index = IndexPath.init(row: index, section: 0)
//                //let index = IndexPath.init(row: sender.tag, section: 0)
//                let cell = self.locationList.cellForRow(at: index) as! LocationCell
//                MakeShake(viewToShake: cell)
//                return
//            }
//        }
        for (index,location) in locations.enumerated() {
            
            
            if !regexForLocation(loc: location) {
                let index = IndexPath.init(row: index, section: 0)
                let cell = self.locationList.cellForRow(at: index) as! LocationCell
                MakeShake(viewToShake: cell)
                self.showAlertMessage(title: "Invalid Address!", message: "Please enter the valid address.") {
                }
                return
            }
        }
        //basicBusiness?.locations = locations
        self.locationRetrive?.sendLocationObjects(locations: locations)
        self.performDismiss()
        
    }
    
    func regexForLocation(loc: String) -> Bool{
		
		//EDIT FROM MARCO: Just checks if location contains zip code which is all we need.
		
		let parts = loc.components(separatedBy: ",")
		let end = parts.last!
		let ZipC = end.components(separatedBy: " ").last ?? ""
		if ZipC == "" {
			return false
		}
		
		if ZipC.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
			if ZipC.count >= 4 {
				if ZipC.count <= 6 {
					return true
				}
			}
		}
		return false
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
