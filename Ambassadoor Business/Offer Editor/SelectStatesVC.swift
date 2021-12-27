//
//  SelectStatesVC.swift
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

class stateCell: UITableViewCell {
	@IBOutlet weak var stateSelected: UILabel!
	@IBOutlet weak var stateLabel: UILabel!
	@IBOutlet weak var stateImage: UIImageView!
    
    /// set state image and state name.
	var thisState: State? {
		didSet {
			stateImage.image = thisState?.GetImage()
			stateLabel.text = thisState?.name
		}
	}
}

class SelectStatesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: - statesShelf list UITableView Delegate and Datasource
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
    
    /// Update stateSelected text in cell when user select the state.
    /// - Parameter indexPath: Index path of the cell.
	func updateSelection(indexPath: IndexPath) {
		(statesShelf.cellForRow(at: indexPath) as! stateCell).stateSelected.isHidden = !isSelected(state: GetItems()[indexPath.row])
		searchBar.resignFirstResponder()
	}
    
    /// Check id user selected state or not. To avoid reuse identifies cell conflict
    /// - Parameter state: selected state
    /// - Returns: true if user selected the state otherwise false
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
	
//    Get all states and filter by search string if user search other wise filter by has prefix name.
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
    
    /// Dismiss current view controller
    /// - Parameter sender: UIButton referrance
	@IBAction func backPressed(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	var searchString = ""
    
    /// Update UseStateButton title and UseStateView color based on selectedStates.
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
	
    
    /// Check if user selected any state. fetch zipcode by state using third party API.
    /// - Parameter sender: UIButton referrance
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
    
    
    /// Fetch zipcodes by state name using third party API. pass zipcods in sendZipcodeCollection delegate method. Dismiss current view controller.
    /// - Parameter filter: selected states
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
    
    /// Initialise statesShelf list delegate and datasource
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
	
	var locationDelegate: LocationFilterDelegate?
	
//    UISearchbar delegate
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchString = searchText
		statesShelf.reloadData()
	}
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
