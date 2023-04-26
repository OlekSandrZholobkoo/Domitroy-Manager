//
//  AddStudentVC.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import DatePicker
import CRNotifications

class AddStudentVC: UIViewController {

    @IBOutlet weak var nameTF: CustomTF!
    @IBOutlet weak var phoneTF: CustomTF!
    @IBOutlet weak var emailTF: CustomTF!
    @IBOutlet weak var roomTF: CustomTF!
    @IBOutlet weak var regdateTF: CustomTF!
    @IBOutlet weak var saveUB: UIButton!
    @IBOutlet weak var parentNameTF: CustomTF!
    @IBOutlet weak var parentPhoneTF: CustomTF!
    @IBOutlet weak var initialElectricty: CustomTF!
    @IBOutlet weak var initialHotWater: CustomTF!
    @IBOutlet weak var initialColdWater: CustomTF!
    
    let db: SQLManager = SQLManager()

    var student: StudentModel?
    var status: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nameTF.keyboardType = .default
        phoneTF.keyboardType = .phonePad
        emailTF.keyboardType = .emailAddress
        roomTF.keyboardType = .default
        parentNameTF.keyboardType = .default
        parentPhoneTF.keyboardType = .phonePad
        initialElectricty.keyboardType = .decimalPad
        initialHotWater.keyboardType = .decimalPad
        initialColdWater.keyboardType = .decimalPad
        
        nameTF.alignment = .left
        phoneTF.alignment = .left
        emailTF.alignment = .left
        roomTF.alignment = .left
        regdateTF.alignment = .left
        parentNameTF.alignment = .left
        parentPhoneTF.alignment = .left
        initialElectricty.alignment = .right
        initialHotWater.alignment = .right
        initialColdWater.alignment = .right
        
        initUIView(status: status)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */
    
    func initUIView(status: Int) {
        if status == 0 {
            self.title = "Öğrenci ekle"
        } else if status == 1 {
            self.title = "Öğrenciyi düzenle"
        } else {
            self.title = "Öğrenci detay"
        }
        
        if status == 0 || status == 1 { // add, edit
            nameTF.editable = true
            phoneTF.editable = true
            emailTF.editable = true
            roomTF.editable = true
            parentPhoneTF.editable = true
            parentNameTF.editable = true
            initialElectricty.editable = true
            initialHotWater.editable = true
            initialColdWater.editable = true
        
            regdateTF.setValue(value: DateUtil.covertDateToString(dateFormat: "yyyy-MM-dd", date: Date()))
            
            let tapRegdate = UITapGestureRecognizer(target: self, action: #selector(onTapRegdate))
            regdateTF.addGestureRecognizer(tapRegdate)
            saveUB.isHidden = false
            saveUB.layer.cornerRadius = 6.0
        } else { //detail
            nameTF.editable = false
            phoneTF.editable = false
            emailTF.editable = false
            roomTF.editable = false
            parentPhoneTF.editable = false
            parentNameTF.editable = false
            initialElectricty.editable = false
            initialHotWater.editable = false
            initialColdWater.editable = false
            
            saveUB.isHidden = true
        }
        regdateTF.editable = false
        
        if status == 0 { //initialize value for add
            nameTF.setValue(value: "")
            phoneTF.setValue(value: "")
            emailTF.setValue(value: "")
            roomTF.setValue(value: "")
            parentPhoneTF.setValue(value: "")
            parentNameTF.setValue(value: "")
            initialElectricty.setValue(value: "")
            initialHotWater.setValue(value: "")
            initialColdWater.setValue(value: "")
            
            regdateTF.setValue(value: DateUtil.covertDateToString(dateFormat: "yyyy-MM-dd", date: Date()))
        } else { //initialize value for edit and detail
            nameTF.setValue(value: student!.name)
            phoneTF.setValue(value: student!.phone)
            emailTF.setValue(value: student!.email)
            roomTF.setValue(value: student!.room_number)
            regdateTF.setValue(value: student!.check_in_date)
            parentPhoneTF.setValue(value: student!.parent_phone)
            parentNameTF.setValue(value: student!.parent_name)
            initialElectricty.setValue(value: String(format: "%.2f", student!.initial_electricity))
            initialHotWater.setValue(value: String(format: "%.2f", student!.initial_hot_water))
            initialColdWater.setValue(value: String(format: "%.2f", student!.initial_cold_water))
        }
    }
    
    @objc func onTapRegdate() {
        let minDate = DatePickerHelper.shared.dateFrom(month: 01, year: 2020)
        let maxDate = DatePickerHelper.shared.dateFrom(month: 12, year: 2050)
        let today = Date()
                
        let datePicker = DatePicker()
        datePicker.setup(beginWith: today, min: minDate!, max: maxDate!){(selected, date) in
            if selected, let selectedDate = date {
                self.regdateTF.setValue(value: DateUtil.covertDateToString(dateFormat: "yyyy-MM-dd", date: selectedDate))
            }
        }
        datePicker.show(in: self)
    }
    
    @IBAction func onTapSaveUB(_ sender: Any) {
        let name = nameTF.getValue()
        let phone = phoneTF.getValue()
        let room = roomTF.getValue()
        let email = emailTF.getValue()
        let regdate = regdateTF.getValue()
        let parentName = parentNameTF.getValue()
        let parentPhone = parentPhoneTF.getValue()
        let initialElectricityUsage = initialElectricty.getValue()
        let initialColdWaterUsage = initialColdWater.getValue()
        let initialHotWaterUsage = initialHotWater.getValue()
        
        if name.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "İsim Boş.", dismissDelay: 2.0)
            return
        }
        if phone.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Telefon Numarası Boş.", dismissDelay: 2.0)
            return
        }
