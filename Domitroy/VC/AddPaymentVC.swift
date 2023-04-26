//
//  AddPaymentVC.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//
import UIKit
import MonthYearPicker
import CRNotifications
import SendGrid_Swift
import MessageUI

class AddPaymentVC: UIViewController {

    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var rentTF: CustomTF!
    @IBOutlet weak var electricityTF: CustomTF!
    @IBOutlet weak var hotTF: CustomTF!
    @IBOutlet weak var coldTF: CustomTF!
    @IBOutlet weak var saveUB: UIButton!
    
    var user: StudentModel?
    var db: SQLManager = SQLManager()
    var status: Int?
    var payment: PaymentModel?
    
    var priceElectricity: Float = 0.0
    var priceHotWater: Float = 0.0
    var priceColdWater: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Payment for \(user!.name)"
        // Do any additional setup after loading the view.
        
        priceElectricity = UserDefaultManager().checkSetValue(key: PRICE_ELECTRICITY) ? UserDefaultManager().getUserDefaultFloat(key: PRICE_ELECTRICITY) : INITIAL_ELECTRICTY_PRICE
        priceHotWater = UserDefaultManager().checkSetValue(key: PRICE_HOT_WATER) ? UserDefaultManager().getUserDefaultFloat(key: PRICE_HOT_WATER) : INITIAL_HOT_WATER_PRICE
        priceColdWater = UserDefaultManager().checkSetValue(key: PRICE_COLD_WATER) ? UserDefaultManager().getUserDefaultFloat(key: PRICE_COLD_WATER) : INITIAL_COLD_WATER_PRICE
        
        initUIView()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initUIView() {
        dateLB.text = DateUtil.covertDateToString(dateFormat: "yyyy-MM", date: Date())
        
        rentTF.keyboardType = .decimalPad
        rentTF.alignment = .right
        electricityTF.keyboardType = .decimalPad
        electricityTF.alignment = .right
        hotTF.keyboardType = .decimalPad
        hotTF.alignment = .right
        coldTF.keyboardType = .decimalPad
        coldTF.alignment = .right
        
        if status == 0 {
            self.title = "Ödeme Ekle"
            dateLB.text = DateUtil.covertDateToString(dateFormat: "yyyy-MM", date: Date())
        } else {
            self.title = "Ödemeyi Düzenle"
            dateLB.text = payment!.month_year
            rentTF.setValue(value: String(format: "%.2f", payment!.rent))
            electricityTF.setValue(value: String(format: "%.2f", payment!.last_electricity_usage))
            hotTF.setValue(value: String(format: "%.2f", payment!.last_hot_water_usage))
            coldTF.setValue(value: String(format: "%.2f", payment!.last_cold_water_usage))
        }
        saveUB.layer.cornerRadius = 6.0
    }
    
