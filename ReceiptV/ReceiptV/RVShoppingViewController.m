//
//  MSMapViewController.m
//  Example
//
//  Created by Eric Horacek on 10/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <MapKit/MapKit.h>
#import "CameraViewController.h"
#import "RVShoppingViewController.h"
#import "DBManager.h"

@interface RVShoppingViewController() {
    NSMutableArray *_shopItems;
}
@end

@implementation RVShoppingViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_speakBtn setBackgroundColor:[UIColor whiteColor]];
    [_calculateBtn setBackgroundColor:[UIColor whiteColor]];
    [_cameraBtn setBackgroundColor:[UIColor whiteColor]];
    
    _shopItems = [[DBManager sharedInstance] getShoptItems:@"dummy"];
}

- (IBAction)launchCamera:(id)sender {
    CameraViewController *picker = [[CameraViewController alloc] init];
    [self presentViewController:picker animated:YES completion:^{}];
}

- (IBAction)launchMicToListen:(id)sender {
    NSLog(@"Speak button (via UIControlEventTouchDown)");
    //TODO: lauch microphone to listen the user speech
}

- (IBAction)stopListening:(id)sender {
    NSLog(@"Speak button (via UIControlEventTouchUpInside)");
    static int count = 0;
    //TODO: parse recognized words and add to shopItem list
    [_shopItems addObject:[[ShopItem alloc] initWithName:[NSString stringWithFormat:@"Item %d", count++] andPrice:0]];
}
@end
