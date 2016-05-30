/*
 #####################################################################
 # File    : DataSQLiteDB.h
 # Project : 
 # Created : 2013-03-30
 # DevTeam :
 # Author  : roronoa
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

#import "DataSQLiteDB.h"
#import "MSFileManager.h"

@interface DataSQLiteDB() {
    sqlite3  *_sqlite3;             //数据库操作
}

@property (nonatomic, copy) NSString *dbpath;

@end

@implementation DataSQLiteDB

#pragma mark -
#pragma mark 生命周期

//初始化数据库，不存在则创建
- (id)init:(NSString *)dbname {
    self = [super init];

    if (nil != self) {
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        _dbpath = [[MSFileManager getDbFullPath:dbname] copy];
        
        if (nil == _dbpath || sqlite3_open([_dbpath UTF8String], &_sqlite3) != SQLITE_OK) {
            _sqlite3 = nil;
        }
    }

    return self;
}


//释放资源
- (void)dealloc {
    [self closeDB];
//    
//    [_dbpath release];
//    
//    [super dealloc];
}


#pragma mark -
#pragma mark 基本操作

//调试出错信息(char * 错误信息)
- (void)printErrorCString:(const char *)msg {
    //TODO：发布时不允许打印
    NSLog(@"%@", @(msg));
}

/** 清空一张表 */
- (void)truncateTable:(NSString *)tableName {
    if([tableName length] < 1){
        return;
    }
    
    [self execSQL:[NSString stringWithFormat:@"DELETE FROM '%@'", tableName]];
    [self execSQL:[NSString stringWithFormat:@"UPDATE sqlite_sequence SET seq=0 WHERE name='%@'", tableName]];
}

/** 清理并压缩数据库 */
- (void)compressDB {
    [self execSQL:@"VACUUM"];
}

//关闭数据库
- (void)closeDB {
    if(nil != _sqlite3){
        sqlite3_close(_sqlite3);
        _sqlite3 = nil;
    }
}

//执行一句SQL，不返回数据
- (BOOL)execSQL:(NSString *)sqlStr {
    char *msg = nil;

    if (nil == _sqlite3 || nil == sqlStr) {
        return NO;
    }

    @try {
        
    if (sqlite3_exec(_sqlite3, [sqlStr UTF8String], NULL, NULL, &msg) != SQLITE_OK ) {
        if (nil != msg) {
            sqlite3_free(msg);
        }

        return NO;
    }
        
    }
    @catch (NSException *exception) {
        return NO;
    }

    return YES;
}

//打开一个SQL查询语句的游标
- (sqlite3_stmt *)query:(NSString *)sqlStr {
    if (sqlStr == nil) {
        return nil;
    }
    sqlite3_stmt *pStmt = nil;
    const char *msg = nil;

    if (nil == _sqlite3 || nil == sqlStr) {
        return nil;
    }
    @try {
        
        int result = sqlite3_prepare_v2(_sqlite3, [sqlStr UTF8String], -1, &pStmt, &msg);
        
        if (result != SQLITE_OK) {
            if (nil != msg) {
                [self printErrorCString:sqlite3_errmsg(_sqlite3)];
            }
            
            return nil;
        }
        
    }
    @catch (NSException *exception) {
        return nil;
    }
    return pStmt;
}

