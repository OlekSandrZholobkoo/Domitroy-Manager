//
//  DateUtil.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class DateUtil {    
    static func covertDateToString(dateFormat: String, date: Date) -> String{
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        df.dateFormat = dateFormat
        let strDate = df.string(from: date)
        return strDate
    }
}
