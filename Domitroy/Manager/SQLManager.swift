//
//  SQLManager.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import Foundation
import SQLite3

class SQLManager {
    var db: OpaquePointer?
    let dbPath = "Domitroy.sqlite"
    let STUDENT_TABLE = "student"
    let PAYMENT_TABLE = "payment"
    
    init() {
        db = openDatabase()
    }
    
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbPath)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
            return nil
        }
        else
        {
            print("Successfully opened connection to database at \(dbPath)")
            return db
        }
    }
    
    func createTable(tbName: String, keyQuery: String) {
        let createTableQuery = "CREATE TABLE IF NOT EXISTS \(tbName) (" + keyQuery + ");"
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("\(tbName) table created.")
            } else {
                print("\(tbName) table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        
        sqlite3_finalize(createTableStatement)
    }
    
    func insertTable(tbName: String, insertQuery: String) -> Bool {
        var result: Bool = false
        let insertTableQuery = "INSERT INTO \(tbName) \(insertQuery);"
        var insertTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertTableQuery, -1, &insertTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(insertTableStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
                result = true
            } else {
                print("Could not insert row.\(tbName) \(insertQuery)")
                result = false
            }
        } else {
            print("INSERT statement could not be prepared. \(tbName)")
            result = false
        }
        
        sqlite3_finalize(insertTableStatement)
        return result
    }
    
    func updateTable(tbName: String, condQuery: String) -> Bool {
        var result: Bool = false
        let updateStatementString = "UPDATE \(tbName) SET \(condQuery);"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) ==
            SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("\nSuccessfully updated row.")
                result = true
            } else {
                print("\nCould not update row.")
                result = false
            }
        } else {
            print("\nUPDATE statement is not prepared")
            result = false
        }
        sqlite3_finalize(updateStatement)
        return result
    }
    
    @discardableResult
    func deleteTable(tbName: String, id: Int) -> Bool {
        var result: Bool = false
        let deleteStatementStirng = "DELETE FROM \(tbName) WHERE id = ?;"
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
                result = true
            } else {
                print("Could not delete row.")
                result = false
            }
        } else {
            print("DELETE statement could not be prepared")
            result = false
        }
        sqlite3_finalize(deleteStatement)
        return result
    }
    
    func readStudentTable(condQuery: String) -> [StudentModel]{
        var studentArr: [StudentModel] = [StudentModel]()
        let readTableQuery = "SELECT * FROM \(STUDENT_TABLE) \(condQuery);"
        var readTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, readTableQuery, -1, &readTableStatement, nil) == SQLITE_OK {
            while sqlite3_step(readTableStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(readTableStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(readTableStatement, 1)))
                let phone = String(describing: String(cString: sqlite3_column_text(readTableStatement, 2)))
                let email = String(describing: String(cString: sqlite3_column_text(readTableStatement, 3)))
                let room_number = String(describing: String(cString: sqlite3_column_text(readTableStatement, 4)))
                let check_in_date = String(describing: String(cString: sqlite3_column_text(readTableStatement, 5)))
                let initial_electricity = sqlite3_column_double(readTableStatement, 6)
                let initial_hot_water = sqlite3_column_double(readTableStatement, 7)
                let initial_cold_water = sqlite3_column_double(readTableStatement, 8)
                let parent_name = String(describing: String(cString: sqlite3_column_text(readTableStatement, 9)))
                let parent_phone = String(describing: String(cString: sqlite3_column_text(readTableStatement, 10)))
                
                let student: StudentModel = StudentModel(id: Int(id), name: name, phone: phone, email: email, room_number: room_number, check_in_date: check_in_date, initial_electricity: Float(initial_electricity), initial_hot_water: Float(initial_hot_water), initial_cold_water: Float(initial_cold_water), parent_name: parent_name, parent_phone: parent_phone)
                
                studentArr.append(student)
                
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(readTableStatement)
        return studentArr
    }
    
    func readPaymentTable(condQuery: String) -> [PaymentModel]{
        var paymentArr: [PaymentModel] = [PaymentModel]()
        let readTableQuery = "SELECT * FROM \(PAYMENT_TABLE) \(condQuery);"
        var readTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, readTableQuery, -1, &readTableStatement, nil) == SQLITE_OK {
            while sqlite3_step(readTableStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(readTableStatement, 0)
                let userId = sqlite3_column_int(readTableStatement, 1)
                let month_year = String(describing: String(cString: sqlite3_column_text(readTableStatement, 2)))
                let rent = sqlite3_column_double(readTableStatement, 3)
                let electricity = sqlite3_column_double(readTableStatement, 4)
                let hotwater = sqlite3_column_double(readTableStatement, 5)
                let coldwater = sqlite3_column_double(readTableStatement, 6)
                let status = sqlite3_column_int(readTableStatement, 7)
                let unpaidamount = sqlite3_column_double(readTableStatement, 8)
                let electricity_usage = sqlite3_column_double(readTableStatement, 9)
                let hot_water_usage = sqlite3_column_double(readTableStatement, 10)
                let cold_water_usage = sqlite3_column_double(readTableStatement, 11)
                let last_electricity_usage = sqlite3_column_double(readTableStatement, 12)
                let last_hot_water_usage = sqlite3_column_double(readTableStatement, 13)
                let last_cold_water_usage = sqlite3_column_double(readTableStatement, 14)
                let payment: PaymentModel = PaymentModel(id: Int(id), userId: Int(userId), month_year: month_year, rent: Float(rent), electricity: Float(electricity), hotwater: Float(hotwater), coldwater: Float(coldwater), status: Int(status), unPaidAmount: Float(unpaidamount), electricity_usage: Float(electricity_usage), hot_water_usage: Float(hot_water_usage), cold_water_usage: Float(cold_water_usage), last_electricity_usage: Float(last_electricity_usage), last_hot_water_usage: Float(last_hot_water_usage), last_cold_water_usage: Float(last_cold_water_usage))
                paymentArr.append(payment)
                
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(readTableStatement)
        return paymentArr
    }
}
