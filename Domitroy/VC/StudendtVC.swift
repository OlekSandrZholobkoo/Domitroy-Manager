//
//  StuendtVC.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit
import CRNotifications

class StudendtVC: UIViewController {
    
    @IBOutlet weak var studentTV: UITableView!
    @IBOutlet weak var noDataLB: UILabel!
    
    let db: SQLManager = SQLManager()
    
    var students: [StudentModel] = [StudentModel]()
    
    var status: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        if segue.identifier == "AddStudentVC" {
            let destinationVC = segue.destination as! AddStudentVC
            destinationVC.student = sender as? StudentModel
            destinationVC.status = self.status
        }
    }
    
    func initData() {
        students.removeAll()
        students = db.readStudentTable(condQuery: "")
        
        if students.count > 0 {
            noDataLB.isHidden = true
            studentTV.isHidden = false
        } else {
            noDataLB.isHidden = false
            studentTV.isHidden = true
        }
        studentTV.reloadData()
    }
    
    func initView() {
        studentTV.rowHeight = UITableView.automaticDimension
        studentTV.estimatedRowHeight = 98.0
        studentTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        studentTV.dataSource = self
    }

    @IBAction func onTapBackUB(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func onTapPluaUB(_ sender: Any) {
        self.status = 0
        self.performSegue(withIdentifier: "AddStudentVC", sender: nil)
    }
}

extension StudendtVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.initCellWithData(user: students[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension StudendtVC: UserCellDelegate {
    func didSelectDetail(user: StudentModel) {
        self.status = 2
        self.performSegue(withIdentifier: "AddStudentVC", sender: user)
    }
    
    func didSelectEdit(user: StudentModel) {
        self.status = 1
        self.performSegue(withIdentifier: "AddStudentVC", sender: user)
    }
    
    func didSelectRemove(user: StudentModel) {
        let alert = UIAlertController(title: "Sil", message: "Bu kullanıcıyı silmek istediğinizden emin misiniz?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) {(Void) in
            let payments: [PaymentModel] = self.db.readPaymentTable(condQuery: "WHERE userId = '\(user.id)'")
            for payment in payments {
                self.db.deleteTable(tbName: self.db.PAYMENT_TABLE, id: payment.id)
            }
            if self.db.deleteTable(tbName: self.db.STUDENT_TABLE, id: user.id) {
                CRNotifications.showNotification(type: CRNotifications.success, title: "Başarı", message: "Öğrenci Başarıyla Silindi.", dismissDelay: 2.0)
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
}
