//
//  AlertView.h
//  MyTimLogistics
//
//  Created by 麦田计划 on 16/7/8.
//  Copyright © 2016年 麦田计划. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView

+ (void) addNotifierWithText : (NSString* ) text dismissAutomatically :(BOOL) shouldDismiss;
+ (void) dismissNotifier;


@end
