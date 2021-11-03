//
//  InterestPickerVC.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 2/21/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

let maxInterests: Int = 9999 //business app shouldn't have max.

class PickerCell: UITableViewCell { //picker
	@IBOutlet weak var interestImage: UIImageView!
	@IBOutlet weak var interestLabel: UILabel!
	@IBOutlet weak var mainView: ShadowView!
	
	func maxSelected() {
//		if "Max of \(maxInterests) Interests." != self.interestLabel.text {
//			let thisInterests = interestLabel.text!
//			MakeShake(viewToShake: mainView, coefficient: 0.5)
//			interestLabel.textColor = .systemRed
//			SetLabelText(label: interestLabel, text: "Max of \(maxInterests) Interests.", animated: true)
//			DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
//				if "Max of \(maxInterests) Interests." == self.interestLabel.text {
//					self.interestLabel.textColor = GetForeColor()
//					SetLabelText(label: self.interestLabel, text: thisInterests, animated: true, fromTop: false)
//				}
//			}
//		}
	}
}

class AlreadyPicked: UITableViewCell { //already
	@IBOutlet weak var pickedLabel: UILabel!
	@IBOutlet weak var interestImage: UIImageView!
}

class TopCell: UICollectionViewCell { //topcell
	@IBOutlet weak var InterestImage: UIImageView!
}

protocol pickerViewDelegate {
	func getInterests() -> [String]
}

class InterestPickerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, pickerViewDelegate {
	
	func getInterests() -> [String] {
		return pickedInterests
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return possibleInterests.count
	}
	
	@IBOutlet weak var topBarHeight: NSLayoutConstraint!
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let thisInterest = possibleInterests[indexPath.row]
		if pickedInterests.contains(thisInterest) {
			let picked = tableView.dequeueReusableCell(withIdentifier: "already") as! AlreadyPicked
			picked.interestImage.downloadAndSetImage(GetInterestUrl(interest: thisInterest))
			picked.pickedLabel.text = thisInterest
			return picked
		} else {
			let reg = tableView.dequeueReusableCell(withIdentifier: "picker") as! PickerCell
			reg.interestImage.downloadAndSetImage(GetInterestUrl(interest: thisInterest))
			reg.interestLabel.text = thisInterest
			reg.interestLabel.textColor = GetForeColor()
			return reg
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if pickedInterests.count == 0 {
			topBarHeight.constant = 0
			tableView.contentInset = UIEdgeInsets.init(top: 3, left: 0, bottom: 30, right: 0)
		} else {
			topBarHeight.constant = 72
			tableView.contentInset = UIEdgeInsets.init(top: 75, left: 0, bottom: 30, right: 0)
		}
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
		return pickedInterests.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let thisInterest = pickedInterests[indexPath.item]
		let thisOne = collectionView.dequeueReusableCell(withReuseIdentifier: "topcell", for: indexPath) as! TopCell
		thisOne.InterestImage.downloadAndSetImage(GetInterestUrl(interest: thisInterest))
		return thisOne
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	
		let interest = possibleInterests[indexPath.row]
		if pickedInterests.contains(interest) {
			removeInterest(interest: interest)
		} else {
            
            addInterest(interest: interest)
//			if !addInterest(interest: interest) {
//				let cell = tableView.cellForRow(at: indexPath) as! PickerCell
//				cell.maxSelected()
//
//			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	func addInterest(interest: String) {
//		if pickedInterests.count >= maxInterests {
//			return false
//		}
		pickedInterests.append(interest)
		topBar.reloadData()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			if self.pickedInterests.count > 0 {
				self.topBar.scrollToItem(at: IndexPath.init(item: self.pickedInterests.count - 1, section: 0), at: .right, animated: true)
			}
		}
		let i2 = possibleInterests.firstIndex(of: interest) ?? 0
		tableView.reloadRows(at: [IndexPath.init(row: i2, section: 0)], with: .right)
	}
	
	func removeInterest(interest: String) {
		let i = pickedInterests.firstIndex(of: interest) ?? 0
		if i == 0 {
			print("IMPOSSIBLE: \(i)")
		}
		pickedInterests.remove(at: i)
		topBar.reloadData()
		let i2 = possibleInterests.firstIndex(of: interest) ?? 0
		tableView.reloadRows(at: [IndexPath.init(row: i2, section: 0)], with: .left)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		removeInterest(interest: pickedInterests[indexPath.item])
	}
	
	var possibleInterests: [String] = []
	var pickedInterests: [String] = []

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var topBar: UICollectionView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		topBar.contentInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
		
		possibleInterests = AllInterests
		
		topBar.delegate = self
		topBar.dataSource = self
		tableView.delegate = self
		tableView.dataSource = self
    }

}
