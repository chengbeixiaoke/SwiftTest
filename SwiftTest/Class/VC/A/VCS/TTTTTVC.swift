//
//  TTTTTVC.swift
//  SwiftTest
//
//  Created by yyw on 2026/2/2.
//

import UIKit

class TTTTTVC: BaseViewController {
    let customMenuView2 = UIView(frame: CGRectMake(50, 250, 200, 200))
    
    var blurView: TranslucentBlurView_IM?

    lazy var tableView =  {
        let tableView = BaseTableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = viewBackgroundColor
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ACell.self,
                           forCellReuseIdentifier: "ACell")
        
        tableView.register(A2Cell.self,
                           forCellReuseIdentifier: "A2Cell")
        
        return tableView
    }()
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "XXX"
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 26.0, *) {
            tableView.topEdgeEffect.isHidden = true
            tableView.bottomEdgeEffect.isHidden = true
        }
    }
    
    func setupBlurView() {
        blurView?.removeFromSuperview()
        let blurView = TranslucentBlurView_IM(frame: CGRectMake(0, 0, WidthScreen, 109))
        view.addSubview(blurView)
        self.blurView = blurView
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupBlurView()
        }
    }
}

extension TTTTTVC: UITableViewDelegate, UITableViewDataSource {
    class ACell: BaseTableViewCell {
        let xx_imageView = UIImageView(frame: .zero)

        override func setupUI() {
            super.setupUI()
            
            xx_imageView.contentMode = .scaleToFill
            xx_imageView.image = UIImage(named: "test001")
            contentView.addSubview(xx_imageView)
            xx_imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HeightScreen
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ACell", for: indexPath) as! ACell
        cell.xx_imageView.image = UIImage(named: "app_bg_4")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return BaseView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return BaseView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
