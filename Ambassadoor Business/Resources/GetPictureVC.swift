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

/// Custom UIImage picker
class GetPictureVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate {
	
	var delegate: ImagePickerDelegate?
	
	@IBOutlet weak var blur: UIVisualEffectView!
	@IBOutlet weak var imgWidth: NSLayoutConstraint!
	@IBOutlet weak var imgHeight: NSLayoutConstraint!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var scrollView: UIScrollView!
	
//    Asks the delegate for the imageView to scale when zooming is about to occur in the scroll view.
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
    
    /// set image to crop based on scrollview zoom and scale.
    /// - Parameter image: picked image
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
	
    // Crop image as per scroll zoom and content offset.
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
	
    
    /// Change the cropped image orientation to up.
    /// - Parameter image: Cropped Image.
    /// - Returns: Orientated image.
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
	
    
    /// Crop the image and send cropped image to ImagePickerDelegate delegate method. dismiss current view controller.
    /// - Parameter sender: UIButton referrance
	@IBAction func cropImage(_ sender: Any) {
		
		let croppedImage = GetCroppedImage()
		
		//This is the part where the image is uploaded and is assigned a URL by Chris.
		
		//let imageUrl: String = uploadImage(image: croppedImage)
		delegate?.imagePicked(image: croppedImage, imageUrl: "")
		self.dismiss(animated: true, completion: nil)
	}
	
    
    /// send nil to ImagePickerDelegate delegate method. Dismiss current view controller
    /// - Parameter sender: UIButton referrance
	@IBAction func cancel(_ sender: Any) {
		delegate?.imagePicked(image: nil, imageUrl: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	let imagePicker = UIImagePickerController()
	@IBOutlet weak var outView: UIView!
	
    
    /// Initialize scrollview, imagePicker, outView
    override func viewDidLoad() {
        super.viewDidLoad()
		
		scrollView.delegate = self
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = false
		outView.layer.cornerRadius = outView.bounds.width / 2
    }
	
	var alreadyPresented: Bool = false
	
    
    /// Check if user has given authorize permisson to access photolibrary. if not ask permission otherwise go to photo library.
    /// - Parameter animated: true or false
	override func viewDidAppear(_ animated: Bool) {
		outView.layer.cornerRadius = outView.bounds.width / 2
		if alreadyPresented {
			return
		}
		debugPrint("Finding Photo Autrhoization")
		let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
		
		switch photoAuthorizationStatus {
		case .authorized:
			//self.present(self.imagePicker, animated: true, completion: nil)
            self.present(self.imagePicker, animated: true, completion: nil)
            self.imagePicker.modalPresentationStyle = .fullScreen
			print("Access is granted by user")
			//only for NEW iOS Beta.
//		case .limited:
//			self.present(self.imagePicker, animated: true, completion: nil)
//			print("Access LIMITED but granted.")
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization({
				(newStatus) in
				print("status is \(newStatus)")
				if newStatus ==  PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        //self.present(self.imagePicker, animated: true, completion: nil)
                        self.present(self.imagePicker, animated: true, completion: nil)
                        self.imagePicker.modalPresentationStyle = .fullScreen
                    }
					
					print("success")
				} else {
                    DispatchQueue.main.async {
					self.dismiss(animated: true, completion: nil)
                    }
				}
			})
			debugPrint("It is not determined until now")
		case .restricted:
            DispatchQueue.main.async {
			self.dismiss(animated: true, completion: nil)
			debugPrint("User do not have access to photo album.")
            }
		case .denied:
            DispatchQueue.main.async {
			self.dismiss(animated: true, completion: nil)
			debugPrint("User has denied the permission.")
            }
		default:
			print("err")
		}
		alreadyPresented = true
	}
	
//  MARK:  UIImagePickerController delegate method
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
