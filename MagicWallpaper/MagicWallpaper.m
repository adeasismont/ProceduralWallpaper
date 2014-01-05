#import "MagicWallpaper.h"

@interface MagicWallpaper ()

@property (nonatomic, strong) CAEmitterLayer *emitterLayer;

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
    // Return your wallpaper variants here.
    return @[
             @{ @"kSBUIMagicWallpaperThumbnailNameKey": @"magic-wallpaper1",
                @"info": @"1" },
             @{ @"kSBUIMagicWallpaperThumbnailNameKey": @"magic-wallpaper2",
                @"info": @"2" }
             ];
}

- (void)setWallpaperOptions:(NSDictionary *)options
{
    // Setup the wallpaper based on the options (returned from -presetWallpaperOptions) here.
    // Both variants are the same for this sample wallpaper.
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
    
    self.backgroundColor = [UIColor blackColor];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *uiImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"spark" ofType:@"png"]];
    CGImageRef image = uiImage.CGImage;
    
    // Firework emitter layer
    self.emitterLayer = [CAEmitterLayer layer];
    self.emitterLayer.emitterPosition = CGPointMake(200, 200);
    self.emitterLayer.renderMode = kCAEmitterLayerAdditive;
    self.emitterLayer.birthRate = 0;
    
    // Firework rocket
    CAEmitterCell *firework = [CAEmitterCell emitterCell];
    firework.emissionLongitude = -M_PI / 2;
    firework.emissionLatitude = 0;
    firework.emissionRange = M_PI / 4;
    firework.lifetime = 1.0;
    firework.birthRate = 1;
    firework.velocity = 400;
    firework.velocityRange = 200;
    firework.yAcceleration = -50;
    firework.color = [UIColor grayColor].CGColor;
    firework.redRange = 0.5;
    firework.greenRange = 0.5;
    firework.blueRange = 0.5;
    [firework setName:@"firework"];
    
    // Firework rocket flare
    CAEmitterCell *flare = [CAEmitterCell emitterCell];
    flare.contents = (__bridge id)image;
    flare.emissionLongitude = (4 * M_PI) / 2;
    flare.scale = 0.4;
    flare.velocity = 100;
    flare.birthRate = 45;
    flare.lifetime = 1.5;
    flare.yAcceleration = 350;
    flare.emissionRange = M_PI / 7;
    flare.alphaSpeed = -0.7;
    flare.scaleSpeed = -0.1;
    flare.scaleRange = 0.1;
    flare.beginTime = 0.01;
    flare.duration = 0.7;
    
    // Firework explosion
    CAEmitterCell *explosion = [CAEmitterCell emitterCell];
    explosion.contents = (__bridge id)image;
    explosion.birthRate = 9000;
    explosion.scale = 0.6;
    explosion.velocity = 100;
    explosion.lifetime = 1;
    explosion.alphaSpeed = -0.2;
    explosion.yAcceleration = 50;
    explosion.beginTime = 0.95;
    explosion.duration = 0.1;
    explosion.emissionRange = 2 * M_PI;
    explosion.scaleSpeed = -0.5;
    explosion.spin = 2;
    [explosion setName:@"explosion"];
    
    // Firework hidden spark pre-cell
    CAEmitterCell *preSpark = [CAEmitterCell emitterCell];
    preSpark.birthRate = 80;
    preSpark.velocity = explosion.velocity * 0.7;
    preSpark.lifetime = 1.5;
    preSpark.yAcceleration = -explosion.yAcceleration * 0.55;
    preSpark.beginTime = explosion.beginTime - 0.1;
    preSpark.emissionRange = explosion.emissionRange;
    preSpark.color = [UIColor whiteColor].CGColor;
    preSpark.redSpeed = 100;
    preSpark.greenSpeed = 100;
    preSpark.blueSpeed = 100;
    [preSpark setName:@"preSpark"];
    
    // Firework post-explosion spark§
    CAEmitterCell *spark = [CAEmitterCell emitterCell];
    spark.contents = (__bridge id)image;
    spark.lifetime = 0.05;
    spark.yAcceleration = -250;
    spark.beginTime = 0.7;
    spark.scale = 0.4;
    spark.birthRate = 10;
    
    preSpark.emitterCells = @[ spark ];
    firework.emitterCells = @[ flare, explosion, preSpark ];
    self.emitterLayer.emitterCells = @[ firework ];
    
    [self.layer addSublayer:self.emitterLayer];
    
    return self;
}

- (void)setAnimating:(BOOL)animating
{
    self.emitterLayer.birthRate = (animating ? 1 : 0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.emitterLayer.emitterPosition = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds));
}

@end
