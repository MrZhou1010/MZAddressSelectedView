# MZAddressSelectedView
仿京东地址选择器
// 地址选择器的使用

    let addressSelectedView = MZAddressSelectedView(frame: self.view.bounds)
    addressSelectedView.title = "选择地址"
    addressSelectedView.setupAllTitle(index: 0)
    addressSelectedView.callBackBlock = { (value, data) in
      btn.setTitle(value, for: .normal)
    }
    addressSelectedView.show()
    
    // 模型 -- MZAddressModel
    
    // 获取省市县街道方法
    fileprivate func getAreaData(tag: Int, code: String = "")
    通过修改该方法获取本地数据或者网络请求的数据
    
