//
//  UserPaymentVC.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout
import CRNotifications

class UserPaymentVC: UIViewController {
    
    @IBOutlet weak var monthlyDataCV: UICollectionView!
    @IBOutlet weak var nodataLB: UILabel!
    @IBOutlet weak var debtUV: UIView!
    @IBOutlet weak var olddebtLB: UILabel!
    @IBOutlet weak var totaldebtLB: UILabel!
    
    var status: Int = 0
    
    let numberOfItemsPerRow: CGFloat = 1.0
    let leftAndRightPadding: CGFloat = 40.0
    
    var payments: [PaymentModel] = [PaymentModel]()
    var user: StudentModel?
    var editPayment: PaymentModel?
    
    var db: SQLManager = SQLManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = user!.name
        
        let alignedFlowLayout = monthlyDataCV.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.horizontalAlignment = .left
        
        initData()
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initData()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddPaymentVC" {
            let destinationVC = segue.destination as! AddPaymentVC
            destinationVC.user = sender as? StudentModel
            destinationVC.status = self.status
            if self.status == 1 {
                destinationVC.payment = self.editPayment
            }
        }
    }
    
    
    func initData() {
        payments.removeAll()
        payments = db.readPaymentTable(condQuery: "WHERE userId = \(user!.id) ORDER BY month_year ASC")
        
        if payments.count > 0 {
            nodataLB.isHidden = true
            monthlyDataCV.isHidden = false
            debtUV.isHidden = false
            
            var totalDebt: Float = 0.0
            
            for payment in payments {
                totalDebt += payment.unPaidAmount
            }
            totaldebtLB.text = "Toplam borç: " + String(format: "%.2f", totalDebt)
            
        } else {
            nodataLB.isHidden = false
            monthlyDataCV.isHidden = true
            debtUV.isHidden = true
        }
        monthlyDataCV.reloadData()
    }
    
    func initView() {
        debtUV.layer.cornerRadius = 6.0
        
        monthlyDataCV.dataSource = self
        monthlyDataCV.delegate = self
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onTapAddUB(_ sender: Any) {
        self.status = 0
        self.performSegue(withIdentifier: "AddPaymentVC", sender: self.user)
    }
    
}

extension UserPaymentVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return payments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthlyPayCell", for: indexPath) as! MonthlyPayCell
        if indexPath.row == payments.count - 1 {
            cell.editUB.isHidden = false
        } else {
            cell.editUB.isHidden = true
        }
        cell.initWithData(payment: payments[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension UserPaymentVC: UICollectionViewDelegate {
    
}

extension UserPaymentVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpcing = (numberOfItemsPerRow + 1) * leftAndRightPadding
        if let collection = self.monthlyDataCV {
            let width = (collection.bounds.width - totalSpcing) / numberOfItemsPerRow
            return CGSize(width: width, height: 182.0)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 8, left: 12, bottom: 8, right: 12)
    }
}

extension UserPaymentVC: MonthlyPayCellDelegate {
    func didSelectPaidStateUB(payment: PaymentModel) {
        var title = ""
        var alert = UIAlertController()
        var okAction = UIAlertAction()
        var query = ""
        
        if payment.status == 0 || payment.status == 2 {
            title = "Ödediğinden emin misin?"
            alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
            alert.addTextField(configurationHandler: {(textField) in
                textField.placeholder = String(format: "%.2f", payment.unPaidAmount)
                textField.keyboardType = .decimalPad
            })
            okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                
                let payAmount = ((alert.textFields![0].text! as NSString).floatValue).roundTo(places: 2.0)
                let rest = payment.unPaidAmount - payAmount
                if rest < 0.01 {
                    query = "status = '1', unpaidAmount = \(rest) WHERE id = \(payment.id)"
                } else {
                    query = "status = '2', unpaidAmount = \(rest) WHERE id = \(payment.id)"
                }
                if self.db.updateTable(tbName: self.db.PAYMENT_TABLE, condQuery: query) {
                    CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Ödeme Başarıyla Güncellendi.", dismissDelay: 2.0)
                    self.initData()
                } else {
                    CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
                }
            })
            
        } else {
            title = "Emin misin ödenmemiş?"
            alert = UIAlertController(title: "", message: title, preferredStyle: .alert)
            let rest = payment.rent + payment.electricity + payment.coldwater + payment.hotwater
            okAction = UIAlertAction(title: "OK", style: .default, handler: {(action) in
                query = "status = '0', unpaidAmount = \(rest) WHERE id = \(payment.id)"
                if self.db.updateTable(tbName: self.db.PAYMENT_TABLE, condQuery: query) {
                    CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Ödeme Başarıyla Güncellendi.", dismissDelay: 2.0)
                    self.initData()
                } else {
                    CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didSelectRemoveUB(payment: PaymentModel) {
        let alert = UIAlertController(title: "", message: "Bu ödeme bilgilerini silmek istediğinizden emin misiniz?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {(Void) in
            if self.db.deleteTable(tbName: self.db.PAYMENT_TABLE, id: payment.id) {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Ödeme Başarıyla Silindi.", dismissDelay: 2.0)
                self.initData()
            } else {
                CRNotifications.showNotification(type: CRNotifications.error, title: "Hata", message: "Hata oluştu.", dismissDelay: 2.0)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didSelectEditUB(payment: PaymentModel) {
        self.status = 1
        self.editPayment = payment
        self.performSegue(withIdentifier: "AddPaymentVC", sender: self.user)
    }
}

