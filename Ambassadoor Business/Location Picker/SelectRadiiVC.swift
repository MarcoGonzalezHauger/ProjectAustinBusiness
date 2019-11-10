//
//  SelectRadiiVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 11/9/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

struct radii {
	var zip: String
	var radius: Int
}

class RadiusCell: UITableViewCell {
	var delegate: RadiusDelegate?
	var ip: IndexPath!
	@IBOutlet weak var zipCode: UITextField!
	@IBOutlet weak var Miles: UITextField!
	
	@IBAction func zipChanged(_ sender: Any) {
		delegate?.updated(zip: zipCode.text!, radius: Int(Miles.text!) ?? 0, indexPath: self.ip)
	}
	
	@IBAction func milesChanged(_ sender: Any) {
		delegate?.updated(zip: zipCode.text!, radius: Int(Miles.text!) ?? 0, indexPath: self.ip)
	}
	
}

protocol RadiusDelegate {
	func updated(zip: String, radius: Int, indexPath: IndexPath)
}

class SelectRadiiVC: BaseVC, UITableViewDelegate, UITableViewDataSource, RadiusDelegate {
	
	func updated(zip: String, radius: Int, indexPath: IndexPath) {
		locations[indexPath.row].zip = zip
		locations[indexPath.row].radius = radius
		updateButton()
		print("infomation UPDATED")
	}
	
	@IBOutlet weak var radiusAroundLocation: UILabel!
	@IBOutlet weak var UseAreaButtonView: ShadowView!
	@IBOutlet weak var UseAreaButton: UIButton!
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return locations.count + 1
	}
	
	@IBAction func useAreaClicked(_ sender: Any) {
		if isSavable() {
			var vals: [String] = []
			for loc in locations {
				vals.append("\(loc.zip)-\(loc.radius)")
			}
			let returnValue = "radius:" + vals.joined(separator: ",")
			self.locationDelegate?.LocationFilterChosen(filter: returnValue)
			dismiss(animated: true, completion: nil)
		} else {
			YouShallNotPass(SaveButtonView: UseAreaButtonView, returnColor: .lightGray)
		}
	}
	
	@IBAction func backClicked(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	override func doneButtonAction() {
		self.view.endEditing(true)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == locations.count {
			return radiiShelf.dequeueReusableCell(withIdentifier: "newCell")!
		}
		let cell = radiiShelf.dequeueReusableCell(withIdentifier: "radiusCell") as! RadiusCell
		let location = locations[indexPath.row]
		cell.zipCode.text = location.zip
		cell.delegate = self
		cell.ip = indexPath
		self.addDoneButtonOnKeyboard(textField: cell.zipCode)
		self.addDoneButtonOnKeyboard(textField: cell.Miles)
		if location.radius != 0 {
			cell.Miles.text = "\(location.radius)"
		} else {
			cell.Miles.text = ""
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == locations.count {
			locations.append(radii(zip: "", radius: 0))
			radiiShelf.insertRows(at: [indexPath], with: .bottom)
		}
		radiiShelf.deselectRow(at: indexPath, animated: false)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == locations.count {
			return 65
		}
		return 100
	}
	
	@IBOutlet weak var radiiShelf: UITableView!
	
	var locations: [radii] = [] {
		didSet {
			radiusAroundLocation.text = "Radius Around Location\(locations.count > 1 ? "s" : "")"
		}
	}
	
	func isSavable() -> Bool {
		var canSave = true
		for r in locations {
			if r.zip.count <= 3 {
				canSave = false
			}
		}
		return canSave
	}
	
	var prev: Bool?
	
	func updateButton() {
		let savable = isSavable()
		if prev ?? !savable == savable {
			return
		}
		prev = savable
		UIView.animate(withDuration: 1) {
			self.UseAreaButtonView.backgroundColor = savable ? .systemBlue : .lightGray
		}
		UseAreaButton.setTitle(savable ? "Use Area" : "Area Not Set", for: .normal)
	}
	
	var locationString: String {
		if let getls = locationDelegate?.GetLocationString {
			return getls()
		} else {
			return ""
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if #available(iOS 13.0, *) {
			self.isModalInPresentation = true
		}
		if locationString.components(separatedBy: ":")[0] != "radius" {
			locations = [radii(zip: "", radius: 0)]
		} else {
			var lcns: [radii] = []
			for data in locationString.components(separatedBy: ":")[1].components(separatedBy: ",") {
				let zip = data.components(separatedBy: "-")[0]
				let radius = Int(data.components(separatedBy: "-")[1]) ?? 0
				lcns.append(radii(zip: zip, radius: radius))
			}
			locations = lcns
		}
		updateButton()
		radiiShelf.delegate = self
		radiiShelf.dataSource = self
		radiiShelf.contentInset.bottom = view.safeAreaInsets.bottom + 88
		radiiShelf.contentInset.top = 6
    }
	
	var locationDelegate: LocationFilterDelegate?
}
