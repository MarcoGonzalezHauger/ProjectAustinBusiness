//
//  PostViewerVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 7/25/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import UIKit

class PreviewPostCell: UICollectionViewCell {
	
	func setColor(color: UIColor) {
		statusIndicator.ShadowColor = color
		statusIndicator.backgroundColor = color
	}
	
	var thisPost: InProgressPost? {
		didSet {
			if let thisPost = thisPost {
				
				switch thisPost.status {
				case "Posted":
					setColor(color: .systemBlue)
				case "Verified":
					setColor(color: .systemGreen)
				case "Paid":
					setColor(color: .systemYellow)
				default:
					setColor(color: .systemRed)
				}
				
				PostImage.image = nil
				
				downloadImage(thisPost.instagramPost!.images) { image in
					if let image = image {
//						let dimention = (self.heightConstraint.constant / image.size.height) * image.size.width
//						print("HEIGHT: \(self.heightConstraint.constant)")
//						print("WIDTH: \(dimention)")
						DispatchQueue.main.async {
//							self.widthConstraint.constant = dimention
//								self.layoutIfNeeded()
								self.PostImage.image = image
						}
					}
				}
			}
		}
	}
	
	@IBOutlet weak var PostImage: UIImageView!
	@IBOutlet weak var statusIndicator: ShadowView!
}

class PostViewerVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	var samplePosts: [InProgressPost] = []
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		topLabel.text = "All Posts (\(samplePosts.count))"
		return samplePosts.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "previewCell", for: indexPath) as! PreviewPostCell
		
		cell.thisPost = samplePosts[indexPath.item]
		cell.PostImage.clipsToBounds = true
		cell.PostImage.layer.cornerRadius = 5
		
		return cell
	}
	
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		print(samplePosts[indexPath.item].status)
	}
	

	@IBOutlet weak var topLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var viewAllButton: UIButton!
	
	
	@IBAction func viewAllPressed(_ sender: Any) {
		
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.dataSource = self
		collectionView.delegate = self
    }

}
