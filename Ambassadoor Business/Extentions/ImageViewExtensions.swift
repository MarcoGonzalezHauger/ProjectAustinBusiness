//
//  ImageViewExtensions.swift
//  Ambassadoor
//
//  Created by Chris Chomicki on 2/6/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//  Exclusive property of Tesseract Freelance, LLC.
//

import Foundation
import UIKit
import CoreData

let imageCache = NSCache<NSString, AnyObject>()

//This extension allows UIImageViews to download images from the web and hvae them saved in cache.

public extension UIImageView {
    
    struct Holder {
        static var activityIndicatorProperty: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    }
    
    var activityIndicator: UIActivityIndicatorView {
        get {
            return UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        }
        set(newValue) {
            Holder.activityIndicatorProperty = newValue
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2);
        self.addBorder()
        
        OperationQueue.main.addOperation({ () -> Void in
            self.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        })
    }
	
	//we decided against havaing borders.
	
    func addBorder() {
//        self.layer.borderColor = UIColor.gray.cgColor
//        self.layer.borderWidth = 1
		self.layer.cornerRadius = 5
    }
    
    func removeBorder() {
//        self.layer.borderColor = UIColor.white.cgColor
    }
	
	func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, makeImageCircular isCircle: Bool = false) {
        contentMode = mode
        self.showActivityIndicator()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data
				else { return }
                var image = UIImage(data: data)
				if image == nil {
					return
				}
				if isCircle {
					image = makeImageCircular(image: image!)
				}
            DispatchQueue.main.async() {
                self.image = image
                self.activityIndicator.stopAnimating()
                self.removeBorder()
            }
            }.resume()
    }
    
    
    
//    func downloadAndSetImage(_ urlLink: String, isCircle: Bool = true){
//        self.showActivityIndicator()
//        self.image = nil
//		downloadImage(urlLink) { (returnImage) in
//			guard let returnImage = returnImage else { return }
//			if isCircle {
//				self.image = makeImageCircular(image: returnImage)
//			} else {
//				self.image = returnImage
//			}
//		}
//    }
}

func saveCoreData(link: String, data: Data) {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let imageDataEntity = NSEntityDescription.entity(forEntityName: "AppImageData", in: context)
    let imageData = NSManagedObject(entity: imageDataEntity!, insertInto: context)
    imageData.setValue(data, forKey: "imagedata")
    imageData.setValue(link, forKey: "url")
    imageData.setValue(Date.getcurrentESTdate(), forKey: "updatedDate")
    let cacheData = CachedImages.init(object: imageData)
    global.cachedImageList.append(cacheData)
    saveCoreDataUpdate(object: imageData)
    
    
    
}

public extension UIImage{
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
/*
func downloadImage(_ urlLink: String, completed: @escaping (_ image: UIImage?) -> ()){
	if urlLink.isEmpty {
		completed(nil)
		return
	}
	// check cache first
	if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
		completed(cachedImage)
		return
	}
	
	// otherwise, download
	let url = URL(string: urlLink)
	URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
		if let err = error {
			print(err)
			completed(nil)
			return
		}
		DispatchQueue.main.async {
			if let newImage = UIImage(data: data!) {
				imageCache.setObject(newImage, forKey: urlLink as NSString)
				completed(newImage)
				return
			}
		}
	}).resume()
	
}
*/
func downloadImage(_ urlLink: String, completed: @escaping (_ image: UIImage?) -> ()){
if urlLink.isEmpty {
    completed(nil)
    return
}
// check cache first
/*
if let cachedImage = imageCache.object(forKey: urlLink as NSString) as? UIImage {
print("CHACHED  : \(urlLink)")
completed(cachedImage)
return
}
*/

let cachedImage = global.cachedImageList.filter { (cache) -> Bool in
    return cache.link! == urlLink
}

if cachedImage.count != 0{
    
    if let image = UIImage(data: cachedImage.first!.imagedata!){
        
        //print("CHACHED  : \(urlLink)")
        
        if let imageData = cachedImage.first!.object {
            imageData.setValue(Date.getcurrentESTdate(), forKey: "updatedDate")
            saveCoreDataUpdate(object: imageData)
        }
        completed(image)
        return
        
    }
}
}
extension Date {
    static func getcurrentESTdate()-> Date{
        let curDateStr = Date.getStringFromDate(date: Date())
        let currentDate = Date.getDateFromString(date: curDateStr!)
        return currentDate!
    }
    static func getStringFromDate(date:Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ssZ"
        //        dateFormatter.timeZone = TimeZone.current
        //        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date) // replace Date String
    }
    
    static func getDateFromString(date:String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm:ssZ"
    //        dateFormatter.timeZone = TimeZone.current
    //        dateFormatter.locale = Locale.current
            
            return dateFormatter.date(from: date) // replace Date String
        }
}