//        if email.isEmpty {
//            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "E-posta Boş.", dismissDelay: 2.0)
//            return
//        }
//        if !email.isEmpty && !ValidationUtil.emailValidation(value: email) {
//            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "E-posta geçersiz.", dismissDelay: 2.0)
//            return
//        }
        if room.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Oda Numarası Boş.", dismissDelay: 2.0)
            return
        }
        if parentName.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Ebeveyn Adı Boş.", dismissDelay: 2.0)
            return
        }
        if parentPhone.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Ebeveyn Telefon Numarası Boş.", dismissDelay: 2.0)
            return
        }
        if initialElectricityUsage.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Elektrik Kullanımı Boştur.", dismissDelay: 2.0)
            return
        }
        if initialHotWaterUsage.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Sıcak Su Kullanımı Boştur.", dismissDelay: 2.0)
            return
        }
        if initialColdWaterUsage.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Soğuk Su Kullanımı Boştur.", dismissDelay: 2.0)
            return
        }
        
        
        if status == 0 {
            let insertQuery: String = "(name, phone, email, room_number, check_in_date, initial_electricity, initial_hot_water, initial_cold_water, parent_name, parent_phone) VALUES ('\(name)', '\(phone)', '\(email)', '\(room)', '\(regdate)', '\(initialElectricityUsage)', '\(initialHotWaterUsage)', '\(initialColdWaterUsage)', '\(parentName)', '\(parentPhone)')"
            if db.insertTable(tbName: db.STUDENT_TABLE, insertQuery: insertQuery) {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Başarı ile eklendi.", dismissDelay: 2.0)
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
            }
        } else if status == 1 {
            let updateQuery: String = "name = '\(name)', phone = '\(phone)', email = '\(email)', room_number = '\(room)', check_in_date = '\(regdate)', initial_electricity = '\(initialElectricityUsage)', initial_hot_water = '\(initialHotWaterUsage)', initial_cold_water = '\(initialColdWaterUsage)', parent_name = '\(parentName)', parent_phone = '\(parentPhone)' WHERE id = '\(student!.id)'"
            if db.updateTable(tbName:db.STUDENT_TABLE, condQuery: updateQuery) {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Öğrenci Başarıyla Güncellendi.", dismissDelay: 2.0)
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
            }
        }
        
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
