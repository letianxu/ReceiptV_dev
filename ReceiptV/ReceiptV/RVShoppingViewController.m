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

@implementation RVShoppingViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.shoppingControl];
}

- (HMSegmentedControl *)shoppingControl
{
    if (!_shoppingControl)
    {
        _shoppingControl = [[HMSegmentedControl alloc] initWithSectionImages:
                            @[[UIImage imageNamed:@"Speaker"],
                              [UIImage imageNamed:@"Calculator"],
                              [UIImage imageNamed:@"Receipt"]]
                                                       sectionSelectedImages:
                            @[[UIImage imageNamed:@"Speaker"],
                              [UIImage imageNamed:@"Calculator"],
                              [UIImage imageNamed:@"Receipt"]]];
        
        CGFloat viewWidth = CGRectGetWidth(self.view.frame);
        CGFloat viewHeight = CGRectGetHeight(self.view.frame);
        _shoppingControl.frame = CGRectMake(0, 579, viewWidth, viewHeight - 600);
        _shoppingControl.selectionIndicatorHeight = 4.0f;
        _shoppingControl.backgroundColor = [UIColor clearColor];
        _shoppingControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _shoppingControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        [_shoppingControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _shoppingControl;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
    switch (segmentedControl.selectedSegmentIndex)
    {
        case 2:
        {
            CameraViewController *picker = [[CameraViewController alloc] init];
            [self presentViewController:picker animated:YES completion:^{}];
        }
        break;
        default:
        break;
    }
}

@end
