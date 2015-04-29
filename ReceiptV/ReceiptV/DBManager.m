//
//  DBManager.m
//  ReceiptV
//
//  Created by letian xu on 2015-03-19.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import "DBManager.h"
#import <objc/runtime.h>

@interface DBManager() {
    FMDatabase* _dataBase;
    NSMutableArray *_columnNames;
    NSMutableArray *_shopItems;
}
@end

@implementation DBManager

+ (DBManager*)sharedInstance
{
    static DBManager *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DBManager alloc] initDataBaseWithFilename:@"ReceiptV"];
    });
    return _sharedInstance;
}

- (instancetype)initDataBaseWithFilename:(NSString*)fileName
{
    self = [super init];
    if (self)
    {
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath   = [docsPath stringByAppendingPathComponent:fileName];
        _dataBase          = [FMDatabase databaseWithPath:dbPath];
        if (![_dataBase open])
        {
            NSLog(@"Database %@ can't be opened, there is no further actions on manager!", fileName);
            return nil;
        }
        
        _shopItems = [NSMutableArray arrayWithCapacity:0];
        _columnNames = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (BOOL) createTableWithName:(NSString*)tableName primaryKey:(NSString*)key shopItemClass:(Class)shopItemClass
{
    NSMutableString* createTableString = [[NSMutableString alloc] initWithFormat:@"create table %@ (", tableName];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(shopItemClass, &outCount);
    if (outCount == 0) return NO;
    for (i = 0; i < outCount; i++) {
        if (i > 0)
        {
            [createTableString appendString:@", "];
        }
        objc_property_t property = properties[i];
        const char* propName = property_getName(property);
        const char* propAttr = property_getAttributes(property);
        if (propAttr[1] == 'f')
        {
            [createTableString appendFormat:@"%s %s", propName, "real"];
        }
        else if ((propAttr[1] == 'c' || propAttr[2] == 'c') ||
                 strstr(propAttr, "NSString"))
        {
            [createTableString appendFormat:@"%s %s", propName, "text"];
        }
        else
        {
            [createTableString appendFormat:@"%s", propName];
        }
        [_columnNames addObject:[NSString stringWithUTF8String:propName]];
        NSLog(@"%s %s\n", property_getName(property), property_getAttributes(property));
    }
    [createTableString appendString:@")"];
    NSLog(@"create table sql string: %@\n", createTableString);

    return [_dataBase executeUpdate:createTableString];
}
//BUG for reentering
- (BOOL) isTableExisting:(NSString*)tableName
{
    NSString *checkTableExistingStr = [NSString stringWithFormat:@"pragma table_info('%@')", tableName];
    FMResultSet *rs = [_dataBase executeQuery:checkTableExistingStr];
    if (rs)
    {
        while ([rs next])
        {
            // add each column name to array for dynamically composing sql string
            NSString *columnName = [rs stringForColumn:@"name"];
            [_columnNames addObject:columnName];
        }
        [rs close];
        return YES;
    }
    return NO;
}

//BUG order of column name and class variable name
- (BOOL) addShopItemToTable:(NSString*)tableName item:(ShopItem *)item
{
    NSMutableString* addItemString = [[NSMutableString alloc] initWithFormat:@"insert into %@ (", tableName];
    unsigned int i = 0;
    for (NSString* name in _columnNames)
    {
        if (i > 0)
        {
            [addItemString appendString:@", "];
        }
        [addItemString appendFormat:@"%@", name];
        i++;
    }
    [addItemString appendString:@") values ("];
    
    Class shoptItemClass = object_getClass(item);
    unsigned int outCount;
    Ivar* vars = class_copyIvarList(shoptItemClass, &outCount);
    for (i = 0; i < outCount; i++)
    {
        if (i > 0)
        {
            [addItemString appendString:@", "];
        }
        const char* type = ivar_getTypeEncoding(vars[i]);
        if (type[0] == '*' || type[1] == '*')
        {
            [addItemString appendFormat:@"'%@'", [item valueForKey:_columnNames[i]]];
        }
        else if (type[0] == 'f' || type[1] == 'f')
        {
            [addItemString appendFormat:@"%f", [[item valueForKey:_columnNames[i]] doubleValue]];
        }
        else
        {
            [addItemString appendFormat:@"%@", [item valueForKey:_columnNames[i]]];
        }
    }
    [addItemString appendString:@")"];
    NSLog(@"add item sql string: %@\n", addItemString);

    return [_dataBase executeUpdate:addItemString];
}

- (NSMutableArray *)getShoptItems:(NSString*)tableName
{
    return _shopItems;
}



@end
