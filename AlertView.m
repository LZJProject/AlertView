//
//  AlertView.m
//  MyTimLogistics
//
//  Created by 麦田计划 on 16/7/8.
//  Copyright © 2016年 麦田计划. All rights reserved.
//

#import "AlertView.h"
#import <QuartzCore/QuartzCore.h>

#define APPDELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)


#define NOTIFIER_LABEL_FONT ([UIFont fontWithName:@"HelveticaNeue-Light" size:18])
#define NOTIFIER_CANCEL_FONT ([UIFont fontWithName:@"HelveticaNeue" size:13])

#define MINVALUE(A,B) ((A) <= (B) ? (A) : (B))

static const NSInteger kAlertViewTag = 1812;
static const NSInteger xPadding = 18.0;
static const CGFloat kLabelHeight = 45.0f;
static const CGFloat kCancelButtonHeight = 30.0f;
static const CGFloat kSeparatorHeight = 1.0f;
static const CGFloat kHeightFromBottom = 80.f;


@implementation AlertView

+ (void) addNotifierWithText : (NSString* ) text dismissAutomatically :(BOOL)shouldDismiss
{
    if (!STRINGHASVALUE(text))
        return;
    
    // 获取屏幕区域
    CGRect screenBounds = APPDELEGATE.window.bounds;
    
    // 获取给定文案的宽度
    NSDictionary *attributeDict = @{NSFontAttributeName : NOTIFIER_LABEL_FONT};
    CGFloat height = kLabelHeight;
    CGFloat width = CGFLOAT_MAX;
    CGRect notifierRect = CGRectZero;
    if (iOSVersion >= 7)
    {
        notifierRect = [text boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributeDict context:nil];
        // 2.1 将参数NULL 改为nil  褚
    }
    
    // 获取提醒视图x方向位移的宽度
    CGFloat notifierWidth = MIN(CGRectGetWidth(notifierRect) + 2*xPadding, SCREEN_WIDTH*0.95);
    
    CGFloat xOffset = (CGRectGetWidth(screenBounds) - notifierWidth)/2;
    
    // 获取提醒视图的高度，如果不是自动消失则添加取消按钮
    NSInteger notifierHeight = kLabelHeight;
    if(!shouldDismiss) {
        notifierHeight += (kCancelButtonHeight+kSeparatorHeight);
    }
    
    // 获取提醒视图的y方向位移
    CGFloat yOffset = CGRectGetHeight(screenBounds) - notifierHeight - kHeightFromBottom;
    
    CGRect finalFrame = CGRectMake(xOffset, yOffset, notifierWidth, notifierHeight);
    
    UIView* notifierView = [self checkIfNotifierExistsAlready];
    if(notifierView) {
        // 更新已经存在的提醒视图
        [self updateNotifierWithAnimation:notifierView withText:text andFinalFrame:finalFrame completion:^(BOOL finished) {
            CGRect atLastFrame = finalFrame;
            atLastFrame.origin.y = finalFrame.origin.y + 8;
            notifierView.frame = atLastFrame;
            
            // 获取label，然后更新大小和文案
            UILabel* textLabel = nil;
            for (UIView* subview in notifierView.subviews) {
                if([subview isKindOfClass:[UILabel class]]) {
                    textLabel = (UILabel* ) subview;
                }
                
                // 移除分隔线和取消按钮，这里可以按需要来添加
                if([subview isKindOfClass:[UIImageView class]] || [subview isKindOfClass:[UIButton class]]) {
                    [subview removeFromSuperview];
                }
            }
            textLabel.text = text;
            textLabel.frame = CGRectMake(xPadding, 0.0, notifierWidth - 2*xPadding, kLabelHeight);
            
            // 如果没有消失
            if(!shouldDismiss) {
                // 首先展示一个分隔线
                UIImageView* separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(textLabel.frame), CGRectGetWidth(notifierView.frame), kSeparatorHeight)];
                [separatorImageView setBackgroundColor:RGBACOLOR(100, 100, 100, 1)];
                [notifierView addSubview:separatorImageView];
                
                // 添加取消按钮
                UIButton* buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonCancel.frame = CGRectMake(0.0, CGRectGetMaxY(separatorImageView.frame), CGRectGetWidth(notifierView.frame), kCancelButtonHeight);
                [buttonCancel setBackgroundColor:[UIColor colorWithHex:0x000000 alpha:1]];
                [buttonCancel addTarget:self action:@selector(buttonCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
                [buttonCancel setTitle:@"取消" forState:UIControlStateNormal];
                buttonCancel.titleLabel.font = NOTIFIER_CANCEL_FONT;
                [notifierView addSubview:buttonCancel];
            }
            
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                notifierView.alpha = 1;
                notifierView.frame = finalFrame;
            } completion:^(BOOL finished) {
            }];
        }];
        
        if(shouldDismiss) {
            [self performSelector:@selector(dismissNotifier) withObject:nil afterDelay:2.0];
        }
    }
    else {
        notifierView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, CGRectGetHeight(screenBounds), notifierWidth, notifierHeight)];
        notifierView.backgroundColor = RGBACOLOR(100, 100, 100, 1);
        notifierView.tag = kAlertViewTag;
        notifierView.clipsToBounds = YES;
        notifierView.layer.cornerRadius = 5.0;
        [APPDELEGATE.window addSubview:notifierView];
        [APPDELEGATE.window bringSubviewToFront:notifierView];
        
        // 创建提醒视图内的文案label
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPadding, 0.0, notifierWidth - 2*xPadding, kLabelHeight)];
        textLabel.adjustsFontSizeToFitWidth = YES;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor colorWithHex:0xFFFFFF alpha:1];
        textLabel.font = NOTIFIER_LABEL_FONT;
        textLabel.minimumScaleFactor = 0.7;
        textLabel.text = text;
        [notifierView addSubview:textLabel];
        
        if(shouldDismiss) {
            [self performSelector:@selector(dismissNotifier) withObject:nil afterDelay:2.0];
        }
        else {
            // 如果不是自动取消的话，显示取消按钮
            
            // 添加分隔线
            UIImageView* separatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight(textLabel.frame), notifierWidth, kSeparatorHeight)];
            [separatorImageView setBackgroundColor:[UIColor colorWithHex:0xF94137 alpha:1]];
            [notifierView addSubview:separatorImageView];
            
            // 添加取消按钮
            UIButton* buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonCancel.frame = CGRectMake(0.0, CGRectGetMaxY(separatorImageView.frame), notifierWidth, kCancelButtonHeight);
            [buttonCancel setBackgroundColor: [UIColor colorWithHex:0x000000 alpha:1]];
            [buttonCancel addTarget:self action:@selector(buttonCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
            buttonCancel.titleLabel.font = NOTIFIER_CANCEL_FONT;
            [notifierView addSubview:buttonCancel];
        }
        
        [self startEntryAnimation:notifierView withFinalFrame:finalFrame];
    }
}

