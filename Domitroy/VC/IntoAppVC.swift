//
//  ViewController.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications
import MessageUI

class IntoAppVC: UIViewController {

    @IBOutlet weak var studentUB: UIButton!
    @IBOutlet weak var paymentUB: UIButton!
    @IBOutlet weak var priceUB: UIButton!
    @IBOutlet weak var saveUB: UIButton!
    @IBOutlet weak var manualMsgUB: UIButton!
    
    var db: SQLManager = SQLManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        studentUB.layer.cornerRadius = studentUB.frame.height / 2.0
        paymentUB.layer.cornerRadius = paymentUB.frame.height / 2.0
        priceUB.layer.cornerRadius = paymentUB.frame.height / 2.0
        saveUB.layer.cornerRadius = paymentUB.frame.height / 2.0
        manualMsgUB.layer.cornerRadius = paymentUB.frame.height / 2.0
        
        initSQLDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func initSQLDatabase() {
        db.createTable(tbName: db.STUDENT_TABLE, keyQuery: "id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(255), phone VARCHAR(255), email VARCHAR(255), room_number VARCHAR(255), check_in_date VARCHAR(255), initial_electricity FLOAT, initial_hot_water FLOAT, initial_cold_water FLOAT, parent_name VARCHAR(255), parent_phone VARCHAR(255)")
        
        db.createTable(tbName: db.PAYMENT_TABLE, keyQuery: "id INTEGER PRIMARY KEY AUTOINCREMENT, userId INT, month_year VARCHAR(255), rent FLOAT, electricity FLOAT, hotwater FLOAT, coldwater FLOAT, status INT, unpaidAmount FLOAT, electricity_usage FLOAT, hot_water_usage FLOAT, cold_water_usage FLOAT, last_electricity_usage FLOAT, last_hot_water_usage FLOAT, last_cold_water_usage FLOAT")
    }

    @IBAction func onTapStudentUB(_ sender: Any) {
        self.performSegue(withIdentifier: "goStudentManage", sender: nil)
    }
    
    @IBAction func onTapPaymentUB(_ sender: Any) {
        self.performSegue(withIdentifier: "goPaymentManager", sender: nil)
    }
    
    @IBAction func onTapPriceUB(_ sender: Any) {
        self.performSegue(withIdentifier: "goPriceManager", sender: nil)
    }
    
    @IBAction func onTapSaveUB(_ sender: Any) {
        var content: String = ""
        var users: [StudentModel] = [StudentModel]()
        users = db.readStudentTable(condQuery: "")
        if users.count == 0 {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Veri yok.", dismissDelay: 2.0)
            return
        }
        for user in users {
            content += "İsim: " + user.name + "\n" + "Telefon numarası: " + user.phone + "\n" + "E-posta: " + user.email + "\n" + "Oda numarası: " + user.room_number + "\n" + "Giriş tarihi: " + user.check_in_date + "\n" + "Ebeveyn adı: " + user.parent_name + "\n" + "Ebeveyn Telefon Numarası: " + user.parent_phone + "\n" + "elektrik: " + String(format: "%.2f", user.initial_hot_water) + " Kw" + "\n" + "sıcak su: " + String(format: "%.2f", user.initial_hot_water) + " m³" + "\n" + "soğuk su: " + String(format: "%.2f", user.initial_cold_water) + " m³"
            var paymentsByUser: [PaymentModel] = [PaymentModel]()
            paymentsByUser = db.readPaymentTable(condQuery: "WHERE userId = '\(user.id)'")
            for payment in paymentsByUser {
                content += "\n\n\t" + payment.month_year + "\n\t\t" + "kira: " + String(format: "%.2f", payment.rent) + "\n\t\t" + "elektrik: " + String(format: "%.2f", payment.electricity) + "\n\t\t" + "sıcak su: " + String(format: "%.2f", payment.hotwater) + "\n\t\t" + "soğuk su: " + String(format: "%.2f", payment.coldwater) + "\n\t\t" + "Elektrik Kullanımı Güncel sayaç değeri: " + String(format: "%.2f", payment.last_electricity_usage) + "Kw" + "\n\t\t" + "Bu Ay Elektrik Kullanımı: " + String(format: "%.2f", payment.electricity_usage) + " Kw" + "\n\t\t" + "Sıcak su Kullanımı Güncel sayaç değeri: " + String(format: "%.2f", payment.last_hot_water_usage) + " m³"  + "\n\t\t" + "Bu Ay Sıcak su Kullanımı: " + String(format: "%.2f", payment.hot_water_usage) + " m³" + "\n\t\t" + "Soğuk su Kullanımı Güncel sayaç değeri: " + String(format: "%.2f", payment.last_cold_water_usage) + " m³" + "\n\t\t" + "Bu Ay Soğuk su Kullanımı: " + String(format: "%.2f", payment.cold_water_usage) + " m³" + "\n\t\t" + "borç: " + String(format: "%.2f", payment.unPaidAmount)
            }
            content += "\n\n\n"
        }
        print(content)
        
        let strFileName: String = "AcademicStudioInformation" + DateUtil.covertDateToString(dateFormat: "yyyyMMddHHmmss", date: Date())
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileName = "\(strFileName).txt"
        let fileURL: URL = dir!.appendingPathComponent(fileName)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error")
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func onTapManualMsgUBTap(_ sender: Any) {
        var users: [StudentModel] = [StudentModel]()
        users = db.readStudentTable(condQuery: "")
        
        var userPhones: [String] = [String]()
        for user in users {
            userPhones.append(user.phone)
        }
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = userPhones
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
    }
}

extension IntoAppVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

