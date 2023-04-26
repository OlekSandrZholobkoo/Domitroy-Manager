//
//  FloatExtension.swift
//  Domitroy
//
//  Created by Aira on 25/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

extension Float {
    
    func roundTo(places:Float) -> Float {
        let divisor: Float = Float(pow(10.0, Double(places)))
        return (self * divisor).rounded() / divisor
    }
    
    func roundToInt() -> Int {
        let strVal = String(format: "%.3f", self)
        let strComponent = strVal.components(separatedBy: ".")
        let strIntegerPart = strComponent[0]
        let strDecimalPart = strComponent[1]
        var intIntegerPart: Int = Int(strIntegerPart)!
        let floatDecimalPart: Float = (strDecimalPart as NSString).floatValue
        
        if intIntegerPart % 10 < 5 && intIntegerPart % 10 > 0 {
            intIntegerPart = intIntegerPart / 10 * 10 + 5
        } else if intIntegerPart % 10 > 5 {
            intIntegerPart = intIntegerPart / 10 * 10 + 10
        } else if intIntegerPart % 10 == 0 {
            if floatDecimalPart > 0.01 {
                intIntegerPart = intIntegerPart / 10 * 10 + 5
            } else {
                intIntegerPart = intIntegerPart / 10 * 10
            }
        } else if intIntegerPart % 10 == 5 {
            if floatDecimalPart > 0.01 {
                intIntegerPart = intIntegerPart / 10 * 10 + 10
            } else {
                intIntegerPart = intIntegerPart / 10 * 10 + 5
            }
        }
        return intIntegerPart
    }
}
