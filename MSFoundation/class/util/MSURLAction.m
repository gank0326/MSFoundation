//
//  NVURLAction.m
//  Core
//
//  Created by ZhouHui on 14-4-21.
//  Copyright (c) 2014年 dianping.com. All rights reserved.
//

#import "MSURLAction.h"
#import <objc/runtime.h>

//是否正在有界面开启的动画
static BOOL sbIsCtrlAnimating = NO;

@interface MSURLAction ()


@end

@implementation MSURLAction

+ (id)actionWithClassName:(NSString *)className {
    NSString *urlString = [NSString stringWithFormat:@"stockbar://%@", className];
    return [[self alloc] initWithURLString:urlString];
}

+ (id)actionWithURL:(NSURL *)url {
    return [[MSURLAction alloc] initWithURL:url];
}

+ (id)actionWithURLString:(NSString *)urlString {
    return [[self alloc] initWithURLString:urlString];
}

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        
        NSDictionary *dic = [url parseQuery];
        _params = [NSMutableDictionary dictionary];
        for (NSString *key in [dic allKeys]) {
            id value = [dic objectForKey:key];
            [_params setObject:value forKey:key];
        }
    }
    return self;
}

- (id)initWithURLString:(NSString *)urlString {
    NSString*stringURL = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [self initWithURL:[NSURL URLWithString:stringURL]];
}

- (void)setInteger:(NSInteger)intValue forKey:(NSString *)key {
    [_params setObject:[NSNumber numberWithInteger:intValue] forKey:key];
}

- (void)setDouble:(double)doubleValue forKey:(NSString *)key {
    [_params setObject:[NSNumber numberWithDouble:doubleValue] forKey:key];
}

- (void)setString:(NSString *)string forKey:(NSString *)key {
    if (string.length > 0) {
        [_params setObject:string forKey:key];
    }
}

- (void)setObject:(NSObject *)object forKey:(NSString *)key {
    if(object) {
        [_params setObject:object forKey:key];
    }
}

- (void)setAnyObject:(id)object forKey:(NSString *)key {
    if(object) {
        [_params setObject:object forKey:key];
    }
}

- (NSInteger)integerForKey:(NSString *)key {
    NSString *urlStr = [_params objectForKey:key];
    if(urlStr) {
        if ([urlStr isKindOfClass:[NSString class]]) {
            return [urlStr integerValue];
        } else if ([urlStr isKindOfClass:[NSNumber class]]) {
            return [(NSNumber *)urlStr integerValue];
        }
    }
    return 0;
}

- (double)doubleForKey:(NSString *)key {
    NSString *urlStr = [_params objectForKey:key];
    if(urlStr) {
        if ([urlStr isKindOfClass:[NSString class]]) {
            return [urlStr doubleValue];
        } else if ([urlStr isKindOfClass:[NSNumber class]]) {
            return [(NSNumber *)urlStr doubleValue];
        }
    }
    return .0;
}

- (NSString *)stringForKey:(NSString *)key {
    NSString *urlStr = [_params objectForKey:key];
    if(urlStr) {
        if ([urlStr isKindOfClass:[NSString class]]) {
            return urlStr;
        }
    }
    return nil;
}
- (NSObject *)objectForKey:(NSString *)key {
    NSString *urlStr = [_params objectForKey:key];
    if(urlStr) {
        if ([urlStr isKindOfClass:[NSObject class]]) {
            return (NSObject *)urlStr;
        }
    }
    return nil;
}

- (id)anyObjectForKey:(NSString *)key {
    return [_params objectForKey:key];
}

