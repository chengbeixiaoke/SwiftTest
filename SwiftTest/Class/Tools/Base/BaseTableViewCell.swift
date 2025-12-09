//
//  BaseTableViewCell.swift
//  SwiftTest
//
//  Created by yyw on 2025/9/30.
//

import UIKit

open class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        updateBackgroundColor(.C_White)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateBackgroundColor(_ color: UIColor) {
        backgroundColor = .C_Clear
        contentView.backgroundColor = color
    }
    
    public func setupUI() {
        
    }
}
