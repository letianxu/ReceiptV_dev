//
//  SpeechResult.h
//  ReceiptV
//
//  Created by letian xu on 2015-04-18.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShopItem.h"

@interface SpeechResult : NSObject

@property (strong, nonatomic) NSString *rawResult;

- (instancetype)initWithResult:(NSString*)resultStr;

- (ShopItem*) parseOneShoptItem;

@end
