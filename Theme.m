#import "Theme.h"

@implementation Theme

+ (UIColor *)cream { return [UIColor colorWithRed:0.929 green:0.878 blue:0.776 alpha:1.0]; }
+ (UIColor *)paper { return [UIColor colorWithRed:0.973 green:0.933 blue:0.847 alpha:1.0]; }
+ (UIColor *)ink { return [UIColor colorWithRed:0.157 green:0.110 blue:0.071 alpha:1.0]; }
+ (UIColor *)brown { return [UIColor colorWithRed:0.278 green:0.176 blue:0.102 alpha:1.0]; }
+ (UIColor *)accent { return [UIColor colorWithRed:0.847 green:0.416 blue:0.157 alpha:1.0]; }
+ (UIColor *)muted { return [UIColor colorWithRed:0.478 green:0.396 blue:0.310 alpha:1.0]; }
+ (UIColor *)darkBackground { return [UIColor colorWithRed:0.086 green:0.059 blue:0.043 alpha:1.0]; }
+ (UIColor *)separator { return [UIColor colorWithRed:0.318 green:0.235 blue:0.145 alpha:1.0]; }
+ (UIColor *)brass { return [UIColor colorWithRed:0.745 green:0.573 blue:0.294 alpha:1.0]; }
+ (UIColor *)ledAmber { return [UIColor colorWithRed:1.0 green:0.647 blue:0.196 alpha:1.0]; }
+ (UIColor *)ledRed { return [UIColor colorWithRed:0.831 green:0.157 blue:0.118 alpha:1.0]; }
+ (UIColor *)metal { return [UIColor colorWithRed:0.443 green:0.416 blue:0.376 alpha:1.0]; }
+ (UIColor *)walnut { return [UIColor colorWithRed:0.204 green:0.122 blue:0.071 alpha:1.0]; }

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

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)woodTexture {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(96.0, 96.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {
            0.32, 0.20, 0.11, 1.0,
            0.20, 0.12, 0.07, 1.0,
            0.28, 0.17, 0.09, 1.0
        };
        CGFloat locations[] = { 0.0, 0.55, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 3);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(size.width, size.height), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(space);

        for (NSInteger i = 0; i < 90; i++) {
            CGFloat x = (CGFloat)arc4random_uniform((uint32_t)(size.width * 2.0)) / 2.0;
            CGFloat alpha = 0.03 + (CGFloat)arc4random_uniform(60) / 1000.0;
            [[UIColor colorWithRed:0.10 green:0.06 blue:0.035 alpha:alpha] setStroke];
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(x, -4)];
            [path addCurveToPoint:CGPointMake(x + 2.0, size.height + 4)
                    controlPoint1:CGPointMake(x - 3.0, size.height * 0.35)
                    controlPoint2:CGPointMake(x + 4.0, size.height * 0.70)];
            path.lineWidth = 0.6 + (CGFloat)arc4random_uniform(15) / 10.0;
            [path stroke];
        }
        for (NSInteger i = 0; i < 4; i++) {
            CGFloat x = (CGFloat)arc4random_uniform((uint32_t)size.width);
            CGFloat y = (CGFloat)arc4random_uniform((uint32_t)size.height);
            [[UIColor colorWithRed:0.12 green:0.07 blue:0.04 alpha:0.16] setStroke];
            UIBezierPath *knot = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, 8, 3)];
            knot.lineWidth = 1.0;
            [knot stroke];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (UIImage *)metalTexture {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(64.0, 64.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {
            0.60, 0.58, 0.53, 1.0,
            0.38, 0.36, 0.32, 1.0,
            0.52, 0.50, 0.45, 1.0
        };
        CGFloat locations[] = { 0.0, 0.45, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 3);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(space);

        for (NSInteger y = 0; y < (NSInteger)size.height; y++) {
            CGFloat alpha = (y % 3 == 0) ? 0.10 : 0.04;
            [[UIColor colorWithWhite:1.0 alpha:alpha] setStroke];
            UIBezierPath *line = [UIBezierPath bezierPath];
            [line moveToPoint:CGPointMake(0, y + 0.5)];
            [line addLineToPoint:CGPointMake(size.width, y + 0.5)];
            line.lineWidth = 0.5;
            [line stroke];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (UIImage *)paperTexture {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(64.0, 64.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        [[self paper] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (UIImage *)leatherTexture {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(64.0, 64.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        [[UIColor colorWithRed:0.13 green:0.085 blue:0.055 alpha:1.0] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        for (NSInteger i = 0; i < 420; i++) {
            CGFloat x = (CGFloat)arc4random_uniform((uint32_t)size.width);
            CGFloat y = (CGFloat)arc4random_uniform((uint32_t)size.height);
            CGFloat alpha = 0.03 + (CGFloat)arc4random_uniform(35) / 1000.0;
            BOOL light = (arc4random_uniform(2) == 0);
            UIColor *color = light ? [UIColor colorWithRed:0.45 green:0.32 blue:0.20 alpha:alpha]
                                   : [UIColor colorWithRed:0.02 green:0.01 blue:0.0 alpha:alpha];
            [color setFill];
            UIRectFill(CGRectMake(x, y, 1.5, 1.5));
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (UIImage *)navigationBarImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(1.0, 44.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {
            0.27, 0.17, 0.10, 1.0,
            0.10, 0.065, 0.040, 1.0,
            0.19, 0.115, 0.065, 1.0
        };
        CGFloat locations[] = { 0.0, 0.52, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 3);
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, size.height), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(space);

        [[UIColor colorWithWhite:1.0 alpha:0.10] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, 1.0));
        [[self brass] setFill];
        UIRectFill(CGRectMake(0, size.height - 2.0, size.width, 2.0));
        [[UIColor colorWithWhite:0.0 alpha:0.45] setFill];
        UIRectFill(CGRectMake(0, size.height - 1.0, size.width, 1.0));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

+ (void)styleNavigationBar:(UINavigationBar *)bar {
    if (!bar) {
        return;
    }
    bar.barStyle = UIBarStyleBlack;
    bar.translucent = NO;
    bar.tintColor = [self brass];
    [bar setBackgroundImage:[self navigationBarImage] forBarMetrics:UIBarMetricsDefault];
    [bar setShadowImage:[self imageWithColor:[UIColor colorWithRed:0.42 green:0.30 blue:0.14 alpha:1.0]
                                       size:CGSizeMake(1, 1)]];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [self cream], UITextAttributeTextColor,
                           [UIColor colorWithWhite:0.0 alpha:0.75], UITextAttributeTextShadowColor,
                           [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
                           [self displayFontOfSize:18], UITextAttributeFont, nil];
    bar.titleTextAttributes = attrs;

    NSDictionary *buttonAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [self cream], UITextAttributeTextColor,
                                 [self boldTextFontOfSize:13], UITextAttributeFont, nil];
    [[UIBarButtonItem appearance] setTitleTextAttributes:buttonAttrs forState:UIControlStateNormal];
}

+ (void)styleTableView:(UITableView *)tableView {
    tableView.backgroundColor = [UIColor colorWithPatternImage:[self woodTexture]];
    tableView.separatorColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

@end
