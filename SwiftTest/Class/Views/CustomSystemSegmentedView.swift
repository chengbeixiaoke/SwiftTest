//
//  CustomSegmentedView.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/29.
//

import UIKit
import SnapKit

open class CustomSystemSegmentedView: UISegmentedControl {
    public private(set) var contentView: UIView?
    
    public var selectedIndex: Int = 0 {
        didSet {
            selectedSegmentIndex = selectedIndex
        }
    }
    
    public var normalConfig: [NSAttributedString.Key : Any]? {
        didSet {
            setTitleTextAttributes(normalConfig, for: .normal)
        }
    }
    
    public var selectedConfig: [NSAttributedString.Key : Any]? {
        didSet {
            setTitleTextAttributes(selectedConfig, for: .selected)
        }
    }
    
    public var selectedColor: UIColor? {
        didSet {
            selectedSegmentTintColor = selectedColor
        }
    }
    
    private var titles: [String] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()
    {
        selectedColor = UIColor.ColorFromHex("000000", 0.07, darkHex: "FFFFFF", darkAlpha: 0.1)
        normalConfig = [.foregroundColor: UIColor.Text_727386, .font : UIFont.systemFont(ofSize: 16)]
        selectedConfig = [.foregroundColor: UIColor.ColorBlack, .font: UIFont.systemFont(ofSize: 16)]
        selectedIndex = 0
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        subviews.forEach { view in
            if view is UIImageView {
                view.isHidden = true
            }
        }
    }
    
    public func updateUI(titles: [String])
    {
        self.titles = titles
        removeAllSegments()
        
        titles.reversed().forEach { title in
            insertSegment(withTitle: title, at: 0, animated: true)
        }
        
        subviews.forEach { view in
            if view is UIImageView {
                view.isHidden = true
                contentView = view.superview
            }
        }
        
        selectedSegmentIndex = selectedIndex
    }
}
