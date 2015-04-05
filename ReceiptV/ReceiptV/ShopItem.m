//
//  ShopItem.m
//  ReceiptV
//
//  Created by letian xu on 2015-03-21.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import "ShopItem.h"

@implementation ShopItem

- (instancetype)initWithName:(NSString*)name andPrice:(float)fPrice
{
    self = [super init];
    if (self)
    {
        self.name = [NSString stringWithString:name];
    }
    return self;
}

@end
