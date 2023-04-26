//
//  MonthlyPayCell.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

protocol MonthlyPayCellDelegate {
    func didSelectPaidStateUB(payment: PaymentModel)
    func didSelectRemoveUB(payment: PaymentModel)
    func didSelectEditUB(payment: PaymentModel)
}

class MonthlyPayCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLB: UILabel!
    @IBOutlet weak var rentLB: UILabel!
    @IBOutlet weak var electricityLB: UILabel!
    @IBOutlet weak var hotLB: UILabel!
    @IBOutlet weak var coldLB: UILabel!
    @IBOutlet weak var totalLB: UILabel!
    @IBOutlet weak var paidStateLB: UIButton!
    @IBOutlet weak var conatinerUV: UIView!
    @IBOutlet weak var editUB: UIButton!
    
    var model: PaymentModel?
    var delegate: MonthlyPayCellDelegate?
    
    override func awakeFromNib() {
        conatinerUV.setShadowToUIView(radius: 4.0, type:.SMALL)
    }
    
    func initWithData(payment: PaymentModel) {
        model = payment
        
        dateLB.text = model!.month_year
        rentLB.text = String(format: "%.2f", model!.rent)
        electricityLB.text = String(format: "%.2f", model!.electricity)
        coldLB.text = String(format: "%.2f", model!.coldwater)
        hotLB.text = String(format: "%.2f", model!.hotwater)
        let total: Float = model!.rent + model!.electricity + model!.hotwater + model!.coldwater
        
        if model!.status == 0 {
            paidStateLB.setTitle("Ödenmedi", for: .normal)
            paidStateLB.setTitleColor(.red, for: .normal)
        } else if model!.status == 1 {
            paidStateLB.setTitle("Ödendi", for: .normal)
            paidStateLB.setTitleColor(.green, for: .normal)
        } else if model!.status == 2 {
            paidStateLB.setTitle("Tamamlanmamış", for: .normal)
            paidStateLB.setTitleColor(.blue, for: .normal)
        }
        var strAmount = "Toplam: " + String(format: "%.2f", total)
               
        if model!.status != 0 && model!.unPaidAmount.roundTo(places: 2.0) != 0.00 {
            strAmount += " / " + String(format: "%.2f", model!.unPaidAmount)
        }
        
        totalLB.text = strAmount
        
    }
    
    @IBAction func onTapPaidStateUB(_ sender: Any) {
        delegate?.didSelectPaidStateUB(payment: self.model!)
    }
    
    @IBAction func onTapRemoveUB(_ sender: Any) {
        delegate?.didSelectRemoveUB(payment: self.model!)
    }
    
    @IBAction func onTapEditUB(_ sender: Any) {
        delegate?.didSelectEditUB(payment: self.model!)
    }
}
