//
//  DropDownMenu.m
//  TYHxiaoxin
//
//  Created by hzth-mac3 on 15/10/20.
//  Copyright © 2015年 Lanxum. All rights reserved.
//

#import "DropDownMenu.h"
#import "UIView+Extention.h"

@interface DropDownMenu()
/**
 *  将来用来显示具体内容的容器
 */
@property (nonatomic, weak) UIImageView *containerView;
@end

@implementation DropDownMenu

//- (UIImageView *)containerView
//{
//    if (!_containerView) {
//        // 添加一个控件
//        UIImageView *containerView = [[UIImageView alloc] init];
//        containerView.backgroundColor = [UIColor TabBarColorGreen];
//        containerView.userInteractionEnabled = YES; // 开启交互
//        [self addSubview:containerView];
//        self.containerView = containerView;
//    }
//    return _containerView;
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 清除颜色
//        self.backgroundColor = [UIColor clearColor];
        
        // 添加一个控件
        UIImageView *containerView = [[UIImageView alloc] init];
//        containerView.backgroundColor = [UIColor TabBarColorGreen];
        containerView.userInteractionEnabled = YES; // 开启交互
        [self addSubview:containerView];
        self.containerView = containerView;
    }
    return self;
}

- (void)setContent:(UIView *)content
{
    _content = content;
    // 调整内容的位置
    content.x = 10;
    content.y = 0;
//    content.backgroundColor = [UIColor TabBarColorGreen];
    // 设置背景的高度
    self.containerView.height = CGRectGetMaxY(content.frame)  ;
    // 设置背景的宽度
    self.containerView.width = CGRectGetMaxX(content.frame) + 15;
    
    // 添加内容到背景颜色中
    [self.containerView addSubview:content];
}

- (void)setContentController:(UIViewController *)contentController
{
    _contentController = contentController;
    
    self.content = contentController.view;
}

/**
 *  显示
 */
- (void)showFrom:(UIView *)from
{
    // 1.获得最上面的窗口
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
    // 2.添加自己到窗口上
    [window addSubview:self];
    
    // 3.设置尺寸
    self.frame = window.bounds;
    
    // 4.调整背景的位置
    // 默认情况下，frame是以父控件左上角为坐标原点
    // 转换坐标系
    CGRect newFrame = [from convertRect:from.bounds toView:window];
    //    CGRect newFrame = [from.superview convertRect:from.frame toView:window];
    self.containerView.centerX = CGRectGetMidX(newFrame);
    self.containerView.y = CGRectGetMaxY(newFrame);
    
    // 通知外界，自己显示了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidShow:)]) {
        [self.delegate dropdownMenuDidShow:self];
    }
}

/**
 *  销毁
 */
- (void)dismiss
{
    [self removeFromSuperview];
    
    // 通知外界，自己被销毁了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidDismiss:)]) {
        [self.delegate dropdownMenuDidDismiss:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

@end
