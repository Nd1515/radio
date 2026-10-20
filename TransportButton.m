#import "TransportButton.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@implementation TransportButton

@synthesize showsPause = _showsPause;
@synthesize drawsCircle = _drawsCircle;
@synthesize symbolColor = _symbolColor;
@synthesize circleColor = _circleColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.symbolColor = [Theme cream];
        self.circleColor = [Theme brass];
        self.drawsCircle = NO;
    }
    return self;
}

- (void)setShowsPause:(BOOL)showsPause {
    _showsPause = showsPause;
    [self setNeedsDisplay];
}

- (void)setDrawsCircle:(BOOL)drawsCircle {
    _drawsCircle = drawsCircle;
    [self setNeedsDisplay];
}

- (void)setSymbolColor:(UIColor *)symbolColor {
    _symbolColor = symbolColor;
    [self setNeedsDisplay];
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.78 : 1.0;
}

- (void)drawSymbolInContext:(CGContextRef)context width:(CGFloat)width height:(CGFloat)height {
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1.0,
                                [[UIColor colorWithWhite:0.0 alpha:0.55] CGColor]);
    CGContextSetFillColorWithColor(context, (self.symbolColor ? self.symbolColor : [Theme cream]).CGColor);
    if (self.showsPause) {
        CGFloat barWidth = width * 0.12;
        CGFloat gap = width * 0.10;
        CGFloat barHeight = height * 0.34;
        CGRect left = CGRectMake(width / 2.0 - gap / 2.0 - barWidth,
                                 (height - barHeight) / 2.0,
                                 barWidth, barHeight);
        CGRect right = CGRectMake(width / 2.0 + gap / 2.0,
                                  (height - barHeight) / 2.0,
                                  barWidth, barHeight);
        [[UIBezierPath bezierPathWithRoundedRect:left cornerRadius:barWidth * 0.35] fill];
        [[UIBezierPath bezierPathWithRoundedRect:right cornerRadius:barWidth * 0.35] fill];
    } else {
        CGFloat size = MIN(width, height) * 0.34;
        CGFloat offset = size * 0.10;
        UIBezierPath *triangle = [UIBezierPath bezierPath];
        [triangle moveToPoint:CGPointMake(width / 2.0 - size * 0.40 + offset, height / 2.0 - size * 0.62)];
        [triangle addLineToPoint:CGPointMake(width / 2.0 - size * 0.40 + offset, height / 2.0 + size * 0.62)];
        [triangle addLineToPoint:CGPointMake(width / 2.0 + size * 0.64 + offset, height / 2.0)];
        [triangle closePath];
        [triangle fill];
    }
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGRect circleRect = CGRectInset(self.bounds, 2.0, 2.0);

    if (self.drawsCircle) {
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 4.0,
                                    [[UIColor colorWithWhite:0.0 alpha:0.55] CGColor]);
        [[UIColor colorWithRed:0.18 green:0.12 blue:0.07 alpha:1.0] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:circleRect] fill];
        CGContextRestoreGState(context);

        CGRect inner = CGRectInset(circleRect, 5.0, 5.0);
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        UIColor *base = self.circleColor ? self.circleColor : [Theme brass];
        CGFloat r, g, b, a;
        [base getRed:&r green:&g blue:&b alpha:&a];
        CGFloat components[] = {
            MIN(1.0, r + 0.28), MIN(1.0, g + 0.25), MIN(1.0, b + 0.18), 1.0,
            r, g, b, 1.0,
            MAX(0.0, r - 0.22), MAX(0.0, g - 0.20), MAX(0.0, b - 0.15), 1.0
        };
        CGFloat locations[] = { 0.0, 0.45, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 3);
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, inner);
        CGContextClip(context);
        CGPoint center = CGPointMake(CGRectGetMidX(inner), CGRectGetMidY(inner) - 3.0);
        CGContextDrawRadialGradient(context, gradient, center, 2.0, center, inner.size.width / 2.0 + 2.0, 0);
        CGContextRestoreGState(context);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(space);

        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, inner);
        CGContextClip(context);
        [[UIColor colorWithWhite:1.0 alpha:0.30] setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(inner.origin.x + 6.0,
                                                           inner.origin.y + 3.0,
                                                           inner.size.width - 12.0,
                                                           inner.size.height * 0.40)] fill];
        CGContextRestoreGState(context);

        [[UIColor colorWithRed:0.28 green:0.19 blue:0.09 alpha:0.85] setStroke];
        UIBezierPath *ring = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(inner, 0.5, 0.5)];
        ring.lineWidth = 1.0;
        [ring stroke];
    }

    [self drawSymbolInContext:context width:width height:height];
}

@end
