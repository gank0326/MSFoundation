/*
#####################################################################
# File    : UIAlertViewCategory.h
# Project : 
# Created : 2013-03-30
# DevTeam : Thomas Develop
# Author  : 
# Notes   :
#####################################################################
### Change Logs   ###################################################
#####################################################################
---------------------------------------------------------------------
# Date  :
# Author:
# Notes :
#
#####################################################################
*/

#import <UIKit/UIKit.h>

//为SDK自带的 UIAlertView 类添加一些实用方法
@interface UIAlertView (AppExt)

// 隐藏当前实例 
+ (void)sb_hiddenTips;
+ (void)sb_hiddenTipsInView:(UIView *)view;

// 显示提示信息 （无按钮）
+ (void)sb_showTips:(NSString *)tips;

// 显示提示信息（可设定自动隐藏时间） 
+ (void)sb_showTips:(NSString *)tips hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds;

// 显示提示信息（可设定是否显示转子） 
+ (void)sb_showTips:(NSString *)tips showIndicator:(BOOL)showIndicator;

// 显示提示信息（可设定自动隐藏时间、是否显示转子） 
+ (void)sb_showTips:(NSString *)tips showIndicator:(BOOL)showIndicator hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds;

// 显示提示信息 （无按钮）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view;

// 显示提示信息（可设定自动隐藏时间）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds;

// 显示提示信息（可设定是否显示转子）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view showIndicator:(BOOL)showIndicator;

// 显示提示信息（可设定自动隐藏时间、是否显示转子）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view showIndicator:(BOOL)showIndicator hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds;


// 显示提示对话框 
+ (UIAlertView *)sb_showAlert:(NSString *)msg;

// 显示提示对话框(只有一个确定) 
+ (UIAlertView *)sb_showAlert:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate;

// 显示确定按钮对话框（取消和确定）
+ (UIAlertView *)sb_showConfirm:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate;

// 显示一个带ProgressView的对话框
+ (UIAlertView *)sb_showProgressDialog:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate;

// 显示一个带ActivityIndicator的对话框
+ (UIAlertView *)sb_showIndicatorDialog:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate;

// 获取提示文本控件 
- (UILabel *)sb_getTipsTextLabel;

@end
