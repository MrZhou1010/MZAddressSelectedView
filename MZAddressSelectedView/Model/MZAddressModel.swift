//
//  MZAddressModel.swift
//  MZAddressSelectedView
//
//  Created by Mr.Z on 2019/11/8.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

class MZAddressModel: NSObject {
    
    /// 编码
    @objc var code: String = ""
    /// 名称
    @objc var name: String = ""
    /// 父id,对应上一级code
    @objc var pid: String = ""
    /// 等级
    @objc var level: String = ""
    /// 排序
    @objc var sort: String = ""
    /// 经度
    @objc var longitude: String = ""
    /// 纬度
    @objc var latitude: String = ""
}
