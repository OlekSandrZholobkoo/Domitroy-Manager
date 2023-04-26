//
//  CustomTF.swift
//  Domitroy
//
//  Created by Aira on 23/09/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

@IBDesignable class CustomTF: UIView {

    @IBOutlet var containUV: UIView!
    @IBOutlet weak var contentUV: UIView!
    @IBOutlet weak var ic_img: UIImageView!
    @IBOutlet weak var valueTF: UITextField!
    
    @IBInspectable var icon: UIImage = UIImage() {
        didSet {
            ic_img.image = icon
        }
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            self.valueTF.placeholder = placeholder
        }
    }
    
    @IBInspectable var editable: Bool = false {
        didSet {
            self.valueTF.isEnabled = editable
        }
    }
    
    @IBInspectable var keyboardType: UIKeyboardType = .default {
        didSet {
            self.valueTF.keyboardType = keyboardType
        }
    }
    
    @IBInspectable var alignment: NSTextAlignment = .left {
        didSet {
            self.valueTF.textAlignment = alignment
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUPXIB()
        setUP()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUPXIB()
        setUP()
    }
    
    func setUPXIB() {
        Bundle.main.loadNibNamed("CustomTF", owner: self, options: nil)
        addSubview(containUV)
        containUV.frame = self.bounds
        containUV.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func setUP() {
        self.contentUV.layer.cornerRadius = 6.0
        self.contentUV.layer.borderWidth = 1.0
        self.contentUV.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func getValue() -> String {
        return self.valueTF.text!
    }
    
    func setValue(value: String) {
        self.valueTF.text = value
    }

}
