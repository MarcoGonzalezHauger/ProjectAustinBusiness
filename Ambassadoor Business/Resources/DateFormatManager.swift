//
//  DateFormatManager.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 01/08/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
class DateFormatManager: NSObject {
    
    static let sharedInstance = DateFormatManager()
    
    let kDateMonthYearFormat: String = "dd/MM/yyyy"
    let kEnUsLocaleIdentifier: String = "en_US_POSIX"
    //yyyy/MMM/dd HH:mm:ss
    func getDateFormatterWithFormat(format: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = NSLocale(localeIdentifier: kEnUsLocaleIdentifier) as Locale
        return dateFormatter
    }
    
    func getStringFromDateWithFormat(date: Date, format: String) -> String {
        let dateFormatter = getDateFormatterWithFormat(format: format)
        
        return dateFormatter.string(from: date)
        
    }
    
    func getDateFromString(dateString: String) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatterGet.locale = Locale(identifier: "en_US_POSIX")
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        //dateFormatterPrint.dateFormat = "MMM, yyyy"
        
        if let date = dateFormatterGet.date(from: dateString) {
            print(dateFormatterPrint.string(from: date))
            
            return dateFormatterPrint.string(from: date)
        } else {
            print("There was an error decoding the string")
            return ""
        }
        
    }
    
    func getDateFromStringWithFormat(dateString: String, format: String) -> Date? {
        let dateFormatter = getDateFormatterWithFormat(format: format)
        if let dateInString: String = dateString {
            return dateFormatter.date(from: dateInString)!
        }
    }

}
