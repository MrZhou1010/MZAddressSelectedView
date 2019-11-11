//
//  MZAddressSelectedView.swift
//  MZAddressSelectedView
//
//  Created by 木木 on 2019/11/8.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit
import MJExtension

/// 屏幕尺寸
let kScreenSize: CGSize = UIScreen.main.bounds.size
/// 屏幕宽度
let kScreenWidth: CGFloat = UIScreen.main.bounds.size.width
/// 屏幕高度
let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height
/// 适配比例
let kRectScale: CGFloat = (kScreenWidth / 375.0)
/// 主题色
let kThemeColor: UIColor = UIColor.red

extension UIView {
    /// 设置某几个角的圆角
    func setCorner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

class MZAddressSelectedView: UIView {
    
    /// 传递的数据
    public var callBackBlock: (_ value: String, _ idArr: [String]) -> () = { (value, data) in }
    
    public var title: String = "" {
        didSet {
            self.titleLab.text = title
        }
    }
    
    private var provinceArr = [MZAddressModel]()    /// 省
    private var cityArr = [MZAddressModel]()        /// 市
    private var countyArr = [MZAddressModel]()      /// 区/县
    private var regionArr = [MZAddressModel]()      /// 街道/乡镇
    
    private var titleArr = ["请选择"]
    private var selectedIdArr = [String]() /// 选择的数据index
    private var titleBtnArr = [UIButton]()
    private var tableViewArr = [UITableView]()
    
    private var isClick: Bool = false /// 判断是滚动还是点击

    private lazy var containView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: 300 * kRectScale))
        view.backgroundColor = UIColor.white
        view.setCorner(byRoundingCorners: [.topLeft, .topRight], radii: 5.0)
        return view
    }()
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel(frame: CGRect(x: 16 * kRectScale, y: 10 * kRectScale, width: 160 * kRectScale, height: 30 * kRectScale))
        lab.text = "请选择地址"
        lab.textColor = UIColor.black
        lab.font = UIFont.systemFont(ofSize: 18)
        lab.textAlignment = .left
        return lab
    }()
    
    private lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: kScreenWidth - 46 * kRectScale, y: 10 * kRectScale, width: 34 * kRectScale, height: 30 * kRectScale)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(kThemeColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(cancelBtnClicked(btn:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var sepLineView: UIView = {
        let view = UIView(frame: CGRect(x: 16 * kRectScale, y: 40 * kRectScale, width: kScreenWidth - 32 * kRectScale, height: 1))
        view.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return view
    }()
    
    private lazy var titleScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 50 * kRectScale, width: kScreenWidth, height: 30 * kRectScale))
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var lineView: UIView = {
        let lineView = UIView.init(frame: .zero)
        lineView.backgroundColor = kThemeColor
        return lineView
    }()
    
    private lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: self.titleScrollView.frame.maxY, width: kScreenWidth, height: 300 * kRectScale - self.titleScrollView.frame.maxY))
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.isHidden = true
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let currentPoint = touches.first?.location(in: self)
        if !self.containView.frame.contains(currentPoint ?? CGPoint()) {
            self.dismiss()
        }
    }
    
    private func setupUI() {
        self.addSubview(self.containView)
        self.containView.addSubview(self.titleLab)
        self.containView.addSubview(self.cancelBtn)
        self.containView.addSubview(self.sepLineView)
        self.containView.addSubview(self.titleScrollView)
        self.containView.addSubview(self.contentScrollView)
    }
    
    public func setupAllTitle(index: Int) {
        for view in self.titleScrollView.subviews {
            view.removeFromSuperview()
        }
        self.titleBtnArr.removeAll()
        var x: CGFloat = 16 * kRectScale
        for i in 0 ..< self.titleArr.count {
            let title: String = self.titleArr[i]
            let titleLenth: CGFloat = CGFloat(title.count * 15)
            let titleBtn: UIButton = UIButton(type: .custom)
            titleBtn.backgroundColor = UIColor.orange
            titleBtn.tag = i
            titleBtn.setTitle(title, for: .normal)
            titleBtn.setTitleColor(UIColor.black, for: .normal)
            titleBtn.setTitleColor(kThemeColor, for: .selected)
            titleBtn.isSelected = false
            titleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            titleBtn.frame = CGRect(x: x, y: 0, width: titleLenth, height: 30 * kRectScale)
            x += titleLenth + 6 * kRectScale
            titleBtn.addTarget(self, action: #selector(titleBtnClicked(btn:)), for: .touchUpInside)
            self.titleBtnArr.append(titleBtn)
            // 选中
            if i == index {
                self.titleBtnClicked(btn: titleBtn)
            }
            self.titleScrollView.addSubview(titleBtn)
            self.titleScrollView.contentSize = CGSize(width: x, height: 0)
        }
        self.contentScrollView.contentSize = CGSize(width: CGFloat(self.titleArr.count) * kScreenWidth, height: 0)
    }
    
    private func setupOneTableView(btnTag: Int) {
        var tableView: UITableView
        if self.tableViewArr.count == 0 {
            tableView = UITableView(frame: .zero, style: .plain)
            tableView.frame = CGRect(x: CGFloat(btnTag) * kScreenWidth, y: 0, width: kScreenWidth, height: self.contentScrollView.frame.size.height)
            tableView.tag = btnTag
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = UIColor.clear
            tableView.separatorStyle = .none
            self.contentScrollView.addSubview(tableView)
            self.tableViewArr.append(tableView)
            self.getAreaData(tag: 0)
        } else {
            if btnTag < self.tableViewArr.count {
                tableView = self.tableViewArr[btnTag]
            } else {
                tableView = UITableView(frame: .zero, style: .plain)
                tableView.frame = CGRect(x: CGFloat(btnTag) * kScreenWidth, y: 0, width: kScreenWidth, height: self.contentScrollView.frame.size.height)
                tableView.tag = btnTag
                tableView.delegate = self
                tableView.dataSource = self
                tableView.backgroundColor = UIColor.clear
                tableView.separatorStyle = .none
                self.contentScrollView.addSubview(tableView)
                self.tableViewArr.append(tableView)
            }
        }
    }
    
    @objc private func cancelBtnClicked(btn: UIButton) {
        self.dismiss()
    }
    
    @objc private func titleBtnClicked(btn: UIButton) {
        for tempBtn in self.titleBtnArr {
            tempBtn.isSelected = false
        }
        btn.isSelected = true
        self.isClick = true
        self.setupOneTableView(btnTag: btn.tag)
        UIView.animate(withDuration: 0.5) {
            self.lineView.frame = CGRect(x: btn.frame.minX + btn.frame.width * 0.25, y: btn.frame.height - 3, width: btn.frame.width * 0.5, height: 3)
        }
        self.titleScrollView.addSubview(self.lineView)
        self.contentScrollView.contentOffset = CGPoint(x: CGFloat(btn.tag) * kScreenWidth, y: 0)
    }
    
    public func show() {
        self.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.containView.frame = CGRect(x: 0, y: kScreenHeight - 300 * kRectScale, width: kScreenWidth, height: 300 * kRectScale)
        }
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.containView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: 300 * kRectScale)
        }) { (finish) in
            if finish {
                self.isHidden = true
            }
        }
    }
}

