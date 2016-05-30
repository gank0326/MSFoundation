/*
 #####################################################################
 # File    : DataBaseCacheClean.h.m
 # Project : 
 # Created : 2013-03-30
 # DevTeam : thomas only one
 # Author  : thomas
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

#import "DataBaseCacheClean.h"
#import "MSAppCoreInfo.h"
#import "DataSQLiteDB.h"
#import "DataAppCacheDB.h"

@implementation DataBaseCacheClean

// 执行数据库缓存清理操作
+ (void)cleanAllDBCache {
    DataAppCacheDB *cacheDB = [MSAppCoreInfo getCacheDB];
    [cacheDB truncateTable:cacheDB.dbBinValueTable];
    [cacheDB truncateTable:cacheDB.dbStrValueTable];
    [cacheDB truncateTable:cacheDB.dbIntValueTable];
    [cacheDB compressDB];
}

@end
