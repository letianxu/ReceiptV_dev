//
//  ShopItem.h
//  ReceiptV
//
//  Created by letian xu on 2015-03-21.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopItem : NSObject

@property (assign, nonatomic) float fPrice;
@property (strong, nonatomic) NSString *name;

- (instancetype)initWithName:(NSString*)name andPrice:(float)fPrice;

@end