extension MZAddressSelectedView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.contentScrollView {
            let offset: CGFloat = scrollView.contentOffset.x / kScreenWidth
            let offsetIndex: Int = Int(offset)
            if offset != CGFloat(offsetIndex) {
                self.isClick = false
            }
            if self.isClick == false {
                if offset == CGFloat(offsetIndex)  {
                    let titleBtn: UIButton = self.titleBtnArr[offsetIndex]
                    self.titleBtnClicked(btn: titleBtn)
                }
            }
        }
    }
}

extension MZAddressSelectedView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return self.provinceArr.count
        } else if tableView.tag == 1 {
            return self.cityArr.count
        } else if tableView.tag == 2 {
            return self.countyArr.count
        } else if tableView.tag == 3 {
            return self.regionArr.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addressCellIdentifier = "addressCellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style:.default, reuseIdentifier: addressCellIdentifier)
        }
        var model = MZAddressModel()
        if tableView.tag == 0 {
            model = self.provinceArr[indexPath.row]
        } else if tableView.tag == 1 {
            model = self.cityArr[indexPath.row]
        } else if tableView.tag == 2 {
            model = self.countyArr[indexPath.row]
        } else if tableView.tag == 3 {
            model = self.regionArr[indexPath.row]
        }
        cell?.textLabel?.text = model.name ?? ""
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.textLabel?.textColor = UIColor.black
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var model = MZAddressModel()
        if tableView.tag == 0 {
            model = self.provinceArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name ?? "请选择"
            // 修改选中的index
            if self.selectedIdArr.count > 0 {
                self.selectedIdArr[tableView.tag] = model.code!
            } else {
                self.selectedIdArr.append(model.code!)
            }
            if self.titleBtnArr.count == 1 {
                self.titleArr.append("请选择")
            }
            // 网络请求获取市
            self.getAreaData(tag: tableView.tag + 1, code: model.code!)
        } else if tableView.tag == 1 {
            model = self.cityArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name ?? "请选择"
            // 修改选中的index
            if self.selectedIdArr.count > 1 {
                self.selectedIdArr[tableView.tag] = model.code!
            } else {
                self.selectedIdArr.append(model.code!)
            }
            if self.titleBtnArr.count == 2 {
                self.titleArr.append("请选择")
            }
            // 网络请求获取区/县
            self.getAreaData(tag: tableView.tag + 1, code: model.code!)
        } else if tableView.tag == 2 {
            model = self.countyArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name ?? "请选择"
            // 修改选中的index
            if self.selectedIdArr.count > 2 {
                self.selectedIdArr[tableView.tag] = model.code!
            } else {
                self.selectedIdArr.append(model.code!)
            }
            if self.titleBtnArr.count == 3 {
                self.titleArr.append("请选择")
            }
            // 网络请求获取街道/乡镇
            self.getAreaData(tag: tableView.tag + 1, code: model.code!)
        } else if tableView.tag == 3 {
            model = self.regionArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name ?? "请选择"
            // 修改选中的index
            if self.selectedIdArr.count > 3 {
                self.selectedIdArr[tableView.tag] = model.code!
            } else {
                self.selectedIdArr.append(model.code!)
            }
            self.setupAllTitle(index: 3)
            self.dismiss()
            // 取数据
            let value = self.titleArr[0] + " " + self.titleArr[1] + " " + self.titleArr[2] + " " + self.titleArr[3]
            self.callBackBlock(value, self.selectedIdArr)
        }
    }
}

