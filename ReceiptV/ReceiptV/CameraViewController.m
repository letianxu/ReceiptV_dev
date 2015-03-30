//
//  CameraViewController.m
//  ReceiptV
//
//  Created by letian xu on 2015-03-22.
//  Copyright (c) 2015 skydragon. All rights reserved.
//

#import <LLSimpleCamera.h>
#import "CameraViewController.h"
#import "ViewUtils.h"

@interface CameraViewController ()
@property (strong, nonatomic) LLSimpleCamera *camera;
@property (strong, nonatomic) UIButton *snapButton;
@property (strong, nonatomic) UIButton *backButton;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    NSLog(@"Screen width: %f height: %f", screenRect.size.width, screenRect.size.height);
    
    // ----- initialize camera -------- //
    
    // create camera vc
    self.camera = [[LLSimpleCamera alloc] initWithQuality:CameraQualityPhoto andPosition:CameraPositionBack];
    
    // attach to a view controller
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.camera attachToViewController:self withFrame:CGRectMake(50, statusBarHeight, screenRect.size.width-100, screenRect.size.height-64-statusBarHeight)];
    
    // read: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
    // you probably will want to set this to YES, if you are going view the image outside iOS.
    self.camera.fixOrientationAfterCapture = NO;
    
    /************* camera buttons ***************/
    // snap button to capture image
    UIImage *snapBtnImage = [UIImage imageNamed:@"Camera"];
    self.snapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.snapButton.frame = CGRectMake(0, 0, 64.0f, 64.0f);
    self.snapButton.clipsToBounds = YES;
    //self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    //self.snapButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.snapButton.layer.borderWidth = 2.0f;
    //self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.snapButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.snapButton.layer.shouldRasterize = YES;
    [self.snapButton setImage:snapBtnImage forState:UIControlStateNormal];
    [self.snapButton addTarget:self action:@selector(snapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.snapButton];
    
    // snap button to capture image
    UIImage *backBtnImage = [UIImage imageNamed:@"Back"];
    self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.backButton.frame = CGRectMake(0, 0, 64.0f, 64.0f);
    self.backButton.clipsToBounds = YES;
    //self.snapButton.layer.cornerRadius = self.snapButton.width / 2.0f;
    //self.backButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //self.backButton.layer.borderWidth = 2.0f;
    //self.snapButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.backButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.backButton.layer.shouldRasterize = YES;
    [self.backButton setImage:backBtnImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
}


- (void)snapButtonPressed:(UIButton *)button {
    
    // capture
    [self.camera capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
        if(!error) {
            
            // we should stop the camera, since we don't need it anymore. We will open a new vc.
            // this very important, otherwise you may experience memory crashes
            [camera stop];
            
            NSLog(@"Size: %@  -  Orientation: %d", NSStringFromCGSize(image.size), image.imageOrientation);
        }
        else {
            NSLog(@"An error has occured: %@", error);
        }
    } exactSeenImage:YES];
}

- (void)backButtonPressed:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start the camera
    [self.camera start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // stop the camera
    [self.camera stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* other lifecycle methods */
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.camera.view.frame = self.view.contentBounds;
    
    self.snapButton.center = self.view.contentCenter;
    self.snapButton.bottom = self.view.height;
    
    self.backButton.left = self.view.contentCenter.x - 96;
    self.backButton.bottom = self.view.height;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
