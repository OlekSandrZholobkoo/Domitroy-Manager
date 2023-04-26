//
//  PriceVC.swift
//  Domitroy
//
//  Created by Aira on 15/10/2020.
//  Copyright © 2020 Aira. All rights reserved.
//

import UIKit

class PriceVC: UIViewController {

    @IBOutlet weak var electricityTF: CustomTF!
    @IBOutlet weak var hotTF: CustomTF!
    @IBOutlet weak var coldTF: CustomTF!
    @IBOutlet weak var saveUB: UIButton!
    
    var isEditStatus: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        saveUB.layer.cornerRadius = 6.0
        initUIView(isEdit: false)
    }
    
    func initUIView(isEdit: Bool) {
        
        if isEdit {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(onTapEditUB))
            self.navigationItem.rightBarButtonItem?.tintColor = .white
            
        }
        
        saveUB.isHidden = !isEdit
        
        hotTF.alignment = .right
        hotTF.keyboardType = .decimalPad
        coldTF.alignment = .right
        coldTF.keyboardType = .decimalPad
        electricityTF.alignment = .right
        electricityTF.keyboardType = .decimalPad
        
        hotTF.editable = isEdit
        coldTF.editable = isEdit
        electricityTF.editable = isEdit
        
        let priceElectricity = UserDefaultManager().checkSetValue(key: PRICE_ELECTRICITY) ? UserDefaultManager().getUserDefaultFloat(key: PRICE_ELECTRICITY) : INITIAL_ELECTRICTY_PRICE
        let priceHotWater = UserDefaultManager().checkSetValue(key: PRICE_HOT_WATER) ? UserDefaultManager().getUserDefaultFloat(key: PRICE_HOT_WATER) : INITIAL_HOT_WATER_PRICE
        let priceColdWater = UserDefaultManager().checkSetValue(key: PRICE_COLD_WATER) ? UserDefaultManager().getUserDefaultFloat(key: PRICE_COLD_WATER) : INITIAL_COLD_WATER_PRICE
        
        electricityTF.setValue(value: String(format: "%.2f", priceElectricity))
        hotTF.setValue(value: String(format: "%.2f", priceHotWater))
        coldTF.setValue(value: String(format: "%.2f", priceColdWater))
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onTapSaveUB(_ sender: Any) {
        let priceElectricity = (electricityTF.getValue() as NSString).floatValue
        let priceHotWater = (hotTF.getValue() as NSString).floatValue
        let priceColdWater = (coldTF.getValue() as NSString).floatValue
        
        UserDefaultManager().setUserDefaultFloat(key: PRICE_ELECTRICITY, value: priceElectricity)
        UserDefaultManager().setUserDefaultFloat(key: PRICE_HOT_WATER, value: priceHotWater)
        UserDefaultManager().setUserDefaultFloat(key: PRICE_COLD_WATER, value: priceColdWater)
        isEditStatus = false
        initUIView(isEdit: isEditStatus)
    }
    
    @IBAction func onTapBackUB(_ sender: Any) {
        if !isEditStatus {
            self.navigationController?.popViewController(animated: true)
        } else {
            isEditStatus = false
            initUIView(isEdit: isEditStatus)
        }
        
    }
    
    @IBAction func onTapEditUB(_ sender: Any) {
        isEditStatus = true
        initUIView(isEdit: true)
    }
    
}
