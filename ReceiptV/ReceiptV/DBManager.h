//
//  DBManager.h
//  ReceiptV
//
//  Created by letian xu on 2015-03-19.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDatabase.h>

@class ShopItem;
@interface DBManager : NSObject

- (instancetype)initDataBaseWithFilename:(NSString*)fileName;

- (BOOL) createTableWithName:(NSString*)tableName primaryKey:(NSString*)key; //TODO input a class and retreive the member name as column name

- (BOOL) addShopItemToTable:(NSString*)tableName item:(ShopItem *)item;

- (BOOL) deleteShoptItemFromTable:(NSString*)tableName item:(ShopItem*)item;

- (BOOL) updateShopItemInTable:(NSString*)tableName item:(ShopItem*)item;

- (NSArray *)getShoptItem;

- (BOOL) close;

@end
