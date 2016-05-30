/*
#####################################################################
# File    : NSObjectCagegory.m
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

#import "NSObject+SBMODULE.h"
#import <UIKit/UIKit.h>

@implementation NSObject (sbmodule)

/** 以数组作为参数列表，执行对象的一个方法 */
- (id)performSelector:(SEL)func withParams:(NSArray *)params {
	NSMethodSignature *signature = [self methodSignatureForSelector:func];

    if (nil == signature) {
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

	[invocation setTarget:self];
	[invocation setSelector:func];

	if(nil != params){
		NSUInteger i = 1;

		for (id param in params) {
			[invocation setArgument:&param atIndex:++i];
		}
	}

	[invocation invoke];

	if ([signature methodReturnLength]) {
		id data;
		[invocation getReturnValue:&data];
		return data;
	}

	return nil;
}

- (BOOL)sb_notNull {
    return ((NSNull *)self != [NSNull null]);
}

@end

@implementation NSObject(SBTricks)

- (NSValue *)sb_asKey {
    return [NSValue valueWithNonretainedObject:self];
}

@end
