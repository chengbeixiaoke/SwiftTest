//
//  UIDimmingView+Extension.m
//  CashSAVO
//
//  Created by yyw on 2025/2/11.
//

#import "UIDimmingView+Extension.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation UIDimmingView_Extension

+ (instancetype)sharedInstance {
    static UIDimmingView_Extension *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UIDimmingView_Extension alloc] init];
    });
    return sharedInstance;
}


// 交换方法的函数
void savo_swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector, Method originalMethod, Method swizzledMethod) {
    // 尝试添加原始方法
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        // 如果添加成功，将 swizzled 方法的实现替换为原始方法的实现
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        // 如果添加失败，交换两个方法的实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
// 重写的背景颜色设置方法
- (void)swizzledDidMoveToSuperview {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isKindOfClass:[UIView class]]) {
            CGFloat radius = 30;
            UIView *view =  (UIView *)self;
            CGFloat x = (view.bounds.size.width - view.superview.bounds.size.width)/2.0;
            CGFloat y = (view.bounds.size.height - view.superview.bounds.size.height)/2.0;
            CGFloat w = view.superview.bounds.size.width;
            CGFloat h = view.superview.bounds.size.height;

            // 创建贝塞尔曲线路径
            UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, w, h)
                                                              byRoundingCorners:UIRectCornerAllCorners
                                                                    cornerRadii:CGSizeMake(radius, radius)];
            
            // 创建形状图层
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = roundedPath.CGPath;
            
            // 添加 KVO 观察
            [view.layer addObserver:[UIDimmingView_Extension sharedInstance]
                         forKeyPath:@"mask"
                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context:NULL];
            
            // 添加 KVO 观察
            [view.layer addObserver:[UIDimmingView_Extension sharedInstance]
                         forKeyPath:@"cornerRadius"
                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context:NULL];
            
            // 应用裁剪
            view.layer.mask = shapeLayer;
            
        }
    });
    
    
    
    [self swizzledDidMoveToSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"cornerRadius"]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        NSLog(@"Corner radius 从 %@ 变为 %@", oldValue, newValue);
    }
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class UIDimmingView = NSClassFromString(@"UIDimmingView");
        if (UIDimmingView != nil) {
            SEL originalSelector = @selector(didMoveToSuperview);
            SEL swizzledSelector = @selector(swizzledDidMoveToSuperview);
            
            if ([UIDimmingView instancesRespondToSelector:originalSelector]) {
                Method originalMethod = class_getInstanceMethod(UIDimmingView, originalSelector);
                Method swizzledMethod = class_getInstanceMethod([UIDimmingView_Extension class], swizzledSelector);
                if (originalMethod != nil && swizzledMethod != nil) {
                    savo_swizzleMethod(UIDimmingView, originalSelector, swizzledSelector, originalMethod, swizzledMethod);
                }
            }
        }
    });
}
@end
