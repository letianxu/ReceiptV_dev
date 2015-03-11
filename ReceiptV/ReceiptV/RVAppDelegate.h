//
//  AppDelegate.h
//  ReceiptV
//
//  Created by letian xu on 2015-03-09.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MSDynamicsDrawerViewController;

@interface RVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

@end

