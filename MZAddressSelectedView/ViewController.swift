//
//  ViewController.swift
//  MZAddressSelectedView
//
//  Created by 木木 on 2019/11/8.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let addressBtn = UIButton(type: .custom)
        addressBtn.frame = CGRect(x: 16, y: 200, width: UIScreen.main.bounds.size.width - 32, height: 50)
        addressBtn.backgroundColor = UIColor.orange
        addressBtn.layer.cornerRadius = 5.0
        addressBtn.setTitle("选择地址", for: .normal)
        addressBtn.setTitleColor(UIColor.black, for: .normal)
        addressBtn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        self.view.addSubview(addressBtn)
        
        let view = UIView(frame: CGRect(x: 16, y: 300, width: UIScreen.main.bounds.size.width - 32, height: 10))
        view.backgroundColor = UIColor.clear
        view.setGradientColor(colors: [UIColor.red.cgColor, UIColor.red.withAlphaComponent(0.1).cgColor], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
        self.view.addSubview(view)
    }

    @objc private func btnClick(btn: UIButton) {
        let addressSelectedView = MZAddressSelectedView(frame: self.view.bounds)
        addressSelectedView.title = "选择地址"
        addressSelectedView.isGradientLine = true
        addressSelectedView.setupAllTitle(index: 0)
        addressSelectedView.callBackBlock = { (modelArr) in
            var value = ""
            for model in modelArr {
                value = value + model.name! + " "
            }
            value = value.trimmingCharacters(in: .whitespaces)
            btn.setTitle(value, for: .normal)
        }
        addressSelectedView.show()
    }
}

