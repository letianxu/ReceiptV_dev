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
                            @[[UIImage imageNamed:@"2"],
                              [UIImage imageNamed:@"1"],
                              [UIImage imageNamed:@"4"]]
                                                       sectionSelectedImages:
                            @[[UIImage imageNamed:@"2-selected"],
                              [UIImage imageNamed:@"1-selected"],
                              [UIImage imageNamed:@"4-selected"]]];
        
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
        case 0:
        {
            FRCImagePickerController *picker = [[FRCImagePickerController alloc] init];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:^{}];
        }
        break;
        default:
        break;
    }
}

#pragma mark -
#pragma UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /*[self dismissViewControllerAnimated:NO completion:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
            if (_frameImage) {
                CGSize size = [image size];
                UIGraphicsBeginImageContext(size);
                CGRect rect;
                rect.origin = CGPointZero;
                rect.size = size;
                
                [image drawInRect:rect];
                [_frameImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
                
                //add current date
                //TODO I should set the position of date dynamically
                if ([FRCSettingHelper showDate]) {
                    NSDateFormatter *dtf = [[NSDateFormatter alloc] init];
                    [dtf setDateFormat:@"yyyy/MM/dd"];
                    int y = 72;
                    int fontSize = 96;
                    if (rect.size.width > 1936) {
                        y = 100;
                        fontSize = 110;
                    }
                    NSString *dateStr = [dtf stringFromDate:[NSDate date]];
                    CGRect dateRect = CGRectMake(rect.size.width * 0.69, y, rect.size.width, rect.size.height);
                    [dateStr drawInRect:dateRect
                         withAttributes:@{
                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
                                          NSForegroundColorAttributeName: [UIColor whiteColor]
                                          }];
                }
                if ([FRCSettingHelper showQR]) {
                    //add QR code of Image URL
                    //TODO make URL
                    NSString *imageUrl = @"http://gif.r4d-inc.net/uploads/09B8F947-8E8D-4A1E-B284-F76BAF18F160.gif";
                    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_AUTO version:QR_VERSION_AUTO string:imageUrl];
                    int qrDimention = 640;
                    UIImage *qrImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:qrDimention];
                    //At first, draw white background and then draw QR code
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextFillRect(context, CGRectMake(image.size.width - qrDimention - 140.0f,
                                                          image.size.height - qrDimention - 140.0f,
                                                          qrDimention + 80.0f,
                                                          qrDimention + 80.0f));
                    [qrImage drawAtPoint:CGPointMake(
                                                     image.size.width - qrDimention - 100.0f,
                                                     image.size.height - qrDimention - 100.0f
                                                     )];
                }
                
                UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                image = mergedImage;
            }
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library writeImageToSavedPhotosAlbum:image.CGImage
                                      orientation:(ALAssetOrientation)image.imageOrientation
                                  completionBlock:^(NSURL *assetURL, NSError *error) {
                                      if (error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"failed_to_save_images", nil)
                                                                          message:NSLocalizedString(@"please_retake_a_picture", nil)
                                                                         delegate:self
                                                                cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                                                otherButtonTitles:NSLocalizedString(@"ok", nil), nil
                                                ] show];
                                          });
                                      }
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                      });
                                  }];
        });
    }];*/
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark -
#pragma FRCImagePickerViewDelegate
- (void)FRCImagePickerController:(FRCImagePickerController *)controller didFrameImageChanged:(UIImage *)frameImage
{
}

@end
