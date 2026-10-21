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

+ (UIFont *)displayFontOfSize:(CGFloat)size;
+ (UIFont *)textFontOfSize:(CGFloat)size;
+ (UIFont *)boldTextFontOfSize:(CGFloat)size;
+ (void)styleNavigationBar:(UINavigationBar *)bar;

@end
