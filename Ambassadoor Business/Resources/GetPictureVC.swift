//
//  GetPictureVC.swift
//  Ambassadoor Business
//
//  Created by Marco Gonzalez Hauger on 5/3/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//	Exclusive Property of Tesseract Freelance, LLC.
//

import UIKit
import Photos

protocol ImagePickerDelegate {
	func imagePicked(image: UIImage?, imageUrl: String?)
}

class GetPictureVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate {
	
	var delegate: ImagePickerDelegate?
	
	@IBOutlet weak var blur: UIVisualEffectView!
	@IBOutlet weak var imgWidth: NSLayoutConstraint!
	@IBOutlet weak var imgHeight: NSLayoutConstraint!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var scrollView: UIScrollView!
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	func setImageToCrop(image : UIImage) {
		
		imageView.image = image
		imgWidth.constant = image.size.width
		imgHeight.constant = image.size.height
		let scaleHeight = scrollView.frame.size.width / image.size.width
		let scaleWidth = scrollView.frame.size.height / image.size.height
		let maxScale = max(scaleWidth, scaleHeight)
		debugPrint("MAX SCALE \(maxScale)")
		scrollView.minimumZoomScale = maxScale
		scrollView.zoomScale = maxScale
		blur.isHidden = true
		
	}
	
	func GetCroppedImage() -> UIImage {
		let scale : CGFloat = 1 / scrollView.zoomScale
		let x : CGFloat = scrollView.contentOffset.x * scale
		let y : CGFloat = scrollView.contentOffset.y * scale
		let width : CGFloat = scrollView.frame.size.width * scale
		let height : CGFloat = scrollView.frame.size.height * scale
		let	croppedCGImage = fixOrientation(image: imageView.image)?
			.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height))
		let croppedImage = UIImage(cgImage: croppedCGImage!)
		return croppedImage
	}
	
	func fixOrientation(image: UIImage?) -> UIImage? {
		guard let image = image else { return nil }
		if image.imageOrientation == UIImage.Orientation.up {
			return image
		}
		UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
		image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
		if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
			UIGraphicsEndImageContext()
			return normalizedImage
		} else {
			return image
		}
	}
	
	@IBAction func cropImage(_ sender: Any) {
		
		let croppedImage = GetCroppedImage()
		
		//This is the part where the image is uploaded and is assigned a URL by Chris.
		
		let imageUrl: String = "https://edcoinfo.com/wp-content/uploads/2017/04/bitmap.png" //chris's bit. It's a test picture right npw.
		delegate?.imagePicked(image: croppedImage, imageUrl: imageUrl)
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func cancel(_ sender: Any) {
		delegate?.imagePicked(image: nil, imageUrl: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	let imagePicker = UIImagePickerController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		scrollView.delegate = self
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = false
		
		scrollView.layer.cornerRadius = 5
    }
	
	var alreadyPresented: Bool = false
	
	override func viewDidAppear(_ animated: Bool) {
		if alreadyPresented {
			return
		}
		debugPrint("Finding Photo Autrhoization")
		let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
		
		switch photoAuthorizationStatus {
		case .authorized:
			self.present(self.imagePicker, animated: true, completion: nil)
			debugPrint("Access is granted by user")
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization({
				(newStatus) in
				debugPrint("status is \(newStatus)")
				if newStatus ==  PHAuthorizationStatus.authorized {
					self.present(self.imagePicker, animated: true, completion: nil)
					print("success")
				} else {
					self.dismiss(animated: true, completion: nil)
				}
			})
			debugPrint("It is not determined until now")
		case .restricted:
			self.dismiss(animated: true, completion: nil)
			debugPrint("User do not have access to photo album.")
		case .denied:
			self.dismiss(animated: true, completion: nil)
			debugPrint("User has denied the permission.")
		}
		alreadyPresented = true
	}
	
	@objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imageView.image = image
			self.setImageToCrop(image: image)
		} else {
			debugPrint("Error code: This error that has this message.")
		}
		debugPrint("Image picker will be dismissed. Image found.")
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		debugPrint("Image picker cancelled.")
		delegate?.imagePicked(image: nil, imageUrl: nil)
		self.dismiss(animated: true) {
			self.dismiss(animated: true, completion: nil)
		}
	}

}