    @IBAction func onTapCalendarUB(_ sender: Any) {
        let alert = UIAlertController(title: "Ay seç", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width: 250, height: 140)))
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            self.dateLB.text = DateUtil.covertDateToString(dateFormat: "yyyy-MM", date: picker.date)
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    @IBAction func onTapSaveUB(_ sender: Any) {
        let rent = rentTF.getValue()
        let electricity = electricityTF.getValue()
        let hot = hotTF.getValue()
        let cold = coldTF.getValue()
        
        if rent.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Kira Boş.", dismissDelay: 2.0)
            return
        }
        if electricity.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Elektrik Boş.", dismissDelay: 2.0)
            return
        }
        if hot.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Sıcak Su Boş.", dismissDelay: 2.0)
            return
        }
        if cold.isEmpty {
            CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Soğuk Su Boştur.", dismissDelay: 2.0)
            return
        }
        
        var paymentModels: [PaymentModel] = [PaymentModel]()
        
        paymentModels = db.readPaymentTable(condQuery: "WHERE userId = \(user!.id) AND month_year < '\(dateLB.text!)' ORDER BY month_year ASC")
        
        var last_electricity_usage: Float = 0.0
        var last_hot_water_usage: Float = 0.0
        var last_cold_water_usage: Float = 0.0
        
        if paymentModels.count == 0 {
            last_electricity_usage = user!.initial_electricity
            last_hot_water_usage = user!.initial_hot_water
            last_cold_water_usage = user!.initial_cold_water
        } else {
            last_electricity_usage = paymentModels.last!.last_electricity_usage
            last_hot_water_usage = paymentModels.last!.last_hot_water_usage
            last_cold_water_usage = paymentModels.last!.last_cold_water_usage
        }
        
        let total_electricity_usage: Float = ((electricity as NSString).floatValue).roundTo(places: 2.0)
        let total_hot_water_usage: Float = ((hot as NSString).floatValue).roundTo(places: 2.0)
        let total_cold_water_usage: Float = ((cold as NSString).floatValue).roundTo(places: 2.0)
        
        let current_electricity_usage: Float = (total_electricity_usage - last_electricity_usage).roundTo(places: 2.0)
        let current_hot_water_usage: Float = (total_hot_water_usage - last_hot_water_usage).roundTo(places: 2.0)
        let current_cold_water_usage: Float = (total_cold_water_usage - last_cold_water_usage).roundTo(places: 2.0)
        
        
        let electricityPrice: Int = ((priceElectricity * current_electricity_usage).roundTo(places: 2.0)).roundToInt()
        let hotWaterPrice: Int = ((priceHotWater * current_hot_water_usage).roundTo(places: 2.0)).roundToInt()
        let coldWaterPrice: Int = ((priceColdWater * current_cold_water_usage).roundTo(places: 2.0)).roundToInt()
        
        
        let totalAmount: Float = ((rent as NSString).floatValue + Float(electricityPrice) + Float(hotWaterPrice) + Float(coldWaterPrice)).roundTo(places: 2.0)
        
        if status == 0 {
            let insertQuery: String = "(userId, month_year, rent, electricity, hotwater, coldwater, status, unpaidAmount, electricity_usage, hot_water_usage, cold_water_usage, last_electricity_usage, last_hot_water_usage, last_cold_water_usage) VALUES ('\(user!.id)', '\(dateLB.text ?? "")', '\(rent)', '\(electricityPrice)', '\(hotWaterPrice)', '\(coldWaterPrice)', 0, '\(totalAmount)', '\(current_electricity_usage)', '\(current_hot_water_usage)', '\(current_cold_water_usage)', '\(total_electricity_usage)', '\(total_hot_water_usage)', '\(total_cold_water_usage)')"
            if db.insertTable(tbName: db.PAYMENT_TABLE, insertQuery: insertQuery) {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Ödeme Bilgileri Başarıyla Eklendi.", dismissDelay: 2.0)
                
                showActionSheet(rent: rent, electricity: String(format: "%.2f", Float(electricityPrice)), hot: String(format: "%.2f", Float(hotWaterPrice)), cold: String(format: "%.2f", Float(coldWaterPrice)))
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
            }
        } else {
            let updateQuery: String = "month_year = '\(dateLB.text ?? "")', rent = '\(rent)', electricity = '\(electricityPrice)', hotwater = '\(hotWaterPrice)', coldwater = '\(coldWaterPrice)', unpaidAmount = '\(totalAmount)', electricity_usage = '\(current_electricity_usage)', hot_water_usage = '\(current_hot_water_usage)', cold_water_usage = '\(current_cold_water_usage)', last_electricity_usage = '\(total_electricity_usage)', last_hot_water_usage = '\(total_hot_water_usage)', last_cold_water_usage = '\(total_cold_water_usage)' WHERE id = '\(payment!.id)'"
            if db.updateTable(tbName:db.PAYMENT_TABLE, condQuery: updateQuery) {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Ödeme Başarıyla Güncellendi.", dismissDelay: 2.0)
                showActionSheet(rent: rent, electricity: String(format: "%.2f", Float(electricityPrice)), hot: String(format: "%.2f", Float(hotWaterPrice)), cold: String(format: "%.2f", Float(coldWaterPrice)))
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
            }
        }
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showActionSheet(rent: String, electricity: String, hot: String, cold: String) {
        let actionSheet = UIAlertController(title: "", message: "Yöntem Seçin", preferredStyle: .actionSheet)
        let total: Float = ((rent as NSString).floatValue + (electricity as NSString).floatValue + (hot as NSString).floatValue + (cold as NSString).floatValue).roundTo(places: 2.0)
        print(dateLB.text!)
        var debtPayments: [PaymentModel] = [PaymentModel]()
        debtPayments = db.readPaymentTable(condQuery: "WHERE userID = \(user!.id) AND month_year < '\(dateLB.text!)'")
        var oldDebt: Float = 0.0
        for payment in debtPayments {
            oldDebt += payment.unPaidAmount
        }
        
        let msgContent: String = "Merhaba \(dateLB.text ?? "") için oda ücretiniz aşağıdaki gibidir. \n Kira: \(rent) tl \n Elektrik: \(electricity) tl \n Sıcak su: \(hot) tl \n Soğuk su: \(cold) tl \n\n \(dateLB.text ?? "") İçin Toplam: \(String(format: "%.2f", total)) tl \n\n Eski Borç: \(String(format: "%.2f", oldDebt)) tl \n Toplam borç: \(String(format: "%.2f", oldDebt + total)) tl \n\n Academic Studio"
        
        let actionSms = UIAlertAction(title: "SMS ile gönder", style: .default) {(Void) in
            self.sendSMS(msg: msgContent)
        }
        let actionEmail = UIAlertAction(title: "E-posta ile gönder", style: .default) {(Void) in
            self.sendEmail(msg: msgContent)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionSms)
        actionSheet.addAction(actionEmail)
        actionSheet.addAction(actionCancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func sendSMS(msg: String) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = msg
            controller.recipients = [user!.phone, user!.parent_phone]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func sendEmail(msg: String) {
        let sendGrid = SendGrid(withAPIKey: SENDGRID_APIKEY)
        let content = SGContent(type: .plain, value: msg)
        let from = SGAddress(email: "academicstudioincek@gmail.com")
        let to = SGPersonalization(to: [SGAddress(email: user!.email)])
        
        let email = SendGridEmail(personalizations: [to], from: from, subject: "Sayın \(user!.name)", content: [content])
        
        sendGrid.send(email: email) {(response, error) in
            if error != nil {
                print("Failed")
            } else {
                print("Success")
            }
        }
    }
}

extension AddPaymentVC: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
