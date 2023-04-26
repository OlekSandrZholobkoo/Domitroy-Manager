//
//  PaymentVC.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import MonthYearPicker
import CRNotifications
import SendGrid_Swift

class PaymentVC: UIViewController {

    @IBOutlet weak var userTV: UITableView!
    @IBOutlet weak var nodataLB: UILabel!
    
    let db: SQLManager = SQLManager()
    
    var students: [StudentModel] = [StudentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initView()
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserPaymentVC" {
            let destinationVC = segue.destination as! UserPaymentVC
            destinationVC.user = sender as? StudentModel
        }
    }
    
    func initData() {
        students.removeAll()
        students = db.readStudentTable(condQuery: "")
        
        if students.count > 0 {
            nodataLB.isHidden = true
            userTV.isHidden = false
        } else {
            nodataLB.isHidden = false
            userTV.isHidden = true
        }
        userTV.reloadData()
    }
    
    func initView() {
        userTV.rowHeight = UITableView.automaticDimension
        userTV.estimatedRowHeight = 98.0
        userTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        userTV.dataSource = self
    }

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapSendToPartnerUB(_ sender: Any) {
        let alert = UIAlertController(title: "Ay seç", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: 20), size: CGSize(width: 250, height: 140)))
        picker.minimumDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        alert.view.addSubview(picker)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let selectedMonth = DateUtil.covertDateToString(dateFormat: "yyyy-MM", date: picker.date)
            var paymentModels: [PaymentModel] = [PaymentModel]()
            paymentModels = self.db.readPaymentTable(condQuery: "WHERE month_year = '\(selectedMonth)'")
            if paymentModels.count == 0 {
                CRNotifications.showNotification(type: CRNotifications.info, title: "Bilgi", message: "Veri yok.", dismissDelay: 2.0)
            } else {
                self.sendEmailToPartner(payments: paymentModels, month: selectedMonth)
            }
            
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    func sendEmailToPartner(payments: [PaymentModel], month: String) {
        var content: String = ""
        var totalByMonth: Float = 0.0
        var totalRent: Float = 0.0
        var totalElec: Float = 0.0
        var totalHot: Float = 0.0
        var totalCold: Float = 0.0
        for payment in payments {
            let totalByUser = payment.rent + payment.hotwater + payment.coldwater + payment.rent
            totalByMonth += totalByUser
            let users: [StudentModel] = db.readStudentTable(condQuery: "Where id = '\(payment.userId)'")
            let userName = users[0].name
            content += userName + "\n\t" + "kira: " + String(format: "%.2f", payment.rent) + "\n\t" + "elektrik: " + String(format: "%.2f", payment.electricity) + "\n\t" + "sıcak su: " + String(format: "%.2f", payment.hotwater) + "\n\t" + "soğuk su: " + String(format: "%.2f", payment.coldwater) + "\n\t" + "Toplam: " + String(format: "%.2f", totalByUser) + "\n\n"
            
            totalRent += payment.rent
            totalElec += payment.electricity
            totalHot += payment.hotwater
            totalCold += payment.coldwater
        }
        
        content += month + "\n" + "Toplam: " + String(format: "%.2f", totalByMonth) + "\n\t" + "kira: " + String(format: "%.2f", totalRent) + "\n\t" + "elektrik: " + String(format: "%.2f", totalElec) + "\n\t" + "sıcak su: " + String(format: "%.2f", totalHot) + "\n\t" + "soğuk su: " + String(format: "%.2f", totalCold)
        print(content)
        
        let strFileName: String = "AcademicStudio" + month
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
}

extension PaymentVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        cell.initCellWithData(user: students[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension PaymentVC: PaymentCellDelegate {
    func didSelectCell(user: StudentModel) {
        self.performSegue(withIdentifier: "UserPaymentVC", sender: user)
    }
}
