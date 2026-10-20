#import "Theme.h"

@implementation Theme

+ (UIColor *)cream { return [UIColor colorWithRed:0.949 green:0.914 blue:0.855 alpha:1.0]; }
+ (UIColor *)paper { return [UIColor colorWithRed:1.0 green:0.976 blue:0.933 alpha:1.0]; }
+ (UIColor *)ink { return [UIColor colorWithRed:0.180 green:0.141 blue:0.110 alpha:1.0]; }
+ (UIColor *)brown { return [UIColor colorWithRed:0.290 green:0.216 blue:0.157 alpha:1.0]; }
+ (UIColor *)accent { return [UIColor colorWithRed:0.784 green:0.333 blue:0.169 alpha:1.0]; }
+ (UIColor *)muted { return [UIColor colorWithRed:0.541 green:0.467 blue:0.404 alpha:1.0]; }
+ (UIColor *)darkBackground { return [UIColor colorWithRed:0.118 green:0.094 blue:0.078 alpha:1.0]; }
+ (UIColor *)separator { return [UIColor colorWithRed:0.851 green:0.788 blue:0.702 alpha:1.0]; }

+ (UIFont *)displayFontOfSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"Georgia-Bold" size:size];
    return font ? font : [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)textFontOfSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:size];
    return font ? font : [UIFont systemFontOfSize:size];
}

+ (UIFont *)boldTextFontOfSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    return font ? font : [UIFont boldSystemFontOfSize:size];
}

+ (void)styleNavigationBar:(UINavigationBar *)bar {
    bar.barStyle = UIBarStyleBlack;
    bar.translucent = NO;
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [self cream], UITextAttributeTextColor,
                           [self displayFontOfSize:18], UITextAttributeFont, nil];
    bar.titleTextAttributes = attrs;
}

@end
