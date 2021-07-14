//
//  PickInterests.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 7/9/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class CustomViewFlowLayout: UICollectionViewFlowLayout {
	let cellSpacing: CGFloat = 10
 
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		self.minimumLineSpacing = 10.0
		self.sectionInset = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
		let attributes = super.layoutAttributesForElements(in: rect)
 
		var leftMargin = sectionInset.left
		var maxY: CGFloat = -1.0
		attributes?.forEach { layoutAttribute in
			if layoutAttribute.frame.origin.y >= maxY {
				leftMargin = sectionInset.left
			}
			layoutAttribute.frame.origin.x = leftMargin
			leftMargin += layoutAttribute.frame.width + cellSpacing
			maxY = max(layoutAttribute.frame.maxY, maxY)
		}
		return attributes
	}
}

class PickInterestCell: UICollectionViewCell {
	@IBOutlet weak var shadow: ShadowView!
	@IBOutlet weak var label: UILabel!
	
	var _selected: Bool = false
	
	var storedInterest: String = ""
	
	func setIsActive(_ isActive: Bool) {
		if isActive {
			shadow.backgroundColor = UIColor.init(named: "AmbPurple")
			label.textColor = .white
			_selected = true
		} else {
			shadow.backgroundColor = UIColor.init(named: "newCellColor")
			label.textColor = GetForeColor()
			_selected = false
		}
	}
	
	func setInterest(interest: String) {
		label.text = (EmojiInterests[interest] ?? "❓") + " " + interest
		storedInterest = interest
	}
	
	func maxSelected() {
		if "Max: \(maxInterests)" != self.label.text {
			let thisInterests = label.text!
			MakeShake(viewToShake: shadow, coefficient: 0.2)
			label.textColor = .systemRed
			SetLabelText(label: label, text: "Max: \(maxInterests)", animated: true)
			DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
				if "Max: \(maxInterests)" == self.label.text {
					self.label.textColor = GetForeColor()
					SetLabelText(label: self.label, text: thisInterests, animated: true, fromTop: true)
				}
			}
		}
	}
	
}

class PickInterests: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, pickerViewDelegate {

	@IBOutlet weak var collectionView: UICollectionView!
	
	func getInterests() -> [String] {
		return pickedInterests
	}
	
	var possibleInterests: [String] = []
	var pickedInterests: [String] = []
	
	let columnLayout = CustomViewFlowLayout()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		possibleInterests = AllInterests
		
		columnLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
		collectionView.collectionViewLayout = columnLayout
		collectionView.allowsMultipleSelection = true
		
		collectionView.delegate = self
		collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		
		let thisOne = collectionView.cellForItem(at: indexPath) as! PickInterestCell
		
		if !thisOne._selected {
			if pickedInterests.count >= maxInterests {
				thisOne.maxSelected()
			} else {
				pickedInterests.append(thisOne.storedInterest)
				thisOne.setIsActive(true)
			}
		} else {
			let thisOne = collectionView.cellForItem(at: indexPath) as! PickInterestCell
			
			pickedInterests.removeAll { $0 == thisOne.storedInterest }
			thisOne.setIsActive(false)
			
		}
		UseTapticEngine()
		
		collectionView.deselectItem(at: indexPath, animated: false)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return possibleInterests.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let thisInterest = possibleInterests[indexPath.item]
		
		let thisOne = collectionView.dequeueReusableCell(withReuseIdentifier: "pickInt", for: indexPath) as! PickInterestCell
		
		let slct = pickedInterests.contains(thisInterest) // is Selected
		thisOne.setInterest(interest: thisInterest)
		thisOne.setIsActive(slct)
		
		return thisOne
	}
	
}
