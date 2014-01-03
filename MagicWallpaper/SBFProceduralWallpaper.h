#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SBFProceduralWallpaperDelegate <NSObject>

- (void)wallpaper:(id)wallpaper didComputeAverageColor:(id)averageColor forRect:(CGRect)rect;
- (void)wallpaper:(id)wallpaper didGenerateBlur:(id)blur forRect:(CGRect)rect;

@end

@protocol SBFProceduralWallpaper <NSObject>

@property (assign,nonatomic) id<SBFProceduralWallpaperDelegate> delegate;

@optional
+ (NSArray *)presetWallpaperOptions;
+ (BOOL)colorChangesSignificantly;
- (void)setWallpaperOptions:(NSDictionary *)options;
- (void)setWallpaperVariant:(int)variant;

@required
+ (NSString *)identifier;
- (UIView *)view;
- (void)setAnimating:(BOOL)animating;

@end