#import "TransportButton.h"

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
        self.symbolColor = [UIColor whiteColor];
        self.circleColor = [UIColor clearColor];
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
    self.alpha = highlighted ? 0.55 : 1.0;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    if (self.drawsCircle && self.circleColor) {
        CGContextSetFillColorWithColor(context, self.circleColor.CGColor);
        CGContextFillEllipseInRect(context, self.bounds);
    }

    CGContextSetFillColorWithColor(context, (self.symbolColor ? self.symbolColor : [UIColor whiteColor]).CGColor);
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
}

@end
