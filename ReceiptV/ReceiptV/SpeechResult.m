//
//  SpeechResult.m
//  ReceiptV
//
//  Created by letian xu on 2015-04-18.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import "SpeechResult.h"

@implementation SpeechResult

- (instancetype)initWithResult:(NSString*)resultStr
{
    self = [super init];
    if (self)
    {
        _rawResult = [NSString stringWithString:resultStr];
    }
    return self;
}

- (ShopItem*) parseOneShoptItem
{
    ShopItem *item = [[ShopItem alloc] initWithName:_rawResult andPrice:0.0f];
    return item;
}

@end
