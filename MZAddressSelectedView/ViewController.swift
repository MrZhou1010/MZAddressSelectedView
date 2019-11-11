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
        addressBtn.frame = CGRect(x: 50, y: 200, width: 300, height: 50)
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
        addressSelectedView.setupAllTitle(index: 0)
        addressSelectedView.callBackBlock = { (value, data) in
            btn.setTitle(value, for: .normal)
        }
        addressSelectedView.show()
    }
}

