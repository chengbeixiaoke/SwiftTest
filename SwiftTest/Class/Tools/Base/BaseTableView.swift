//
//  BaseTableView.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/3.
//

import UIKit

open class BaseTableView: UITableView {
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame == .zero ? CGRectMake(0, 0, WidthScreen, HeightScreen) : frame, style: style)
        
        separatorStyle = .none
        backgroundColor = UIColor.C_Clear
        tableHeaderView = UIView(frame: CGRectMake(0, 0, WidthScreen, CGFLOAT_MIN))
        tableFooterView = UIView(frame: CGRectMake(0, 0, WidthScreen, CGFLOAT_MIN))
        contentInset = .zero
        scrollIndicatorInsets = .zero
        
        estimatedRowHeight = 0
        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0
        sectionHeaderHeight = CGFLOAT_MIN
        sectionFooterHeight = CGFLOAT_MIN
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        contentInsetAdjustmentBehavior = .never
        
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
        
        if #available(iOS 26.0, *) {
            topEdgeEffect.isHidden = true
            bottomEdgeEffect.isHidden = true
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func reloadDataAndKeepOffset() {
        setContentOffset(contentOffset, animated: false)
        
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
        
    open func insertSectionAndKeepOffset(_ indexSet: IndexSet) {
        setContentOffset(contentOffset, animated: false)
        
        var animationView: UIView
        if let snapshotView = superview?.resizableSnapshotView(from: superview?.frame ?? .zero, afterScreenUpdates: true, withCapInsets: .zero) {
            snapshotView.frame = superview?.bounds ?? .zero
            animationView = snapshotView
        }
        else {
            let imageView = UIImageView(frame: superview?.bounds ?? .zero)
            let image = superview?.snapshotImage()
            imageView.image = image
            animationView = imageView
        }
        
        superview?.addSubview(animationView)
        let beforeContentSize = contentSize
        performBatchUpdates {
            self.insertSections(indexSet, with: .none)
        } completion: { success in
            animationView.removeFromSuperview()
        }
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
        
    open func scrollToLastItem(at pos: UITableView.ScrollPosition = .top, animated: Bool, completion:(()->())? = nil) {
        guard numberOfSections > 0 else { return }
        let lastSection = numberOfSections - 1
        
        let lastItemIndex = numberOfRows(inSection: lastSection) - 1
        guard lastItemIndex >= 0 else { return }
        
        let indexPath = IndexPath(row: lastItemIndex, section: lastSection)

        if animated {
            UIView.animate(withDuration: 0.25) {
                self.scrollToRow(at: indexPath, at: pos, animated: false)
            }
        } else {
            scrollToRow(at: indexPath, at: pos, animated: false)
        }
    }
    
    open func setContentOffsetOfBottom(animated: Bool) {
        if (bounds.size.height - contentInset.horizontal) < contentSize.height {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
            setContentOffset(bottomOffset, animated: animated)
        }
        else {
            scrollToLastItem(animated: animated)
        }
    }
}
