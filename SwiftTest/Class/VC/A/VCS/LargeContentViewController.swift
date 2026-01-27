//
//  LargeContentViewController.swift
//  SwiftTest
//
//  Created by yyw on 2026/1/20.
//

import UIKit

class LargeContentViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLargeContentButtons()
    }
    
    private func setupLargeContentButtons() {
        createToolbarButton(systemName: "folder", title: "文件夹", frame: CGRectMake(220 - 50, 200, 100, 50))
        createToolbarButton(systemName: "paperplane", title: "发送", frame: CGRectMake(220 - 50, 260, 100, 50))
        createToolbarButton(systemName: "trash", title: "删除", frame: CGRectMake(220 - 50, 320, 100, 50))
        createToolbarButton(systemName: "star", title: "收藏", frame: CGRectMake(220 - 50, 380, 100, 50))
    }
    
    @discardableResult
    private func createToolbarButton(systemName: String, title: String, frame: CGRect) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName), for: .normal)
        button.frame = frame
        
        // 配置大内容查看器
        if #available(iOS 13.0, *) {
            button.showsLargeContentViewer = true
            button.largeContentTitle = title
            button.largeContentImage = UIImage(systemName: systemName)?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 48))
            button.scalesLargeContentImage = true
        }
        
        addHapticFeedback(to: button)

        view.addSubview(button)
        return button
    }
    
//    @available(iOS 13.0, *)
//    private func configureLargeContentViewer(for toolbar: UIToolbar) {
//        // 为工具栏中的每个自定义视图配置
//        toolbar.subviews.forEach { subview in
//            if let button = subview as? UIButton {
//                button.showsLargeContentViewer = true
//                
//                // 添加弹性动画反馈（结合你之前的知识）
//                addHapticFeedback(to: button)
//            }
//        }
//    }
//    
    private func addHapticFeedback(to button: UIButton) {
        button.addTarget(self, action: #selector(handleButtonPress(_:)), for: [.touchDown])
    }
    
    @objc private func handleButtonPress(_ sender: UIButton) {
        // 触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // 弹性动画
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }
}
