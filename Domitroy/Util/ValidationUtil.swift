//
//  ValidationUtil.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class ValidationUtil {
    
    static func emailValidation(value: String)->Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: value)
    }
    
    static func phoneValidation(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        return phoneTest.evaluate(with: value)
    }
}
