# MZAddressSelectedView
仿京东地址选择器

// 地址选择器的使用

    let addressSelectedView = MZAddressSelectedView(frame: self.view.bounds)
    addressSelectedView.title = "选择地址"
    // 添加线条渐变效果
    addressSelectedView.isGradientLine = true
    addressSelectedView.setupAllTitle(index: 0)
    addressSelectedView.callBackBlock = { (value, data) in
        var value = ""
        for model in modelArr {
            value = value + model.name + " "
        }
        value = value.trimmingCharacters(in: .whitespaces)
        btn.setTitle(value, for: .normal)
    }
    addressSelectedView.show()
    
// 地址数据模型

    MZAddressModel
    
// 获取省市县街道方法

    注:通过修改该方法获取本地数据或者网络请求的数据
    fileprivate func getAreaData(tag: Int, code: String = "")
