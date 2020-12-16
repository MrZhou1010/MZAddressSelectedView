//
//  MZAddressSelectedView.swift
//  MZAddressSelectedView
//
//  Created by Mr.Z on 2019/11/8.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit
import MJExtension

/// 屏幕尺寸
fileprivate let kScreenSize: CGSize = UIScreen.main.bounds.size
/// 屏幕宽度
fileprivate let kScreenWidth: CGFloat = UIScreen.main.bounds.size.width
/// 屏幕高度
fileprivate let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height
/// 适配比例
fileprivate let kRectScale: CGFloat = (kScreenWidth / 375.0)
/// 主题色
fileprivate let kThemeColor: UIColor = UIColor.red

extension UIView {
    
    /// 设置某几个角的圆角
    public func setCorner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 设置渐变颜色
    public func setGradientColor(colors: [Any], startPoint: CGPoint, endPoint: CGPoint) {
        if let layers = self.layer.sublayers {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        // 设置渐变的主颜色(可多个颜色添加)
        gradientLayer.colors = colors
        // startPoint与endPoint分别为渐变的起始方向与结束方向,它是以矩形的四个角为基础的
        // (0,0)为左上角、(1,0)为右上角、(0,1)为左下角、(1,1)为右下角,默认是值是(0.5,0)和(0.5,1)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        // 将gradientLayer作为子layer添加到主layer上
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

class MZAddressSelectedView: UIView {
    
    /// 传递的数据
    public var callBackBlock: (_ modelArr: [MZAddressModel]) -> () = { (modelArr) in }
    
    /// 设置标题
    public var title: String = "" {
        didSet {
            self.titleLab.text = self.title
        }
    }
    
    /// 设置是否线条渐变
    public var isGradientLine: Bool = false
    
    /// 省
    private var provinceArr = [MZAddressModel]()
    /// 市
    private var cityArr = [MZAddressModel]()
    /// 区/县
    private var countyArr = [MZAddressModel]()
    /// 街道/乡镇
    private var regionArr = [MZAddressModel]()
    /// 标题数组
    private var titleArr = ["请选择"]
    /// 选择的数据数组
    private var selectedDataArr = [MZAddressModel]()
    /// 按钮数组
    private var titleBtnArr = [UIButton]()
    /// 数据列表数组
    private var tableViewArr = [UITableView]()
    /// 判断是滚动还是点击
    private var isClick: Bool = false
    
    // MARK: - Lazy
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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.02)
        return view
    }()
    
    private lazy var titleScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 50 * kRectScale, width: kScreenWidth, height: 30 * kRectScale))
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var lineView: UIView = {
        let lineView = UIView(frame: .zero)
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
    
    // MARK: - 初始化和UI
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
            let titleLenth: CGFloat = self.stringForWidth(text: title, fontSize: 13, height: 30 * kRectScale)
            let titleBtn: UIButton = UIButton(type: .custom)
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
    
    // MARK: - Fuction
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
        if self.isGradientLine {
            self.lineView.backgroundColor = UIColor.clear
            self.lineView.setGradientColor(colors: [kThemeColor.cgColor, kThemeColor.withAlphaComponent(0.2).cgColor], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5))
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
    
    private func stringForWidth(text: String, fontSize: CGFloat = 15.0, height: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: CGFloat(MAXFLOAT), height: height)
        let rect = NSString(string: text).boundingRect(with: size, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [.font: font], context: nil)
        return ceil(rect.width)
    }
}

extension MZAddressSelectedView: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
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
    // MARK: - UITableViewDelegate, UITableViewDataSource
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
        cell?.textLabel?.text = model.name
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
            self.titleArr[tableView.tag] = model.name == "" ? "请选择" : model.name
            // 修改选中的index
            if self.selectedDataArr.count > 0 {
                self.selectedDataArr[tableView.tag] = model
            } else {
                self.selectedDataArr.append(model)
            }
            if self.titleBtnArr.count == 1 {
                self.titleArr.append("请选择")
            }
            // 网络请求获取市
            self.getAreaData(tag: tableView.tag + 1, code: model.code)
        } else if tableView.tag == 1 {
            model = self.cityArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name == "" ? "请选择" : model.name
            // 修改选中的index
            if self.selectedDataArr.count > 1 {
                self.selectedDataArr[tableView.tag] = model
            } else {
                self.selectedDataArr.append(model)
            }
            if self.titleBtnArr.count == 2 {
                self.titleArr.append("请选择")
            }
            // 网络请求获取区/县
            self.getAreaData(tag: tableView.tag + 1, code: model.code)
        } else if tableView.tag == 2 {
            model = self.countyArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name == "" ? "请选择" : model.name
            // 修改选中的index
            if self.selectedDataArr.count > 2 {
                self.selectedDataArr[tableView.tag] = model
            } else {
                self.selectedDataArr.append(model)
            }
            if self.titleBtnArr.count == 3 {
                self.titleArr.append("请选择")
            }
            // 网络请求获取街道/乡镇
            self.getAreaData(tag: tableView.tag + 1, code: model.code)
        } else if tableView.tag == 3 {
            model = self.regionArr[indexPath.row]
            // 修改标题
            self.titleArr[tableView.tag] = model.name == "" ? "请选择" : model.name
            // 修改选中的index
            if self.selectedDataArr.count > 3 {
                self.selectedDataArr[tableView.tag] = model
            } else {
                self.selectedDataArr.append(model)
            }
            self.setupAllTitle(index: 3)
            self.dismiss()
            // 取数据
            self.callBackBlock(self.selectedDataArr)
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
            WPHomeVM.shareManager.getArea(dic: ["pid": code]) { (data) in
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
            WPHomeVM.shareManager.getArea(dic: ["pid": code]) { (data) in
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
            WPHomeVM.shareManager.getArea(dic: ["pid": code]) { (data) in
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
