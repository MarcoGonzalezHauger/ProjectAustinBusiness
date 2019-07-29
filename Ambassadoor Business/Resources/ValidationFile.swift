//
//  ValidationFile.swift
//  Ambassadoor Business
//
//  Created by K Saravana Kumar on 22/07/19.
//  Copyright © 2019 Tesseract Freelance, LLC. All rights reserved.
//

import Foundation
class Validation {
    
    static let sharedInstance = Validation()
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
}
class Singleton {
    static let sharedInstance = Singleton()
    
    var company: CompanyUser
    
    init() {
        self.company = CompanyUser(dictionary: [:])
    }
    
    func setCompanyUser(user: CompanyUser) {
        company = user
    }
    
    func getCompanyUser() -> CompanyUser {
        return company
    }
    
}
