//
//  SavoPresentSwipeInteractionController.swift
//  CashSAVO
//
//  Created by yyw on 2025/4/29.
//

import UIKit

class SavoSlideDownInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    private let edgeTriggerWidth: CGFloat = 50.0
    
    func wireToViewController(_ viewController: UIViewController) {
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }
    
    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view?.superview)
        
        switch gestureRecognizer.state {
        case .began:
            // 检查是否从右侧边缘开始滑动
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            interactionInProgress = location.x <= edgeTriggerWidth
            
        case .changed:
            guard interactionInProgress else { return }
            
            let combinedPercent = translation.x / WidthScreen
            updateViewForInteractiveTransition(combinedPercent: combinedPercent)
            
            update(combinedPercent)
            shouldCompleteTransition = combinedPercent > 0.5
            
        case .cancelled, .ended:
            guard interactionInProgress else { return }
            interactionInProgress = false
            
            if gestureRecognizer.state == .cancelled || !shouldCompleteTransition {
                cancel()
                // 恢复视图位置
                UIView.animate(withDuration: 0.3) {
                    self.viewController?.view.transform = .identity
                }
            } else {
                finish()
                if let vc = viewController as? MiniAppH5ContainerViewController {
                    MiniAppManager.shared.downMiniApp(vc)
                }
                else {
                    viewController.dismiss(animated: true)
                }
            }
            
        default:
            break
        }
    }
    
    private func updateViewForInteractiveTransition(combinedPercent: CGFloat) {
        let verticalOffset = HeightScreen * combinedPercent
        let combinedTransform = CGAffineTransform(translationX: 0, y: verticalOffset)
        viewController?.view.transform = combinedTransform
    }
    
    
}

extension SavoSlideDownInteractiveTransition: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        
        let location = panGesture.location(in: panGesture.view)
        let velocity = panGesture.velocity(in: panGesture.view)
        
        // 1. 检查是否从右侧边缘开始
        let isFromEdge = location.x <= edgeTriggerWidth
        
        // 2. 检查是否是水平滑动（避免与垂直滚动手势冲突）
        let isHorizontalSwipe = abs(velocity.x) > abs(velocity.y)
        
        return isFromEdge && isHorizontalSwipe
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 允许与某些特定手势同时识别
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 确保我们的手势优先于导航控制器的返回手势
        if let navController = viewController?.navigationController,
           let popGesture = navController.interactivePopGestureRecognizer,
           otherGestureRecognizer == popGesture {
            return true
        }
        return false
    }
}

extension SavoSlideDownInteractiveTransition {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 当内容可以水平滚动且不在最左侧时，优先滚动内容而不是dismiss
        if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            if scrollView.contentOffset.x > 0 {
                return true
            }
        }
        return false
    }
}

class SavoSlideDownTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    let interactiveTransition = SavoSlideDownInteractiveTransition()
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition.interactionInProgress ? interactiveTransition : nil
    }
}
