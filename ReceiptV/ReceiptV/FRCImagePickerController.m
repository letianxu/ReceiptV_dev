//
//  FRCImagePickerController.m
//  FrameCamera2
//

#import "FRCImagePickerController.h"

@interface FRCImagePickerController ()

@property UIImage *frameImage;
@property UIView *overlayView;

@end

@implementation FRCImagePickerController

- (id)init
{
    self = [super init];
    if (self) {
        self.allowsEditing = NO;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        self.showsCameraControls = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // set overlay view
    // TODO
    // This frame size is corrent on only iPhone5+ && iOS7
    _overlayView = [[UIView alloc] initWithFrame:CGRectMake(
                        20,
                        0,
                        self.view.bounds.size.width - 40,
                        self.view.bounds.size.height - 100
                        )];
    [_overlayView setBackgroundColor:[UIColor whiteColor]];

    [self updateFrameImages];
    [self setCameraOverlayView:_overlayView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFrameImages
{
    _frameImage = [UIImage imageNamed:@"frame02"];
    [self.delegate FRCImagePickerController:self didFrameImageChanged:_frameImage];
}

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */
@end
