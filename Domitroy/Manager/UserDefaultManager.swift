//
//  UserDefaultManager.swift
//  Domitroy
//
//  Created by Aira on 15/10/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

let PRICE_ELECTRICITY: String = "price_electricty"
let PRICE_HOT_WATER: String = "price_hot_water"
let PRICE_COLD_WATER: String = "price_cold_water"

class UserDefaultManager {
    var shared: UserDefaults?
    
    init() {
        shared = UserDefaults.standard
    }
    
    func setUserDefaultString(key: String, value: String) {
        shared!.set(value, forKey: key)
    }
    
    func getUserDefaultString(key: String) -> String {
        return shared!.string(forKey: key)!
    }
    
    func setUserDefaultBool(key: String, value: Bool) {
        shared!.set(value, forKey: key)
    }
    
    func getUserDefaultBool(key: String) -> Bool {
        return shared!.bool(forKey: key)
    }
    
    func setUserDefaultFloat(key: String, value: Float) {
        shared?.set(value, forKey: key)
    }
    
    func getUserDefaultFloat(key: String) -> Float {
        return shared!.float(forKey: key)
    }
    
    func checkSetValue(key: String) -> Bool {
        if shared!.object(forKey: key) == nil {
            return false
        } else {
            return true
        }
    }
}
