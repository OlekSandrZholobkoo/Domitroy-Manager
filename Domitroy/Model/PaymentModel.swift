//
//  PaymentModel.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation

class PaymentModel {
    var id: Int
    var userId: Int
    var month_year: String
    var rent: Float
    var electricity: Float
    var hotwater: Float
    var coldwater: Float
    var status: Int
    var unPaidAmount: Float
    var electricity_usage: Float
    var hot_water_usage: Float
    var cold_water_usage: Float
    var last_electricity_usage: Float
    var last_hot_water_usage: Float
    var last_cold_water_usage: Float

    init(id: Int, userId: Int, month_year: String, rent: Float, electricity: Float, hotwater: Float, coldwater: Float, status: Int, unPaidAmount: Float, electricity_usage: Float, hot_water_usage: Float, cold_water_usage: Float, last_electricity_usage: Float, last_hot_water_usage: Float, last_cold_water_usage: Float) {
        self.id = id
        self.userId = userId
        self.month_year = month_year
        self.rent = rent
        self.electricity = electricity
        self.hotwater = hotwater
        self.coldwater = coldwater
        self.status = status
        self.unPaidAmount = unPaidAmount
        self.electricity_usage = electricity_usage
        self.hot_water_usage = hot_water_usage
        self.cold_water_usage = cold_water_usage
        self.last_electricity_usage = last_electricity_usage
        self.last_hot_water_usage = last_hot_water_usage
        self.last_cold_water_usage = last_cold_water_usage
    }
}
