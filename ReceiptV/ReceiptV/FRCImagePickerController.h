//
//  FRCImagePickerController.h
//  FrameCamera2
//

#import <UIKit/UIKit.h>

@class FRCImagePickerController;

@protocol FRCImagePickerControllerDelegate
@optional
- (void)FRCImagePickerController:(FRCImagePickerController *)controller didFrameImageChanged:(UIImage *)frameImage;
@end

@interface FRCImagePickerController : UIImagePickerController

@property (nonatomic, assign) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate, FRCImagePickerControllerDelegate>delegate;

@end
