//
//  FilterTypeVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 11/8/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

@objc protocol LocationFilterDelegate {
	func LocationFilterChosen(filter: String)
	@objc optional func GetLocationString() -> String
}

class FilterTypeVC: UIViewController, LocationFilterDelegate {
	
	func LocationFilterChosen(filter: String) {
		SelectAndClose(data: filter)
	}

	@IBOutlet weak var radiusSelected: UILabel!
	@IBOutlet weak var statesSelected: UILabel!
	@IBOutlet weak var nationSelected: UILabel!
	@IBOutlet weak var closeButton: UIButton!
	
	var locationDelegate: LocationFilterDelegate?
	
	@IBOutlet var nationWideTapped: UITapGestureRecognizer!
	
	@IBAction func nationWideSelected(_ sender: Any) {
		SelectAndClose(data: "nw")
	}
	
	func GetLocationString() -> String {
		return locationString
	}
	
	func SelectAndClose(data: String) {
		locationDelegate?.LocationFilterChosen(filter: data)
		navigationController?.dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		checkClosability()
		UpdateSelection(locationString: locationString)
    }
	
	@IBAction func closeButtonPressed(_ sender: Any) {
		navigationController?.dismiss(animated: true, completion: nil)
	}
	
	var locationString: String {
		if let getls = locationDelegate?.GetLocationString {
			return getls()
		} else {
			return ""
		}
	}
	
	func checkClosability() {
		let shouldClose = locationString != ""
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = !shouldClose
		}
		closeButton.isHidden = !shouldClose
	}
	
	func UpdateSelection(locationString ls: String) {
		let typeString = ls.components(separatedBy: ":")[0]
		radiusSelected.isHidden = typeString != "radius"
		statesSelected.isHidden = typeString != "states"
		nationSelected.isHidden = typeString != "nw"
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination	as? SelectStatesVC {
			dest.locationDelegate = self
		}
		if let dest = segue.destination	as? SelectRadiiVC {
			dest.locationDelegate = self
		}
	}

}
