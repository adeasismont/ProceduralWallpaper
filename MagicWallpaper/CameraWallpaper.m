#import "CameraWallpaper.h"
#import <AVFoundation/AVFoundation.h>

@interface CameraWallpaper () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) BOOL animating;

@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) NSDate *previousCapture;

@end

@implementation CameraWallpaper

#pragma mark - Wallpaper information

@synthesize delegate = _delegate;

+ (NSString *)identifier
{
    return @"CameraWallpaper";
}

+ (BOOL)colorChangesSignificantly
{
    return YES;
}

+ (NSArray *)presetWallpaperOptions
{
    return @[
             @{ @"kSBUIMagicWallpaperThumbnailNameKey": @"camera-wallpaper1",
                @"qr": @(NO) },
             @{ @"kSBUIMagicWallpaperThumbnailNameKey": @"camera-wallpaper2",
                @"qr": @(YES) }
             ];
}

- (void)setWallpaperOptions:(NSDictionary *)options
{
    if ([options[@"qr"] boolValue]) {
        if (self.metadataOutput)
            return;
        self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.captureSession addOutput:self.metadataOutput];
        self.metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeQRCode ];
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    } else {
        if (self.metadataOutput) {
            [self.captureSession removeOutput:self.metadataOutput];
            self.metadataOutput = nil;
        }
    }
}

- (void)setWallpaperVariant:(int)variant
{
}

- (UIView *)view
{
    return self;
}


#pragma mark - Wallpaper implementation

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    [self.captureSession addObserver:self
                          forKeyPath:@"interrupted"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.captureSession addInput:input];
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, 320, 480);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.previewLayer];
    
    return self;
}

- (void)dealloc
{
    [self.captureSession removeObserver:self forKeyPath:@"interrupted"];
}

- (void)setAnimating:(BOOL)animating
{
    _animating = animating;
    
    if (animating) {
        if (self.captureSession.interrupted)
            return;
        [self.captureSession startRunning];
    } else {
        [self.captureSession stopRunning];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != self.captureSession || ![keyPath isEqualToString:@"interrupted"])
        return;
    
    if (!self.captureSession.interrupted && self.animating)
        [self.captureSession startRunning];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.previewLayer.frame = self.view.bounds;
}


#pragma mark - Metadata

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    AVMetadataMachineReadableCodeObject *object = (AVMetadataMachineReadableCodeObject *)[metadataObjects firstObject];
    if (![object isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        return;
    
    // Only capture one object every three seconds
    if (self.previousCapture && fabs([self.previousCapture timeIntervalSinceNow]) < 3.0)
        return;
    
    self.previousCapture = [NSDate date];
    
    NSString *value = object.stringValue;
    
    NSURL *url = [NSURL URLWithString:value];
    if (url) {
        // If it's a URL, ask the user if it should be opened.
        [[[UIAlertView alloc] initWithTitle:@"Open link"
                                    message:value
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Open", nil]
         show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"QR"
                                    message:value
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 1)
        return;
    
    NSURL *url = [NSURL URLWithString:alertView.message];
    [[UIApplication sharedApplication] openURL:url];
}

@end
