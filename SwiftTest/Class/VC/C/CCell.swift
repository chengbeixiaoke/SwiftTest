//
//  CCell.swift
//  SwiftTest
//
//  Created by yyw on 2024/12/31.
//

import UIKit
import SnapKit

class CCell: UITableViewCell {
    
    let idLabel = UILabel(frame: .zero)
    let nameLabel = UILabel(frame: .zero)
    let timeLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setUpContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpContentView() {
        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(self.idLabel)
        self.idLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(5)
        }
        self.idLabel.textColor = .red
        self.idLabel.font = UIFont.systemFont(ofSize: 10)
        
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        self.nameLabel.textColor = .blue
        self.nameLabel.font = UIFont.systemFont(ofSize: 15)
        
        self.contentView.addSubview(self.timeLabel)
        self.timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        self.timeLabel.textColor = .lightGray
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
    }
        
    func updateContent(_ model: UserModel) {
        
        self.idLabel.text = model.id
        self.nameLabel.text = model.name
        self.timeLabel.text = ChatIMDateFormatter.shared.dateString(from: model.createTime)
        
        let d = (Int(model.id) ?? 0) % 3
        self.contentView.backgroundColor = d == 0 ? .orange : (d == 1 ? .yellow : (d == 1 ? .yellow : .green))
    }
}
