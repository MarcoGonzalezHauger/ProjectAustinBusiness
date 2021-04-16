//
//  SelectStatesVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 11/8/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class stateCell: UITableViewCell {
	@IBOutlet weak var stateSelected: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	@IBOutlet weak var stateImage: UIImageView!
	var thisState: State? {
		didSet {
			stateImage.image = thisState?.GetImage()
			stateLabel.text = thisState?.name
		}
	}
}

class SelectStatesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
		
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 85
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return GetItems().count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = statesShelf.dequeueReusableCell(withIdentifier: "stateCell") as! stateCell
		let thisState = GetItems()[indexPath.row]
		cell.thisState = thisState
		cell.stateSelected.isHidden = !isSelected(state: GetItems()[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if !isSelected(state: GetItems()[indexPath.row]) {
			selectedStates.append(GetItems()[indexPath.row])
		}
		updateSelection(indexPath: indexPath)
	}
	
	func updateSelection(indexPath: IndexPath) {
		(statesShelf.cellForRow(at: indexPath) as! stateCell).stateSelected.isHidden = !isSelected(state: GetItems()[indexPath.row])
		searchBar.resignFirstResponder()
	}
	
	func isSelected(state: State) -> Bool {
		return selectedStates.contains(where: { (state1) -> Bool in
			return state1.shortName == state.shortName
		})
	}
	
	func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		selectedStates.removeAll(where: { (state1) -> Bool in
			return state1.shortName == GetItems()[indexPath.row].shortName
		})
		updateSelection(indexPath: indexPath)
	}
	
	let stateList = GetListOfStates()
	
	func GetItems() -> [State] {
		var returnValue = stateList
		returnValue = returnValue.filter { (state) -> Bool in
			if searchString.lowercased() == state.shortName.lowercased() {
				return true
			} else {
				return state.name.lowercased().hasPrefix(searchString.lowercased())
			}
		}
		return returnValue
	}
	
	@IBAction func backPressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	var searchString = ""
	var selectedStates: [State] = [] {
		didSet {
			if selectedStates.count == 1 {
				self.UseStateButton.setTitle("Use State", for: .normal)
				self.UseStateButton.layoutIfNeeded()
				UIView.animate(withDuration: 1) {
					self.UseStateView.backgroundColor = .systemBlue
				}
			} else if selectedStates.count == 0 {
				UseStateButton.setTitle("No States Selected", for: .normal)
				UIView.animate(withDuration: 1) {
					self.UseStateView.backgroundColor = .lightGray
				}
			} else {
				if oldValue.count != 1 {
					UIView.performWithoutAnimation {
						UseStateButton.setTitle("Use \(selectedStates.count) States", for: .normal)
						self.UseStateButton.layoutIfNeeded()
					}
				} else {
					UseStateButton.setTitle("Use \(selectedStates.count) States", for: .normal)
				}
				UIView.animate(withDuration: 1) {
					self.UseStateView.backgroundColor = .systemBlue
				}
			}
		}
	}
	
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var statesShelf: UITableView!
	@IBOutlet weak var UseStateView: ShadowView!
	@IBOutlet weak var UseStateButton: UIButton!
    
    var zipCollection: ZipcodeCollectionDelegate?
	
	@IBAction func UseState(_ sender: Any) {
		if selectedStates.count == 0 {
			YouShallNotPass(SaveButtonView: UseStateView, returnColor: .lightGray)
			return
		} else {
			var vals: [String] = []
			for state in selectedStates {
				vals.append(state.shortName)
			}
			let returnValue = "states:" + vals.joined(separator: ",")
//			self.locationDelegate?.LocationFilterChosen(filter: returnValue)
            self.getStateFilterZips(filter: returnValue)
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
                    self.zipCollection?.sendZipcodeCollection(zipcodes: returnData)
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
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
		if locationString.components(separatedBy: ":")[0] == "states" {
			let data = locationString.components(separatedBy: ":")[1].components(separatedBy: ",")
			selectedStates = stateList.filter({ (state1) -> Bool in
				return data.contains(state1.shortName)
			})
		}
		self.UseStateView.backgroundColor = selectedStates.count == 0 ? .lightGray : .systemBlue
		statesShelf.delegate = self
		statesShelf.dataSource = self
		searchBar.delegate = self
		statesShelf.contentInset.bottom = view.safeAreaInsets.bottom + 88
		statesShelf.contentInset.top = 6
    }

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
	}
	
	var locationDelegate: LocationFilterDelegate?
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchString = searchText
		statesShelf.reloadData()
	}
	
}
