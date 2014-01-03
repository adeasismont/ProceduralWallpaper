#import "MagicWallpaper.h"

@interface MagicWallpaper ()

@end

@implementation MagicWallpaper

#pragma mark - Wallpaper information

@synthesize delegate = _delegate;

+ (NSString *)identifier
{
    return @"MagicWallpaper";
}

+ (BOOL)colorChangesSignificantly
{
    return YES;
}

+ (NSArray *)presetWallpaperOptions
{
    return @[
             @{ @"kSBUIMagicWallpaperThumbnailNameKey": @"magic-wallpaper1",
                @"color": @"red" },
             @{ @"kSBUIMagicWallpaperThumbnailNameKey": @"magic-wallpaper2",
                @"color": @"green" }
             ];
}

- (void)setWallpaperOptions:(NSDictionary *)options
{
    UILabel *label = (UILabel *)[self viewWithTag:2];
    if ([options[@"color"] isEqualToString:@"red"]) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor greenColor];
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.tag = 1;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = @"BBQ";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:50];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:self.bounds];
    label.tag = 2;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = @"BBQ";
    label.textColor = [UIColor redColor];
    label.font = [UIFont boldSystemFontOfSize:50];
    label.textAlignment = NSTextAlignmentCenter;
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    NSArray *motionEffects = @[ xAxis, yAxis ];
    for (UIInterpolatingMotionEffect *effect in motionEffects) {
        effect.maximumRelativeValue = @(100);
        effect.minimumRelativeValue = @(-100);
    }
    
    group.motionEffects = motionEffects;
    [label addMotionEffect:group];
    
    [self addSubview:label];
    
    return self;
}

- (void)setAnimating:(BOOL)animating
{
}

@end
