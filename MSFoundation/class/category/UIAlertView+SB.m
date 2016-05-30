/*
#####################################################################
# File    : UIAlertViewCategory.m
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


#import "UIAlertView+SB.h"


@implementation UIAlertView (AppExt)

/** 获取window 弹出的时候不会被键盘遮住 */
+ (UIView *)systemKeyboardView {
    UIView *view =  [[UIApplication sharedApplication].delegate window];
    return view;
}

/** 隐藏当前实例 */
+ (void)sb_hiddenTips {
    UIView *keyView = [UIAlertView systemKeyboardView];
    [self sb_hiddenTipsInView:keyView];
}

+ (void)sb_hiddenTipsInView:(UIView *)view {
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

/** 显示提示信息 */
+ (void)sb_showTips:(NSString *)tips {
	[UIAlertView sb_showTips:tips showIndicator:YES hiddenAfterSeconds:0];
}

/** 显示提示信息（可设定自动隐藏时间） */
+ (void)sb_showTips:(NSString *)tips hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds {
	[UIAlertView sb_showTips:tips showIndicator:NO hiddenAfterSeconds:hiddenAfterSeconds];
}

/** 显示提示信息（可设定是否显示转子） */
+ (void)sb_showTips:(NSString *)tips showIndicator:(BOOL)showIndicator {
	[UIAlertView sb_showTips:tips showIndicator:showIndicator hiddenAfterSeconds:0];
}

/** 显示提示信息（可设定自动隐藏时间、是否显示转子） */
+ (void)sb_showTips:(NSString *)tips showIndicator:(BOOL)showIndicator hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds {
    UIView *keyView = [UIAlertView systemKeyboardView];
    [UIAlertView sb_showTips:tips inView:keyView showIndicator:showIndicator hiddenAfterSeconds:hiddenAfterSeconds];
}

// ///////////////////////////////////////////////////////////////////////////

// 显示提示信息 （无按钮）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view {
    [UIAlertView sb_showTips:tips inView:view showIndicator:YES hiddenAfterSeconds:0];
}

// 显示提示信息（可设定自动隐藏时间）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds {
    [UIAlertView sb_showTips:tips inView:view showIndicator:NO hiddenAfterSeconds:hiddenAfterSeconds];
}

// 显示提示信息（可设定是否显示转子）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view showIndicator:(BOOL)showIndicator {
    [UIAlertView sb_showTips:tips inView:view showIndicator:showIndicator hiddenAfterSeconds:0];
}

// 显示提示信息（可设定自动隐藏时间、是否显示转子）
+ (void)sb_showTips:(NSString *)tips inView:(UIView *)view showIndicator:(BOOL)showIndicator hiddenAfterSeconds:(CGFloat)hiddenAfterSeconds {
    if (tips.length == 0 || [tips isKindOfClass:[NSNull class]]) {
        tips = @"";
    }
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabelText = tips;
    hud.detailsLabelFont = [UIFont systemFontOfSize:14.0f];
    if (!showIndicator) {
        hud.mode = MBProgressHUDModeText;
    }
    if (hiddenAfterSeconds > 0) {
        [hud hide:YES afterDelay:hiddenAfterSeconds];
    }
}


/** 显示提示对话框 */
+ (UIAlertView *)sb_showAlert:(NSString *)msg {
    return [UIAlertView sb_showAlert:msg withDelegate:nil];
}

/** 显示提示对话框(withDelegate) */
+ (UIAlertView *)sb_showAlert:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate {
    [UIAlertView sb_hiddenTips];

    if (nil == msg || [msg length] < 1) {
        return nil;
    }

	UIAlertView *tipsView = [[UIAlertView alloc] initWithTitle: @"温馨提示"
                                                       message: msg
                                                      delegate: delegate
                                             cancelButtonTitle: @"确定"
                                             otherButtonTitles: nil];
	[tipsView show];

    return tipsView;
}

/** Show confirm message */
+ (UIAlertView *)sb_showConfirm:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate {
    [UIAlertView sb_hiddenTips];

    if (nil == msg || [msg length] < 1) {
        return nil;
    }

	UIAlertView *tipsView = [[UIAlertView alloc] initWithTitle: @"确认"
                                                       message: msg
                                                      delegate: delegate
                                             cancelButtonTitle: @"取消"
                                             otherButtonTitles: @"确定", nil];
	[tipsView show];

    return tipsView;
}

+ (UIAlertView *)sb_showProgressDialog:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate {
    [UIAlertView sb_hiddenTips];
    
    UIAlertView *tipsView = [[UIAlertView alloc] initWithTitle: msg
                                                       message: @"\n"   //为显示progress view做的hack
                                                      delegate: delegate
                                             cancelButtonTitle: @"下次再说"
                                             otherButtonTitles: nil];
    
    UIProgressView *progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(0, 0, 200.0f, 9.0f);
    progressView.center = CGPointMake(139.5, 60.5);
    [tipsView addSubview:progressView];
	[tipsView show];
    return tipsView;
}

+ (UIAlertView *)sb_showIndicatorDialog:(NSString *)msg withDelegate:(id<UIAlertViewDelegate>)delegate {
    [UIAlertView sb_hiddenTips];
    
    UIAlertView *tipsView = [[UIAlertView alloc] initWithTitle: msg
                                                       message: @"\n"   //为显示indicator view做的hack
                                                      delegate: delegate
                                             cancelButtonTitle: @"取消"
                                             otherButtonTitles: nil];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.center = CGPointMake(139.5, 60.5);
    [tipsView addSubview:indicator];
    [indicator startAnimating];
    
	[tipsView show];
    
    return tipsView;
}

/** 获取提示文本控件 */
- (UILabel *)sb_getTipsTextLabel {
	for(UIView *view in self.subviews){
		if( [view isKindOfClass:[UILabel class]] ){
			return (UILabel*) view;
		}
	}
	return nil;
}

@end
