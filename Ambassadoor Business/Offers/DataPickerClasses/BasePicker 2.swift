//
//  BasePicker.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 06/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol PickerDelegate {
    func PickerValue(value: String)
}

class BasePicker: UIPickerView,UIPickerViewDelegate,UIPickerViewDataSource {
    
    var pickerComponents = [String]()
    var pickerDelegate: PickerDelegate!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> BasePicker {
        
       let pick = UINib(nibName: "BasePicker", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BasePicker
        return pick
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerComponents[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerDelegate.PickerValue(value: pickerComponents[row])
    }

}
