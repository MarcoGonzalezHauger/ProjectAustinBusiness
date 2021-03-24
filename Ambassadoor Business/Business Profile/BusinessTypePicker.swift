//
//  BusinessTypePicker.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 24/03/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol TypePickerDelegate {
    func pickedBusinessType(type: BusinessType)
}

class BusinessTypePicker: BaseVC, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var businessPicker: UIPickerView!
    
    var typePicker: TypePickerDelegate?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return BusinessType.getAllType().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return BusinessType.getAllType()[row].rawValue
    }
    
    @IBAction func doneAction(sender: UIButton){
        let pickedType = BusinessType.getAllType()[businessPicker.selectedRow(inComponent: 0)]
        self.typePicker?.pickedBusinessType(type: pickedType)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setPickerData()
        // Do any additional setup after loading the view.
    }
    
    func setPickerData() {
        self.businessPicker.delegate = self
        self.businessPicker.dataSource = self
        self.businessPicker.reloadAllComponents()
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