//绑定变量到一个SQL查询游标
- (BOOL)bind:(sqlite3_stmt *)pStmt data:(NSDictionary *)data {
    if (nil == data || [data count] < 1) {
        return NO;
    }
    
    NSArray *allKeys = [data allKeys];
    
    for(int i=0; i<[allKeys count]; i++){
        NSString *key = allKeys[i];
        NSObject *value = data[key];
        
        //数据内容是字符串
        if ([value isKindOfClass:[NSString class]]) {
            const char *str_value = [(NSString *)value UTF8String];
            
            if(SQLITE_OK != sqlite3_bind_text(pStmt, i + 1, str_value, (int)strlen(str_value), SQLITE_STATIC)){
                [self printErrorCString:sqlite3_errmsg(_sqlite3)];
                return NO;
            }
            
            // 数据内容是NSData
        } else if([value isKindOfClass:[NSData class]]) {
            const void *bytes_value = [(NSData *)value bytes];
            
            if(SQLITE_OK != sqlite3_bind_blob(pStmt, i + 1, bytes_value, (int)[(NSData *)value length], SQLITE_STATIC)){
                [self printErrorCString:sqlite3_errmsg(_sqlite3)];
                return NO;
            }
            
            // 数据内容是数字
        } else if([value isKindOfClass:[NSNumber class]]) {
            NSNumber *number_value = (NSNumber *)value;
            if ([[number_value stringValue] rangeOfString:@"."].location == NSNotFound) {
                int int_value = [number_value intValue];
                
                if(SQLITE_OK != sqlite3_bind_int(pStmt, i + 1, int_value)){
                    [self printErrorCString:sqlite3_errmsg(_sqlite3)];
                    return NO;
                }
            } else {
                double double_value = [number_value doubleValue];
                
                if(SQLITE_OK != sqlite3_bind_double(pStmt, i + 1, double_value)){
                    [self printErrorCString:sqlite3_errmsg(_sqlite3)];
                    return NO;
                }
            }
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark 查询操作
//获取列表数据，返回一个数据键值对的数组
- (NSArray *)getAllDBData:(NSString *)sqlStr {
    sqlite3_stmt *pStmt = [self query:sqlStr];

    if (nil == pStmt) {
        return nil;
    }

    NSMutableArray *_dataArray  = [[NSMutableArray alloc] init];
    NSMutableArray *_columnNames = nil;

    //通过游标遍历数据表格
    while (sqlite3_step(pStmt) == SQLITE_ROW) {
        //列名就加载一次，因为每次都相同
        if (nil == _columnNames) {
            _columnNames = [NSMutableArray arrayWithCapacity:0];

            //列数
            int _columnCount = sqlite3_column_count(pStmt);

            //分配列标题
            for (int i=0; i < _columnCount; i++) {
                const char *title = sqlite3_column_name(pStmt, i);
                [_columnNames addObject:@(title)];
            }
        }

        //对应列名的字典
        NSMutableDictionary *_columnDictionary = [NSMutableDictionary dictionaryWithCapacity:0];

        for (int i = 0; i < [_columnNames count]; i++) {
            const char *str_value = (const char *)sqlite3_column_text(pStmt, i);
            NSString *value = (nil == str_value ? @"" : @(str_value));
            //通过列名取单元格（保险）
            _columnDictionary[_columnNames[i]] = value;
        }

        //每行数据都以字典形式加入到数组中
        [_dataArray addObject:_columnDictionary];
    }

    sqlite3_finalize(pStmt);

    return _dataArray;
}

//获取单条数据，返回一个对应的键值对
- (NSDictionary *)getColumnItem:(NSString *)sqlStr {
    sqlite3_stmt *pStmt = [self query:sqlStr];
    
    if (nil == pStmt) {
        return nil;
    }
    
    //一条数据
    NSMutableDictionary *_columnItem = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    if (sqlite3_step(pStmt) == SQLITE_ROW) {
        
        int _columnCount = sqlite3_column_count(pStmt);
        
        for (int i=0; i < _columnCount; i++) {
            NSString *title = @(sqlite3_column_name(pStmt, i));
            const char *str_value = (const char *)sqlite3_column_text(pStmt, i);
            NSString *value = (nil == str_value ? @"" : @(str_value));
            _columnItem[title] = value;
        }
    }
    
    sqlite3_finalize(pStmt);
    
    return _columnItem;
}

//获取一个数据cell中的数据
- (NSString *)getColumnText:(NSString *)sqlStr {
    sqlite3_stmt *pStmt = [self query:sqlStr];

    if (nil == pStmt) {
        return nil;
    }

    //一个数据表格中的字符串
    NSString *value = nil;

    if (sqlite3_step(pStmt) == SQLITE_ROW) {
        const char *str_value = (const char *)sqlite3_column_text(pStmt, 0);
        value = (nil == str_value ? @"" : @(str_value));
    }

    sqlite3_finalize(pStmt);

    return value;
}

#pragma mark -
#pragma mark 增，删，改操作
//插入数据到指定表中
- (sqlite3_int64)insertData:(NSString *)tableName data:(NSDictionary *)data {
    if (nil == _sqlite3 || nil ==  tableName || [tableName length] < 1 || nil == data || [data count] < 1) {
        return 0;
    }

    //键名数组 值数组
    NSMutableString *SQL_fields = [NSMutableString stringWithCapacity:0];
    NSMutableString *SQL_values = [NSMutableString stringWithCapacity:0];

    //对应的是列名
    for (NSString *key in [data allKeys]) {
        if ([key length] < 1) {
            continue;
        }

        //第一列特殊处理，拼字符串
        if ([SQL_fields length] > 0) {
            [SQL_fields appendString:@","];
            [SQL_values appendString:@","];
        }

        [SQL_fields appendFormat:@"`%@`", key];
        [SQL_values appendString:@"?"];
    }

    if ([SQL_fields length] < 1) {
        return 0;
    }

    //sql 插入的语句
    NSString *_insertSql = [NSString stringWithFormat:@"insert into `%@`(%@) values (%@)", tableName, SQL_fields, SQL_values];

    sqlite3_stmt *pStmt = [self query:_insertSql];

    if (nil == pStmt) {
        return 0;
    }

    sqlite3_int64 insert_id = 0;

    //检测插入成功
    if ([self bind:pStmt data:data]) {
        if(sqlite3_step(pStmt) == SQLITE_DONE){
            insert_id = sqlite3_last_insert_rowid(_sqlite3);
        } else {
            [self printErrorCString:sqlite3_errmsg(_sqlite3)];
        }
    }

    sqlite3_finalize(pStmt);

    return insert_id;
}

//删除指定表中符合条件的数据
- (int)deleteData:(NSString *)tableName whereParam:(NSString *)whereParam {
    if (nil == tableName || [tableName length] < 1) {
        return 0;
    }

    NSMutableString *_deleteSql = [NSMutableString stringWithCapacity:0];
    [_deleteSql appendFormat:@"delete from `%@`", tableName];

    if (nil != whereParam || [whereParam length] > 0) {
        [_deleteSql appendFormat:@" where %@", whereParam];
    }

    if (![self execSQL:_deleteSql]) {
        return 0;
    }

    return sqlite3_changes(_sqlite3);
}

//更新一条数据库记录
- (int)updateData:(NSString *)tableName data:(NSDictionary *)data whereParam:(NSString *)whereParam {
    if (nil == _sqlite3 || nil ==  tableName || [tableName length] < 1 || nil == data || [data count] < 1) {
        return 0;
    }
    
    NSMutableString *_fieldsSql = [NSMutableString stringWithCapacity:0];
    
    for (NSString *key in [data allKeys]) {
        if ([key length] < 1) {
            continue;
        }
        
        if ([_fieldsSql length] > 0) {
            [_fieldsSql appendString:@","];
        }
        
        [_fieldsSql appendFormat:@"`%@`=?", key];
    }
    
    if ([_fieldsSql length] < 1) {
        return 0;
    }
    
    NSMutableString *_updateSql = [NSMutableString stringWithCapacity:0];
    
    [_updateSql appendFormat:@"update `%@` set %@", tableName, _fieldsSql];
    
    if (nil != whereParam || [whereParam length] > 0) {
        [_updateSql appendFormat:@" where %@", whereParam];
    }
    
    sqlite3_stmt *pStmt = [self query:_updateSql];
    
    if (nil == pStmt) {
        return 0;
    }
    
    int changes_count = 0;
    
    if ([self bind:pStmt data:data]) {
        if(sqlite3_step(pStmt) == SQLITE_DONE){
            changes_count = sqlite3_changes(_sqlite3);
        }
    }
    
    sqlite3_finalize(pStmt);
    
    return changes_count;
}

#pragma mark -
#pragma mark 其他操作
//获取指定表中符合条件的数据条数
- (sqlite3_int64)tableRows:(NSString *)tableName whereParam:(NSString *)whereParam {
    if (nil == tableName || [tableName length] < 1) {
        return 0;
    }

    NSMutableString *_countStr = [NSMutableString stringWithCapacity:0];

    [_countStr appendFormat:@"select count(*) from `%@`", tableName];

    if (nil != whereParam || [whereParam length] > 0) {
        [_countStr appendFormat:@" where %@", whereParam];
    }

    sqlite3_stmt *pStmt = [self query:_countStr];

    if (nil == pStmt) {
        return 0;
    }

    sqlite3_int64 rows_count = 0;

    if (sqlite3_step(pStmt) == SQLITE_ROW) {
        rows_count = sqlite3_column_int64(pStmt, 0);
    }

    sqlite3_finalize(pStmt);

    return rows_count;
}

//判断数据库中是否存在某张表
- (BOOL)hasTable:(NSString *)tableName {
    return [self tableRows:@"sqlite_master" whereParam: [NSString stringWithFormat:@"`type`='table' and `name`='%@'", tableName]] > 0;
}



#pragma mark -
#pragma mark 事务
//事务处理：开始事务处理
- (BOOL)beginEvent {
    return [self execSQL:@"BEGIN"];
}

//事务处理：提交事务
- (BOOL)commitEvent {
    return [self execSQL:@"COMMIT"];
}

//事务处理：回滚事务
- (BOOL)rollbackEvent {
    return [self execSQL:@"ROLLBACK"];
}

@end