+ (UIView* ) checkIfNotifierExistsAlready {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissNotifier) object:nil];
    
    UIView* notifier = nil;
    for (UIView* subview in [APPDELEGATE.window subviews]) {
        if(subview.tag == kAlertViewTag && [subview isKindOfClass:[UIView class]]) {
            notifier = subview;
        }
    }
    
    return notifier;
}

+ (void) dismissNotifier {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissNotifier) object:nil];
    
    UIView* notifier = nil;
    
    for (UIView* subview in [APPDELEGATE.window subviews]) {
        if(subview.tag == kAlertViewTag && [subview isKindOfClass:[UIView class]]) {
            notifier = subview;
        }
    }
    
    [self startExitAnimation:notifier];
}

+ (void) buttonCancelClicked : (id) sender {
    [self dismissNotifier];
}

#pragma mark - Animation part
+ (void) updateNotifierWithAnimation : (UIView* ) notifierView withText : (NSString* ) text andFinalFrame:(CGRect)finalFrame completion:(void (^)(BOOL finished))completion {
    //    CGRect finalFrame = notifierView.frame;
    //    finalFrame.origin.y = finalFrame.origin.y + 8;
    
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        notifierView.alpha = 0;
        notifierView.frame = finalFrame;
    } completion:^(BOOL finished) {
        completion(finished);
    }];
}

+ (void) startEntryAnimation : (UIView* ) notifierView withFinalFrame : (CGRect) finalFrame {
    
    CGFloat finalYOffset = finalFrame.origin.y;
    finalFrame.origin.y = finalFrame.origin.y - 15;
    
    CATransform3D transform = [self transformWithXAxisValue:-0.1 andAngle:45];
    notifierView.layer.zPosition = 400;
    notifierView.layer.transform = transform;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        notifierView.frame = finalFrame;
        
        CATransform3D transform = [self transformWithXAxisValue:0.1 andAngle:15];
        notifierView.layer.zPosition = 400;
        notifierView.layer.transform = transform;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect atLastFrame = notifierView.frame;
            atLastFrame.origin.y = finalYOffset;
            notifierView.frame = atLastFrame;
            
            CATransform3D transform = [self transformWithXAxisValue:0.0 andAngle:90];
            notifierView.layer.zPosition = 400;
            notifierView.layer.transform = transform;
            
        } completion:^(BOOL finished) {
        }];
    }];
}

+ (void) startExitAnimation : (UIView* ) notifierView {
    
    //get screen area
    CGRect screenBounds = APPDELEGATE.window.bounds;
    
    CGRect notifierFrame = notifierView.frame;
    CGFloat finalYOffset = notifierFrame.origin.y - 12;
    notifierFrame.origin.y = finalYOffset;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        notifierView.frame = notifierFrame;
        
        CATransform3D transform = [self transformWithXAxisValue:0.1 andAngle:30];
        notifierView.layer.zPosition = 400;
        notifierView.layer.transform = transform;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            CGRect atLastFrame = notifierView.frame;
            atLastFrame.origin.y = CGRectGetHeight(screenBounds);
            notifierView.frame = atLastFrame;
            
            CATransform3D transform = [self transformWithXAxisValue:-1 andAngle:90];
            notifierView.layer.zPosition = 400;
            notifierView.layer.transform = transform;
            
        } completion:^(BOOL finished) {
            [notifierView removeFromSuperview];
        }];
    }];
}

+ (CATransform3D) transformWithXAxisValue : (CGFloat) xValue  andAngle : (CGFloat) valueOfAngle {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -1000;
    //this would rotate object on an axis of x = 0, y = 1, z = -0.3f. It is "Z" here which would
    transform = CATransform3DRotate(transform, valueOfAngle * M_PI / 180.0f, xValue, 0.0, 0.);
    return transform;
}


@end
