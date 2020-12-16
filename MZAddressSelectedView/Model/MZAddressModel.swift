//
//  MZAddressModel.swift
//  MZAddressSelectedView
//
//  Created by Mr.Z on 2019/11/8.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

class MZAddressModel: NSObject {
    @objc var code: String = "" /// 编码
    @objc var name: String = "" /// 名称
    @objc var pid: String = "" /// 父id,对应上一级code
    @objc var level: String = "" /// 等级
    @objc var sort: String = "" /// 排序
    @objc var longitude: String = "" /// 经度
    @objc var latitude: String = "" /// 纬度
}
