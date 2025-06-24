//
//  MiniAppTestView.swift
//  SwiftTest
//
//  Created by yyw on 2025/6/19.
//

import UIKit
import YYKit

class MiniAppTestView: UIView {
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = true
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.contentInset = .zero
        return sv
    }()
    
    var count: Int = 10
    
    var scrollViewSubviews: [MiniAppItemView] = []
    
    override init(frame: CGRect) {
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
    
    func setupUI() {
        let blurEffect = UIBlurEffect(style: .systemMaterialLight) // 有多种样式可选
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        addSubview(blurView)
        
        addSubview(scrollView)
        scrollView.frame = bounds
        
        if count == 2 {
            scrollView.contentSize = bounds.size
        }
        else if count == 3 {
            scrollView.contentSize = CGSizeMake(self.frame.width, self.frame.height + top)
        }
        else {
            scrollView.contentSize = CGSizeMake(self.frame.width, top + CGFloat(count - 1) * UIScale(200) + UIScale(500))
        }
        
        scrollView.scrollRectToVisible(CGRect(x: 0, y: scrollView.contentSize.height - 1, width: WidthScreen, height: 1), animated: false)
        
        for i in 0..<count {
            let height = (WidthScreen - UIScale(30)) / WidthScreen * HeightScreen
            let view = MiniAppItemView(frame: CGRectMake(UIScale(15), scrollView.contentSize.height, WidthScreen - UIScale(30), height))
            scrollView.addSubview(view)
            scrollViewSubviews.append(view)
            
            if i == count - 1 {
                view.frame = CGRectMake(0, scrollView.contentSize.height, WidthScreen, HeightScreen)
                view.imageView.frame = view.bounds
            }
            else {
                view.showGrayView()
            }
            
            let tap = UITapGestureRecognizer { [weak self] sender in
                guard let weakSelf = self else { return }
                guard let sender = sender as? UITapGestureRecognizer, let view = sender.view as? MiniAppItemView else { return }
                view.removeFromSuperview()
                weakSelf.scrollViewSubviews.removeAll(view)
                weakSelf.refreshingScrollViewLayout()
            }
            view.addGestureRecognizer(tap)
        }
        
        updateScrollViewLayout()
    }
    
    func updateScrollViewLayout() {
        let count = scrollViewSubviews.count
        let top = UIScale(100)
        let m34 = -1.0 / 600.0
        var angle = -.pi * 0.08
        
        if count == 2 {
            angle = -.pi * 0.1
        } else if count == 3 {
            angle = -.pi * 0.12
        }
        else {
            angle = -.pi * 0.15
        }
        
        UIView.animateKeyframes(withDuration: 10.0, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                for (index, view) in self.scrollViewSubviews.enumerated() {
                    view.frame = CGRectMake(view.frame.minX,
                                            (self.scrollView.contentSize.height - HeightScreen) + HeightScreen / 3.0 * 2.0 - CGFloat(count - index) * UIScale(50),
                                            view.frame.width,
                                            view.frame.height)
                    view.grayView.alpha = 0.0
                }
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                if count == 2 {
                    let view1 = self.scrollViewSubviews[0]
                    let view2 = self.scrollViewSubviews[1]
                    
                    view1.frame = CGRectMake(view1.frame.minX, top, view1.frame.width, view1.frame.height)
                    view2.frame = CGRectMake(view1.frame.minX, (HeightScreen + top) / 2.0, view1.bounds.width, view1.bounds.height)
                }
                else if count == 3 {
                    let view1 = self.scrollViewSubviews[0]
                    let view2 = self.scrollViewSubviews[1]
                    let view3 = self.scrollViewSubviews[2]
                    
                    view1.frame = CGRectMake(view1.frame.minX, top, view1.bounds.width, view1.bounds.height)
                    view2.frame = CGRectMake(view2.frame.minX, top + (self.scrollView.contentSize.height - top) / 3.0, view2.bounds.width, view2.bounds.height)
                    view3.frame = CGRectMake(view1.frame.minX, top + (self.scrollView.contentSize.height - top) / 3.0 * 2.0, view1.bounds.width, view1.bounds.height)
                }
                else {
                    let frame = self.scrollViewSubviews[0].frame
                    for (index, view) in self.scrollViewSubviews.enumerated() {
                        if index == self.scrollViewSubviews.count - 1 {
                            view.frame = CGRectMake(frame.minX, top + CGFloat(index) * UIScale(200), self.scrollViewSubviews.first!.bounds.width, self.scrollViewSubviews.first!.bounds.height)
                        }
                        else {
                            view.frame = CGRectMake(frame.minX, top + CGFloat(index) * UIScale(200), view.bounds.width, view.bounds.height)
                        }
                    }
                }
                
                for view in self.scrollViewSubviews {
                    view.imageView.frame = view.bounds
                    var transform = CATransform3DIdentity
                    transform.m34 = m34
                    transform = CATransform3DRotate(transform, angle, 1, 0, 0)
                    view.layer.transform = transform
                }
            }
        }
    }
    
    func refreshingScrollViewLayout(_ animation: Bool = true) {
//        switch scrollViewSubviews.count {
//        case 1:
//            refreshingScrollViewLayout_1(animation)
//            
//        case 2:
//            refreshingScrollViewLayout_2(animation)
//            
//        case 3:
//            refreshingScrollViewLayout_3(animation)
//            
//        default:
//            refreshingScrollViewLayout_default(animation)
//        }
    }
    
    func refreshingScrollViewLayout_1(_ animation: Bool = true) {
        guard let view = scrollViewSubviews.first else { return }
        
        UIView.animateKeyframes(withDuration: animation ? 0.25 : 0.0, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                var transform = CATransform3DIdentity
                transform.m34 = -1.0 / 500.0
                transform = CATransform3DRotate(transform, -.pi * 0.08, 1, 0, 0)
                view.layer.transform = transform
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                view.frame = CGRectMake(view.frame.minX, (HeightScreen - view.frame.height)/2.0, view.bounds.width, view.bounds.height)
            }
        }
        scrollView.contentSize = self.frame.size
    }
    
    func refreshingScrollViewLayout_2(_ animation: Bool = true) {
        guard let view1 = scrollViewSubviews.first else { return }
        guard let view2 = scrollViewSubviews.last else { return }
        
        let frame1 = view1.frame
        let frame2 = view2.frame
        
        let top = UIScale(100)
        
        UIView.animateKeyframes(withDuration: animation ? 0.25 : 0.0, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                var transform = CATransform3DIdentity
                transform.m34 = -1.0 / 500.0
                transform = CATransform3DRotate(transform, -.pi * 0.1, 1, 0, 0)
                
                view1.layer.transform = transform
                view2.layer.transform = transform
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                view1.frame = CGRectMake(frame1.minX, top, view1.bounds.width, view1.bounds.height)
                view2.frame = CGRectMake(frame2.minX, (HeightScreen + top) / 2.0, view2.bounds.width, view2.bounds.height)
            }
        }
        
        scrollView.contentSize = self.frame.size
    }
    
    func refreshingScrollViewLayout_3(_ animation: Bool = true) {
        let view1 = scrollViewSubviews[0]
        let view2 = scrollViewSubviews[1]
        let view3 = scrollViewSubviews[2]
        
        let frame1 = view1.frame
        let frame2 = view2.frame
        let frame3 = view3.frame
        
        let top = UIScale(100)
        
        UIView.animateKeyframes(withDuration: animation ? 0.25 : 0.0, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                var transform = CATransform3DIdentity
                transform.m34 = -1.0 / 500.0
                transform = CATransform3DRotate(transform, -.pi * 0.15, 1, 0, 0)
                
                view1.layer.transform = transform
                view2.layer.transform = transform
                view3.layer.transform = transform
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                view1.frame = CGRectMake(frame1.minX, top, view1.bounds.width, view1.bounds.height)
                view2.frame = CGRectMake(frame2.minX, top + (HeightScreen - top) / 3.0, view2.bounds.width, view2.bounds.height)
                view3.frame = CGRectMake(frame3.minX, top + (HeightScreen - top) / 3.0 * 2.0, view3.bounds.width, view3.bounds.height)
            }
        }
        scrollView.contentSize = CGSizeMake(self.frame.width, self.frame.height + top)
        scrollView.scrollToBottom()
    }
    
    func refreshingScrollViewLayout_default(_ animation: Bool = true) {
        let count = scrollViewSubviews.count
        let top = UIScale(100)
        let m34 = -1.0 / 500.0
        let angle = -.pi * 0.15
        self.scrollView.contentSize = CGSizeMake(self.frame.width, top + CGFloat(count - 1) * UIScale(200) + UIScale(400))
        
        UIView.animate(withDuration: 5.0) {
            let frame = self.scrollViewSubviews[0].frame
            for (index, view) in self.scrollViewSubviews.enumerated() {
                view.frame = CGRectMake(frame.minX, top + CGFloat(index) * UIScale(200), view.bounds.width, view.bounds.height)
            }
            
            for view in self.scrollViewSubviews {
                var transform = CATransform3DIdentity
                transform.m34 = m34
                transform = CATransform3DRotate(transform, angle, 1, 0, 0)
                view.layer.transform = transform
            }
        }
    }
    
    func layoutInfo(_ view: MiniAppItemView) -> (Float, Float, CGRect) {
        if scrollViewSubviews.count == 1 {
            return (-1.0 / 500.0,
                     -.pi * 0.08,
                     CGRectMake(view.frame.minX,
                                (HeightScreen - view.frame.height)/2.0,
                                view.bounds.width,
                                view.bounds.height))
        }
        else if scrollViewSubviews.count == 2 {
            if view == scrollViewSubviews[0] {
                return (-1.0 / 500.0,
                         -.pi * 0.08,
                         CGRectMake(view.frame.minX,
                                    top,
                                    view.frame.width,
                                    view.frame.height))
            }
            else {
                return (-1.0 / 500.0,
                         -.pi * 0.08,
                         CGRectMake(view.frame.minX,
                                    (HeightScreen + top) / 2.0,
                                    view.bounds.width,
                                    view.bounds.height))
            }
        }
        else if scrollViewSubviews.count == 3 {
            if view == scrollViewSubviews[0] {
                return (-1.0 / 500.0,
                         -.pi * 0.08,
                         CGRectMake(view.frame.minX,
                                    top,
                                    view.bounds.width,
                                    view.bounds.height))
            }
            else if view == scrollViewSubviews[1] {
                return (-1.0 / 500.0,
                         -.pi * 0.08,
                         CGRectMake(view.frame.minX,
                                    top + (scrollView.contentSize.height - top) / 3.0,
                                    view.bounds.width,
                                    view.bounds.height))
            }
            else {
                return (-1.0 / 500.0,
                         -.pi * 0.08,
                         CGRectMake(view.frame.minX,
                                    top + (self.scrollView.contentSize.height - top) / 3.0 * 2.0,
                                    view.bounds.width,
                                    view.bounds.height))
            }
        }
        else {
            
            
            
            let frame = self.scrollViewSubviews[0].bounds
            for (index, view) in self.scrollViewSubviews.enumerated() {
                if index == self.scrollViewSubviews.count - 1 {
                    return (-1.0 / 500.0,
                             -.pi * 0.08,
                             CGRectMake(frame.minX,
                                        top + CGFloat(index) * UIScale(200),
                                        view.bounds.width,
                                        view.bounds.height))
                }
                else {
                    return (-1.0 / 500.0,
                             -.pi * 0.08,
                             CGRectMake(frame.minX,
                                        top + CGFloat(index) * UIScale(200),
                                        view.bounds.width,
                                        view.bounds.height))
                }
            }
        }
        return (0, 0, .zero)
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
        
        setGradientBackground(colors: [.black, .clear],
                              locations: [0, 1],
                              startPoint: CGPoint(x: 0.5, y: 1.0),
                              endPoint: CGPoint(x: 0.5, y: 0.3),
                              size: frame.size)
        
        layer.allowsEdgeAntialiasing = true
        layer.setAnchorPoint(CGPoint(x: 0.5, y: 0))
        layer.cornerRadius = UIScale(18)
        layer.cornerCurve =  .continuous
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
    }
    
    func showGrayView() {
        addSubview(grayView)
        grayView.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
