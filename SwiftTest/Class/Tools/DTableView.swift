//
//  DTableView.swift
//  SwiftTest
//
//  Created by yyw on 2025/1/3.
//

import UIKit

extension UIView {
    func snapshotImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}

public extension UIEdgeInsets {
    var vertical: CGFloat {
        return top + bottom
    }
    var horizontal: CGFloat {
        return left + right
    }
}


class DTableView: UITableView {

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
        
    func insertSectionAndKeepOffset(_ indexSet: IndexSet) {
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
        self.performBatchUpdates({
            self.insertSections(indexSet, with: .none)
        }) { success in
            animationView.removeFromSuperview()
        }
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
        
    public func scrollToLastItem(at pos: UITableView.ScrollPosition = .top, animated: Bool, completion:(()->())? = nil) {
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
            self.scrollToRow(at: indexPath, at: pos, animated: false)
        }
    }
    
    func setContentOffsetOfBottom(animated: Bool) {
        if (self.bounds.size.height - self.contentInset.horizontal) < self.contentSize.height {
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
            self.setContentOffset(bottomOffset, animated: animated)
        }
        else {
            self.scrollToLastItem(animated: animated)
        }
    }
}
