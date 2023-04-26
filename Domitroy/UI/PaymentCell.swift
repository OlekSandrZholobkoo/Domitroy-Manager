//
//  PaymentCell.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

protocol PaymentCellDelegate {
    func didSelectCell(user: StudentModel)
}

class PaymentCell: UITableViewCell {

    @IBOutlet weak var containUV: UIView!
    @IBOutlet weak var nameLB: UILabel!
    
    var user: StudentModel?
    var delegate: PaymentCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
        
        let tapContainUV = UITapGestureRecognizer(target: self, action: #selector(onTapContainUV))
        containUV.addGestureRecognizer(tapContainUV)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWithData(user: StudentModel) {
        self.user = user
        nameLB.text = user.name
    }
    
    @objc func onTapContainUV() {
        delegate?.didSelectCell(user: self.user!)
    }
}
