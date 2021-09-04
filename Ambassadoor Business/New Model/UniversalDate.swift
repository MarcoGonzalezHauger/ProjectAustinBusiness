//
//  UniversalDate.swift
//  Ambassadoor
//
//  Created by Marco Gonzalez Hauger on 1/26/21.
//  Copyright © 2021 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation

func GetEmptyDate() -> Date {
	return "".toUDate()
}

extension Date {
	func toString(dateFormat format: String ) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
	
	func toUString() -> String {
		if self == Date(timeIntervalSince1970: 0) {
			return ""
		}
		return self.toString(dateFormat: dateFormatUniversal)
	}
	
}

extension String {
	func toUDate() -> Date {
		if self == "" {
			return Date(timeIntervalSince1970: 0)
		} else {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = dateFormatUniversal
            //return dateFormatter.date(from: self) ?? Date(timeIntervalSince1970: 0)
            if let date = dateFormatter.date(from: self) {
                return date
            }else{
                dateFormatter.dateFormat = dateFormatUniversalWithoutZone
                if let date = dateFormatter.date(from: self) {
                    return date
                }else{
                    return Date(timeIntervalSince1970: 0)
                }
            }
			
		}
	}
}
