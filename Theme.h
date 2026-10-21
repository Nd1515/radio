#import <UIKit/UIKit.h>

@interface Theme : NSObject

+ (UIColor *)cream;
+ (UIColor *)paper;
+ (UIColor *)ink;
+ (UIColor *)brown;
+ (UIColor *)accent;
+ (UIColor *)muted;
+ (UIColor *)darkBackground;
+ (UIColor *)separator;
+ (UIColor *)brass;
+ (UIColor *)ledAmber;
+ (UIColor *)ledRed;
+ (UIColor *)metal;
+ (UIColor *)walnut;

+ (UIFont *)displayFontOfSize:(CGFloat)size;
+ (UIFont *)textFontOfSize:(CGFloat)size;
+ (UIFont *)boldTextFontOfSize:(CGFloat)size;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)woodTexture;
+ (UIImage *)metalTexture;
+ (UIImage *)paperTexture;
+ (UIImage *)leatherTexture;
+ (UIImage *)navigationBarImage;

+ (void)styleNavigationBar:(UINavigationBar *)bar;
+ (void)styleTableView:(UITableView *)tableView;

@end
