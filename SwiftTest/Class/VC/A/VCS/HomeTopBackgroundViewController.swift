//
//  HomeTopBackgroundViewController.swift
//  SwiftTest
//
//  Created by yyw on 2025/12/22.
//

import UIKit

class HomeTopBackgroundViewController: BaseViewController {
    
    lazy var backgroundView = {
        return HomeTopBackgroundView(frame: CGRectMake(0, 103, WidthScreen, HeightScreen - 103))
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backgroundView.updateLevel(level: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .ColorWhite
        view.addSubview(backgroundView)
    }
}

class HomeTopBackgroundView: UIView {
    private let radius = WidthScreen * 0.8
    
    private var leftGradientView: HomeTopBackgroundGradientView?
    private var rightGradientView: HomeTopBackgroundGradientView?
    private var centerGradientView: HomeTopBackgroundGradientView?
    private var gradientLayer: CAGradientLayer?
    private var alphaView: UIView?
    private var blurView: UIVisualEffectView?

    private var displayLink: CADisplayLink?
    private var gradientColor: GradientColor!
    
    public func updateLevel(level: Int) {
        clipsToBounds = true

        displayLink?.invalidate()
        displayLink = nil
                
        leftGradientView?.removeFromSuperview()
        rightGradientView?.removeFromSuperview()
        centerGradientView?.removeFromSuperview()
        gradientLayer?.removeFromSuperlayer()
        alphaView?.removeFromSuperview()
        blurView?.removeFromSuperview()
        
        gradientColor = GradientColor.color(level: level)
        do {
            let position = CGPointMake(0, 0)
            let frame =  CGRectMake(-radius, 0, radius*2.0, radius*2.0)
            let leftGradientView = HomeTopBackgroundGradientView(frame: frame,
                                                     position: position,
                                                     velocity: randomVelocity(),
                                                     colors: [gradientColor.left_1, gradientColor.left_0])
            leftGradientView.center = position
            addSubview(leftGradientView)
            self.leftGradientView = leftGradientView
        }
        
        do {
            let position = CGPointMake(WidthScreen, 0)
            let frame = CGRectMake(WidthScreen - radius, 0, radius*2.0, radius*2.0)
            let rightGradientView = HomeTopBackgroundGradientView(frame: frame,
                                                     position: position,
                                                     velocity: randomVelocity(),
                                                     colors: [gradientColor.right_1, gradientColor.right_0])
            rightGradientView.center = position
            addSubview(rightGradientView)
            self.rightGradientView = rightGradientView
        }
        
        do {
            let position = CGPointMake(WidthScreen / 2.0, 0)
            let frame = CGRectMake(WidthScreen / 2.0, 0, radius*2.0, radius*2.0)
            let centerGradientView = HomeTopBackgroundGradientView(frame: frame,
                                                     position: position,
                                                     velocity: randomVelocity(),
                                                     colors: [gradientColor.center_1, gradientColor.center_0])
            centerGradientView.center = position
            addSubview(centerGradientView)
            self.centerGradientView = centerGradientView
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.ColorWhite, UIColor.ColorBG_FFFFFF_058_000000_058, UIColor.ColorBG_FFFFFF_0_000000_0].map { $0.cgColor }
        gradientLayer.locations = [0.0, 0.45, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        
        let alphaView = UIView(frame: bounds)
        alphaView.backgroundColor = UIColor.ColorWhite
        alphaView.alpha = 0.4
        addSubview(alphaView)
        self.alphaView = alphaView
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.alpha = 1.0
        addSubview(blurView)
        self.blurView = blurView
                
        startAnimation()
    }
    
    private func startAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateUI() {
        let viewWidth = bounds.size.width
        let x_max = viewWidth/2.0
        let y_max = viewWidth/4.0
        
        if let leftGradientView = leftGradientView {
            // 更新位置
            leftGradientView.position.x += leftGradientView.velocity.dx
            leftGradientView.position.y += leftGradientView.velocity.dy
            
            // 边界碰撞检测
            if leftGradientView.position.x >= x_max {
                leftGradientView.position.x = x_max
                leftGradientView.velocity.dx *= -1
            }
            
            if leftGradientView.position.x <= -x_max {
                leftGradientView.position.x = -x_max
                leftGradientView.velocity.dx *= -1
            }
            
            if leftGradientView.position.y >= y_max {
                leftGradientView.position.y = y_max
                leftGradientView.velocity.dy *= -1
            }
            
            if leftGradientView.position.y <= -y_max {
                leftGradientView.position.y = -y_max
                leftGradientView.velocity.dy *= -1
            }
            
            leftGradientView.center = leftGradientView.position
        }
        
        if let rightGradientView = rightGradientView {
            // 更新位置
            rightGradientView.position.x += rightGradientView.velocity.dx
            rightGradientView.position.y += rightGradientView.velocity.dy
            
            // 边界碰撞检测
            if rightGradientView.position.x >= frame.width + x_max {
                rightGradientView.position.x = frame.width + x_max
                rightGradientView.velocity.dx *= -1
            }
            
            if rightGradientView.position.x <= frame.width - x_max {
                rightGradientView.position.x = frame.width - x_max
                rightGradientView.velocity.dx *= -1
            }
            
            if rightGradientView.position.y >= y_max {
                rightGradientView.position.y = y_max
                rightGradientView.velocity.dy *= -1
            }
            
            if rightGradientView.position.y <= -y_max {
                rightGradientView.position.y = -y_max
                rightGradientView.velocity.dy *= -1
            }
            rightGradientView.center = rightGradientView.position
        }
        
        if let centerGradientView = centerGradientView {
            // 更新位置
            centerGradientView.position.x += centerGradientView.velocity.dx
            centerGradientView.position.y += centerGradientView.velocity.dy
            
            // 边界碰撞检测
            if centerGradientView.position.x >= frame.width/2.0 + x_max {
                centerGradientView.position.x = frame.width/2.0 + x_max
                centerGradientView.velocity.dx *= -1
            }
            
            if centerGradientView.position.x <= frame.width/2.0 - x_max {
                centerGradientView.position.x = frame.width/2.0 - x_max
                centerGradientView.velocity.dx *= -1
            }
            
            if centerGradientView.position.y >= y_max {
                centerGradientView.position.y = y_max
                centerGradientView.velocity.dy *= -1
            }
            
            if centerGradientView.position.y <= -y_max {
                centerGradientView.position.y = -y_max
                centerGradientView.velocity.dy *= -1
            }
            centerGradientView.center = centerGradientView.position
        }
    }
    
    private func randomVelocity() -> CGVector {
        let minSpeed: CGFloat = 0.5
        let maxSpeed: CGFloat = 2.0
        
        return CGVector(dx: CGFloat.random(in: minSpeed...maxSpeed) * (Bool.random() ? 1 : -1),
                        dy: CGFloat.random(in: minSpeed...maxSpeed) * (Bool.random() ? 1 : -1))
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

extension HomeTopBackgroundView {
    struct GradientColor {
        let left_1: UIColor
        let left_0: UIColor
        
        let right_1: UIColor
        let right_0: UIColor
        
        let center_1: UIColor
        let center_0: UIColor
        
        init(left_1: UIColor, left_0: UIColor, right_1: UIColor, right_0: UIColor, center_1: UIColor, center_0: UIColor) {
            self.left_1 = left_1
            self.left_0 = left_0
            self.right_1 = right_1
            self.right_0 = right_0
            self.center_1 = center_1
            self.center_0 = center_0
        }
        
        static func color(level: Int) -> GradientColor {
            switch level {
            case 0:
                return GradientColor.init(left_1: .Level_0_Left_1,
                                          left_0: .Level_0_Left_0,
                                          right_1: .Level_0_Right_1,
                                          right_0: .Level_0_Right_0,
                                          center_1: .Level_0_Center_1,
                                          center_0: .Level_0_Center_0)
                
            case 1:
                return GradientColor.init(left_1: .Level_1_Left_1,
                                          left_0: .Level_1_Left_0,
                                          right_1: .Level_1_Right_1,
                                          right_0: .Level_1_Right_0,
                                          center_1: .Level_1_Center_1,
                                          center_0: .Level_1_Center_0)
                
            case 2:
                return GradientColor.init(left_1: .Level_2_Left_1,
                                          left_0: .Level_2_Left_0,
                                          right_1: .Level_2_Right_1,
                                          right_0: .Level_2_Right_0,
                                          center_1: .Level_2_Center_1,
                                          center_0: .Level_2_Center_0)
                
            case 3:
                return GradientColor.init(left_1: .Level_3_Left_1,
                                          left_0: .Level_3_Left_0,
                                          right_1: .Level_3_Right_1,
                                          right_0: .Level_3_Right_0,
                                          center_1: .Level_3_Center_1,
                                          center_0: .Level_3_Center_0)
                
            case 4:
                return GradientColor.init(left_1: .Level_4_Left_1,
                                          left_0: .Level_4_Left_0,
                                          right_1: .Level_4_Right_1,
                                          right_0: .Level_4_Right_0,
                                          center_1: .Level_4_Center_1,
                                          center_0: .Level_4_Center_0)
                
            default:
                return GradientColor.init(left_1: .Level_0_Left_1,
                                          left_0: .Level_0_Left_0,
                                          right_1: .Level_0_Right_1,
                                          right_0: .Level_0_Right_0,
                                          center_1: .Level_0_Center_1,
                                          center_0: .Level_0_Center_0)
            }
        }
    }
}

class HomeTopBackgroundGradientView: UIView {
    var position: CGPoint
    var velocity: CGVector
    let colors: [UIColor]
    
    init(frame: CGRect, position: CGPoint, velocity: CGVector, colors: [UIColor]) {
        self.position = position
        self.velocity = velocity
        self.colors = colors
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.type = .radial
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(gradientLayer)
    }
}
