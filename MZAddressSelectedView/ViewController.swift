//
//  ViewController.swift
//  MZAddressSelectedView
//
//  Created by Mr.Z on 2019/11/8.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupUI()
    }
    
    private func setupUI() {
        let addressBtn = UIButton(type: .custom)
        addressBtn.frame = CGRect(x: 16.0, y: 200.0, width: UIScreen.main.bounds.size.width - 32.0, height: 50.0)
        addressBtn.backgroundColor = UIColor.orange
        addressBtn.layer.cornerRadius = 5.0
        addressBtn.setTitle("选择地址", for: .normal)
        addressBtn.setTitleColor(UIColor.black, for: .normal)
        addressBtn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        self.view.addSubview(addressBtn)
    }
    
    @objc private func btnClick(btn: UIButton) {
        let addressSelectedView = MZAddressSelectedView(frame: self.view.bounds)
        addressSelectedView.title = "选择地址"
        // 添加线条渐变效果
        addressSelectedView.isGradientLine = true
        addressSelectedView.setupAllTitle(index: 0)
        addressSelectedView.callBackBlock = { (modelArr) in
            var value = ""
            for model in modelArr {
                value = value + model.name + " "
            }
            value = value.trimmingCharacters(in: .whitespaces)
            btn.setTitle(value, for: .normal)
        }
        addressSelectedView.show()
    }
}
