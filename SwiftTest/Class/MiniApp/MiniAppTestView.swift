//
//  MiniAppTestView.swift
//  SwiftTest
//
//  Created by yyw on 2025/6/19.
//

import UIKit
import YYKit

class MiniAppTestView: UIView, UIScrollViewDelegate {
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.contentInset = .zero
        return sv
    }()
    
    // 透视度
    let m34 = -1.0 / 600.0
    
    let scroll_subview_top = UIScale(70)
    let scroll_subview_left = UIScale(15)
    
    var scroll_subview_width: CGFloat {
        return WidthScreen - scroll_subview_left * 2
    }
    
    // scrollview 的 subView 显示的高度
    var scroll_subview_height: CGFloat {
        switch scrollViewSubviews.count {
        case 1:
            return HeightScreen
        case 2:
            return (HeightScreen - scroll_subview_top) / 2.0
        case 3:
            return (HeightScreen - scroll_subview_top) / 3.0
        case 4:
            return UIScale(200)
        default:
            return UIScale(170)
        }
    }
    
    // 最后一个view显示的高度
    var scroll_subview_height_last: CGFloat {
        switch scrollViewSubviews.count {
        case 1:
            return HeightScreen
        case 2:
            return (HeightScreen - scroll_subview_top) / 2.0
        case 3:
            return UIScale(400)
        case 4:
            return UIScale(400)
        default:
            return UIScale(400)
        }
    }
    
    // scroll contentSize height
    var scroll_content_size: CGSize {
        switch scrollViewSubviews.count {
        case 1:
            return CGSize(width: WidthScreen, height: HeightScreen)
        case 2:
            return CGSize(width: WidthScreen, height: HeightScreen)
        default:
            return CGSize(width: WidthScreen, height: scroll_subview_top + CGFloat(scrollViewSubviews.count - 1) * scroll_subview_height + scroll_subview_height_last)
        }
    }
    
    var scrollViewSubviews: [MiniAppItemView] = []
    
    let total: Int
    
    init(frame: CGRect, count: Int) {
        self.total = 10
        super.init(frame: frame)
        setupUI()
        let tap = UITapGestureRecognizer { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.hide()
        }
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 旋转度
    func angle(_ view: UIView) -> CGFloat {
        
        if scrollViewSubviews.count == 1 { return -.pi * 0.08 }
        
        if scrollViewSubviews.count == 2 {
            if scrollViewSubviews[0] == view {
                return -.pi * 0.12
            }
            if scrollViewSubviews[1] == view {
                return -.pi * 0.16
            }
        }
        
        if scrollViewSubviews.count == 3 {
            if scrollViewSubviews[0] == view {
                return -.pi * 0.12
            }
            if scrollViewSubviews[1] == view {
                return -.pi * 0.13
            }
            if scrollViewSubviews[2] == view {
                return -.pi * 0.18
            }
        }
        
        let angle = .pi * 0.1
        let max_angle = .pi * 0.25
        let view_minY = scrollView.convert(view.frame, to: self).minY
        let new_angle = max(0, view_minY / HeightScreen) * (max_angle - angle) + angle
        return -new_angle
    }
    
    func setupUI() {
        let blurEffect = UIBlurEffect(style: .systemMaterialLight) // 有多种样式可选
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        addSubview(blurView)
        
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.frame = bounds
        
        for _ in 0..<total {
            let view = MiniAppItemView(frame: .zero)
            scrollView.addSubview(view)
            scrollViewSubviews.append(view)
            
            let tap = UITapGestureRecognizer { [weak self] sender in
                guard let weakSelf = self else { return }
                guard let sender = sender as? UITapGestureRecognizer, let view = sender.view as? MiniAppItemView else { return }
                view.removeFromSuperview()
                weakSelf.scrollViewSubviews.removeAll(view)
                weakSelf.refreshingScrollViewLayout()
            }
            view.addGestureRecognizer(tap)
        }
        
        scrollView.contentSize = scroll_content_size
        scrollView.scrollRectToVisible(CGRect(x: 0, y: scrollView.contentSize.height - 1, width: WidthScreen, height: 1), animated: false)
        
        for (i, view) in scrollViewSubviews.enumerated() {
            let height = (WidthScreen - scroll_subview_top) / WidthScreen * HeightScreen
            if i == scrollViewSubviews.count - 1 {
                view.frame = CGRectMake(0, scrollView.contentSize.height, WidthScreen, HeightScreen)
            }
            else {
                view.frame = CGRectMake(UIScale(15), scrollView.contentSize.height, WidthScreen - UIScale(30), height)
                view.showGrayView()
            }
        }
        updateScrollViewLayout()
    }
    
    func updateScrollViewLayout() {
        let count = scrollViewSubviews.count
        UIView.animateKeyframes(withDuration: 5, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                for (index, view) in self.scrollViewSubviews.enumerated() {
                    let top = self.scrollView.contentSize.height - CGFloat(count  - index) * UIScale(100)
                    view.frame = CGRectMake(view.frame.minX,
                                            top,
                                            view.bounds.width,
                                            view.bounds.height)
                    view.grayView.alpha = 0.3
                }
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                for (index, view) in self.scrollViewSubviews.enumerated() {
                    let top = self.scroll_subview_top + CGFloat(index) * self.scroll_subview_height
                    if index == count - 1 {
                        let height = (WidthScreen - self.scroll_subview_top) / WidthScreen * HeightScreen
                        view.frame = CGRectMake(self.scroll_subview_left,
                                                top,
                                                self.scroll_subview_width,
                                                height
                        )
                    }
                    else {
                        view.frame = CGRectMake(self.scroll_subview_left,
                                                top,
                                                self.scroll_subview_width,
                                                view.bounds.height)
                    }
                    
                    var transform = CATransform3DIdentity
                    transform.m34 = self.m34
                    transform = CATransform3DRotate(transform, self.angle(view), 1, 0, 0)
                    view.layer.transform = transform
                    
                    view.grayView.alpha = 0.0
                }
            }
        }
    }
    
    func refreshingScrollViewLayout(_ animation: Bool = true) {
        switch scrollViewSubviews.count {
        case 1:
            refreshingScrollViewLayout_1(animation)
            
        case 2:
            refreshingScrollViewLayout_2(animation)
            
        case 3:
            refreshingScrollViewLayout_3(animation)
            
        default:
            refreshingScrollViewLayout_default(animation)
        }
    }
    
    func refreshingScrollViewLayout_1(_ animation: Bool = true) {
        
    }
    
    func refreshingScrollViewLayout_2(_ animation: Bool = true) {
        
    }
    
    func refreshingScrollViewLayout_3(_ animation: Bool = true) {
        
    }
    
    func refreshingScrollViewLayout_default(_ animation: Bool = true) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for view in scrollViewSubviews {
            var transform = CATransform3DIdentity
            transform.m34 = m34
            transform = CATransform3DRotate(transform, angle(view), 1, 0, 0)
            view.layer.transform = transform
        }
    }
    
    
    func show() {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        window.addSubview(self)
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0.0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}

class MiniAppItemView: UIView {
    lazy var grayView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        view.alpha = 0.7
        return view
    }()
    
    lazy var imageView = {
        let view = UIImageView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.frame = bounds
        imageView.image = UIImage(named: "miniapp_image")
        
        imageView.setGradientBackground(colors: [.gray, .clear],
                                        locations: [0, 1],
                                        startPoint: CGPoint(x: 0.5, y: 1.0),
                                        endPoint: CGPoint(x: 0.5, y: 0.0),
                                        size: CGSize(width: WidthScreen * 2, height: HeightScreen * 2))
        
        layer.allowsEdgeAntialiasing = true
        layer.setAnchorPoint(CGPoint(x: 0.5, y: 0))
        
        imageView.layer.cornerRadius = UIScale(18)
        imageView.layer.cornerCurve =  .continuous
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.layer.masksToBounds = true
    }
    
    override var frame: CGRect {
        didSet {
            imageView.frame = bounds
        }
    }
    
    func showGrayView() {
        imageView.addSubview(grayView)
        grayView.frame = imageView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