- (NSString *)description {
    if([_params count]) {
        NSMutableArray *paramsDesc = [NSMutableArray arrayWithCapacity:_params.count];
        for(NSString *key in [_params keyEnumerator]) {
            id value = [_params objectForKey:key];
            if ([value isKindOfClass:[NSObject class]]) {
                [paramsDesc addObject:[NSString stringWithFormat:@"%@=[Obj]", key]];
            } else if ([value isKindOfClass:[NSString class]]) {
                [paramsDesc addObject:[NSString stringWithFormat:@"%@=%@", key, [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            } else {
                [paramsDesc addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
            }
        }
        NSString *urlString = [_url absoluteString];
        NSRange range = [urlString rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            NSString *pureURLStirng = [urlString substringToIndex:range.location];
            return [pureURLStirng stringByAppendingFormat:@"?%@",[paramsDesc componentsJoinedByString:@"&"]];
        } else {
            return [urlString stringByAppendingFormat:@"?%@",[paramsDesc componentsJoinedByString:@"&"]];
        }
    } else {
        return [_url absoluteString];
    }
}

- (NSDictionary *)queryDictionary {
    return _params;
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    if (!otherDictionary) {
        return;
    }
    [_params addEntriesFromDictionary:otherDictionary];
}

- (void)addParamsFromURLAction:(MSURLAction *)otherURLAction {
    NSDictionary *dic = [otherURLAction queryDictionary];
    [self addEntriesFromDictionary:dic];
}

/** 通过配置 生成一个界面控制器 */
+ (UIViewController *)sb_initCtrl:(MSURLAction *)urlAction {
    if (!urlAction || !urlAction.url) {
        return nil;
    }
    
    NSURL *url = urlAction.url;
    
    
    Class ctrlClass = NSClassFromString(url.host);
    NSAssert(ctrlClass != nil, @"确保是工程中有的controller类");
    UIViewController *controller = [ctrlClass new];
    NSAssert([controller isKindOfClass:[UIViewController class]], @"确保是一个controller类");
    
    controller.urlAction = urlAction;
    [controller sb_setPropertyForController:urlAction];
    
    return controller;
}

@end

@implementation UIViewController (urlAction)

- (void)setUrlAction:(MSURLAction *)urlAction {
    objc_setAssociatedObject(self, @"UIViewControllerSBURLAction", urlAction, OBJC_ASSOCIATION_RETAIN);
}

- (MSURLAction *)urlAction {
    return objc_getAssociatedObject(self, @"UIViewControllerSBURLAction");
}

- (void)animationIsOver {
    sbIsCtrlAnimating = NO;
}

- (UIViewController *)sb_makeCtrl:(MSURLAction *)urlAction {
    //用定时器控制下一次允许打开新界面
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animationIsOver];
    });
    
    if (sbIsCtrlAnimating) {
        return nil;
    }
    sbIsCtrlAnimating = YES;
    
    UIViewController *controller = [MSURLAction sb_initCtrl:urlAction];
    controller.urlAction = urlAction;
    [controller sb_setPropertyForController:urlAction];
    
    return controller;
}

- (UIViewController *)sb_openCtrl:(MSURLAction *)urlAction {
    UIViewController *controller = [self sb_makeCtrl:urlAction];
    [self.navigationController pushViewController:controller animated:YES];
    return controller;
}

- (UIViewController *)sb_modalCtrl:(MSURLAction *)urlAction {
    UIViewController *controller = [self sb_makeCtrl:urlAction];
    [self.navigationController presentViewController:controller animated:YES completion:^{
    }];
    return controller;
}

/** 跳转到root 再推出界面 */
- (UIViewController *)sb_popRootAndOpenCtrl:(MSURLAction *)urlAction {
    [self.navigationController popToRootViewControllerAnimated:NO];
    //用root ctrl 来push
    return [self.navigationController sb_openCtrl:urlAction];
}

/** 赋值ctrl的属性值 */
- (void)sb_setPropertyForController:(MSURLAction *)action {
    
    [action.params enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id obj, BOOL *stop) {
        NSAssert([propertyName isKindOfClass:[NSString class]], @"属性名必须为字符串");
        
        if ([self respondsToSelector:NSSelectorFromString(propertyName)]) {
            // To ensure that the existence of a property.
            [self setValue:obj forKeyPath:propertyName];
        }
    }];
}

/** 仅仅推出只需要 init 就可以实现功能的界面 */
- (UIViewController *)sb_quickOpenCtrl:(NSString *)ctrlName {
    return [self sb_openCtrl:[MSURLAction actionWithClassName:ctrlName]];
}

/** 在当前的 栈中关闭新的URL */
- (void)sb_colseCtrl {
    if (sbIsCtrlAnimating) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)sb_dismissCtrl:(void (^)(void))completion {
    if (sbIsCtrlAnimating) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        completion();
    }];
}

@end

@implementation UINavigationController (urlAction)
//配合UIViewController出来的扩展方法
- (UIViewController *)sb_openCtrl:(MSURLAction *)urlAction {
    return [self.topViewController sb_openCtrl:urlAction];
}
- (UIViewController *)sb_modalCtrl:(MSURLAction *)urlAction {
    return [self.topViewController sb_modalCtrl:urlAction];
}
- (void)sb_colseCtrl {
    [self.topViewController sb_colseCtrl];
}
/** 跳转到root 再推出界面 */
- (UIViewController *)sb_popRootAndOpenCtrl:(MSURLAction *)urlAction {
    return [self.topViewController sb_popRootAndOpenCtrl:urlAction];
}

/** 仅仅推出只需要 init 就可以实现功能的界面 */
- (UIViewController *)sb_quickOpenCtrl:(NSString *)ctrlName {
    return [self.topViewController sb_openCtrl:[MSURLAction actionWithClassName:ctrlName]];
}

@end


@implementation NSURL (urlAction)

- (NSDictionary *)parseQuery {
    NSString *query = [self query];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        if ([elements count] <= 1) {
            continue;
        }
        
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end

