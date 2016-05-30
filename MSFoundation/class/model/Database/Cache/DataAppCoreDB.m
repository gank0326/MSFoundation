/*
#####################################################################
# File    : DataAppCoreDB.m
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

#import "DataAppCoreDB.h"

@implementation DataAppCoreDB

@synthesize TABLE_USER_TRACE;

// 确保核心数据库有 USER_TRACE 表
- (void)createTables {
    [super createTables];

    //用户使用习惯数据
    TABLE_USER_TRACE = @"USER_TRACE";

    NSString *_ddlStrUserTrace = @"CREATE TABLE [USER_TRACE]("
    @"[ID] INTEGER PRIMARY KEY, "
    @"[TRACE_POINT] CHAR(200),"
    @"[TRACE_COUNT] INTEGER,"
    @"[TRACE_COUNT_ONSUBMIT] INTEGER);"
    @"CREATE UNIQUE INDEX [USER_TRACE_unique_key] ON [USER_TRACE] ([TRACE_POINT]);";

    if (![self hasTable:TABLE_USER_TRACE]) {
        [self execSQL:_ddlStrUserTrace];
    }
}

//初始化数据库
- (id)init {
    return [super init:APPCONFIG_DB_CORE_NAME];
}

@end
