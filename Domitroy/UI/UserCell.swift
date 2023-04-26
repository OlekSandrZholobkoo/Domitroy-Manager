//
//  UserCell.swift
//  Domitroy
//
//  Created by Aira on 24/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

protocol UserCellDelegate {
    func didSelectDetail(user: StudentModel)
    func didSelectEdit(user: StudentModel)
    func didSelectRemove(user: StudentModel)
}

class UserCell: UITableViewCell {

    @IBOutlet weak var containUV: UIView!
    @IBOutlet weak var nameLB: UILabel!
    
    var delegate: UserCellDelegate?
    var user: StudentModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containUV.setShadowToUIView(radius: 4.0, type: .MEDIUM)
    }
    
    func initCellWithData(user: StudentModel) {
        self.user = user
        nameLB.text = user.name
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onTapDetailUB(_ sender: Any) {
        delegate!.didSelectDetail(user: self.user!)
    }
    
    @IBAction func onTapEditUB(_ sender: Any) {
        delegate!.didSelectEdit(user: self.user!)
    }
    
    @IBAction func onTapRemoveUB(_ sender: Any) {
        delegate!.didSelectRemove(user: self.user!)
    }
}