extension MZAddressSelectedView {
    /// 本地获取省市县街道
    fileprivate func getAreaData(tag: Int, code: String = "") {
        switch tag {
        case 0:
            // 获取省
            self.provinceArr.removeAll()
            for i in 1 ..< 21 {
                let dict = ["code":"\(1000 * i)", "name":"第\(i)省"]
                let model = MZAddressModel.mj_object(withKeyValues: dict)
                self.provinceArr.append(model!)
            }
            self.tableViewArr[0].reloadData()
        case 1:
            // 获取市
            self.cityArr.removeAll()
            for i in 1 ..< 16 {
                let dict = ["code":code + "\(i + 1)", "name":"第" + code + "\(i + 1)" + "市"]
                let model = MZAddressModel.mj_object(withKeyValues: dict)
                self.cityArr.append(model!)
            }
            self.setupAllTitle(index: 1)
            self.tableViewArr[1].reloadData()
        case 2:
            // 获取区/县
            self.countyArr.removeAll()
            for i in 1 ..< 20 {
                let dict = ["code":code + "\(i + 1)", "name":"第" + code + "\(i + 1)" + "县"]
                let model = MZAddressModel.mj_object(withKeyValues: dict)
                self.countyArr.append(model!)
            }
            self.setupAllTitle(index: 2)
            self.tableViewArr[2].reloadData()
        case 3:
            // 获取街道/乡镇
            self.regionArr.removeAll()
            for i in 1 ..< 9 {
                let dict = ["code":code + "\(i + 1)", "name":"第" + code + "\(i + 1)" + "镇"]
                let model = MZAddressModel.mj_object(withKeyValues: dict)
                self.regionArr.append(model!)
            }
            self.setupAllTitle(index: 3)
            self.tableViewArr[3].reloadData()
        default:
            break
        }
    }
    /*
    /// 网络获取省市县街道
    fileprivate func getAreaData(tag: Int, code: String = "") {
        switch tag {
        case 0:
            // 获取省
            self.provinceArr.removeAll()
            WPHomeVM.shareManager.queryAreaList(dic: [:]) { (data) in
                for dic in data {
                    let model = MZAddressModel.mj_object(withKeyValues: dic)
                    self.provinceArr.append(model!)
                }
                self.tableViewArr[0].reloadData()
            }
        case 1:
            // 获取市
            self.cityArr.removeAll()
            WPHomeVM.shareManager.getArea(dic: ["pid":code]) { (data) in
                for dic in data {
                    let model = MZAddressModel.mj_object(withKeyValues: dic)
                    self.cityArr.append(model!)
                }
                self.tableViewArr[1].reloadData()
            }
            self.setupAllTitle(index: 1)
        case 2:
            // 获取区/县
            self.countyArr.removeAll()
            WPHomeVM.shareManager.getArea(dic: ["pid":code]) { (data) in
                for dic in data {
                    let model = MZAddressModel.mj_object(withKeyValues: dic)
                    self.countyArr.append(model!)
                }
                self.tableViewArr[2].reloadData()
            }
            self.setupAllTitle(index: 2)
        case 3:
            // 获取街道/乡镇
            self.regionArr.removeAll()
            WPHomeVM.shareManager.getArea(dic: ["pid":code]) { (data) in
                for dic in data {
                    let model = MZAddressModel.mj_object(withKeyValues: dic)
                    self.regionArr.append(model!)
                }
                self.tableViewArr[3].reloadData()
            }
            self.setupAllTitle(index: 3)
        default:
            break
        }
    }
     */
}

