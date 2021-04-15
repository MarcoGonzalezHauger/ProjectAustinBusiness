//
//  InterestPickerPopupVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/21/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

protocol InterestPickerDelegate {
	func newInterests(interests: [String])
}

class InterestPickerPopupVC: UIViewController { //interestPickerPopup

	@IBOutlet weak var embededView: UIView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
    }
	
	var pickerviewdel: pickerViewDelegate?
	var delegate: InterestPickerDelegate?
	
	var currentInterests: [String] = []
	@IBOutlet weak var doneButton: UIButton!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "embedView" {
			if let view = segue.destination as? InterestPickerVC {
				pickerviewdel = view
				view.pickedInterests = currentInterests
			}
		}
	}
	
	@IBAction func cancelPressed(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func donePressed(_ sender: Any) {
		let newInt = pickerviewdel!.getInterests()
//		if newInt.count > 0 {
//			delegate?.newInterests(interests: newInt)
//			dismiss(animated: true, completion: nil)
//		} else {
//			MakeShake(viewToShake: doneButton, coefficient: 0.2)
//		}
//        
        delegate?.newInterests(interests: newInt)
        dismiss(animated: true, completion: nil)
	}
	

}
