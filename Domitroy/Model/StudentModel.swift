//
//  StudentModel.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class StudentModel {
    var id: Int
    var name: String
    var phone: String
    var email: String
    var room_number: String
    var check_in_date: String
    var initial_electricity: Float
    var initial_hot_water: Float
    var initial_cold_water: Float
    var parent_name: String
    var parent_phone: String

    init(id: Int, name: String, phone: String, email: String, room_number: String, check_in_date: String, initial_electricity: Float, initial_hot_water: Float, initial_cold_water: Float, parent_name: String, parent_phone: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.room_number = room_number
        self.check_in_date = check_in_date
        self.initial_electricity = initial_electricity
        self.initial_hot_water = initial_hot_water
        self.initial_cold_water = initial_cold_water
        self.parent_name = parent_name
        self.parent_phone = parent_phone
    }
}
