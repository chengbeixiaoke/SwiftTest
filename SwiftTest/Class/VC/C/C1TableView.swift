//
//  C1TableView.swift
//  SwiftTest
//
//  Created by yyw on 2025/3/26.
//

import UIKit

class C1TableView: UITableView {
    var needUpdateContentOffset = false
    var isMessageLongPress = false
    public func reloadDataAndKeepOffset() {
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
        
    func insertSectionAndKeepOffset(_ indexSet: IndexSet,
                                    completion: @escaping (CGPoint)->()) {
        setContentOffset(contentOffset, animated: false)
        
        var animationView: UIView
        if let snapshotView = self.superview?.resizableSnapshotView(from: self.superview?.frame ?? .zero, afterScreenUpdates: true, withCapInsets: .zero) {
            snapshotView.frame = self.superview?.bounds ?? .zero
            animationView = snapshotView
        }
        else {
            let imageView = UIImageView(frame: self.superview?.bounds ?? .zero)
            let image = self.superview?.snapshotImage()
            imageView.image = image
            animationView = imageView
        }
        
        self.superview?.addSubview(animationView)
        let beforeContentSize = contentSize
        self.performBatchUpdates({ [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.insertSections(indexSet, with: .none)
        })
        { success in
            animationView.removeFromSuperview()
            print("插入数据完成")
            
            self.layoutIfNeeded()
            let afterContentSize = self.contentSize
            
            let newOffset = CGPoint(
                x: self.contentOffset.x + (afterContentSize.width - beforeContentSize.width),
                y: self.contentOffset.y + (afterContentSize.height - beforeContentSize.height))
            print("[Test] contentOffset.y:\(self.contentOffset.y), afterContentSize:\(afterContentSize), beforeContentSize:\(beforeContentSize), newOffset:\(newOffset)")
            self.setContentOffset(newOffset, animated: false)
            completion(newOffset)
        }
    }
        
    public func scrollToLastItem(at pos: UITableView.ScrollPosition = .top,
                                 animated: Bool,
                                 completion: @escaping ()->()) {
        if isMessageLongPress {
            return
        }
        
        guard numberOfSections > 0 else { return }
        let lastSection = numberOfSections - 1
        
        let lastItemIndex = numberOfRows(inSection: lastSection) - 1
        guard lastItemIndex >= 0 else { return }
        
        let indexPath = IndexPath(row: lastItemIndex, section: lastSection)

        if animated {
            UIView.animate(withDuration: 0.25) {
                self.scrollToRow(at: indexPath, at: pos, animated: false)
            } completion: {_ in
                completion()
            }
        } else {
            self.scrollToRow(at: indexPath, at: pos, animated: false)
            completion()
        }
    }
    
    func setContentOffsetOfBottom(animated: Bool) {
        if (self.bounds.size.height - self.contentInset.horizontal) < self.contentSize.height && needUpdateContentOffset {
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
            self.setContentOffset(bottomOffset, animated: animated)
        }
        else {
            self.scrollToLastItem(animated: animated) {}
        }
    }
    
    deinit {
        print("[Test] C1TableView deinit")
    }
}
