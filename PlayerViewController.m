#import "PlayerViewController.h"
#import "RadioPlayer.h"
#import "Station.h"
#import "TransportButton.h"
#import "Theme.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@interface VUMeterView : UIView
@property (nonatomic, assign) BOOL active;
@end

@implementation VUMeterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setActive:(BOOL)active {
    _active = active;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    UIBezierPath *panel = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(bounds, 1.0, 1.0) cornerRadius:4.0];
    [[UIColor colorWithRed:0.08 green:0.06 blue:0.04 alpha:0.96] setFill];
    [panel fill];
    [[Theme brass] setStroke];
    panel.lineWidth = 1.0;
    [panel stroke];

    [[Theme brass] setFill];
    [@"SIGNAL" drawInRect:CGRectMake(9, 5, 42, 10)
                withFont:[Theme boldTextFontOfSize:7]
           lineBreakMode:NSLineBreakByClipping
               alignment:NSTextAlignmentLeft];

    NSInteger segments = 14;
    CGFloat startX = 54.0;
    CGFloat segmentWidth = 9.0;
    CGFloat gap = 3.0;
    for (NSInteger row = 0; row < 2; row++) {
        for (NSInteger i = 0; i < segments; i++) {
            BOOL lit = self.active && i < (row == 0 ? 10 : 7);
            UIColor *color = lit ? [Theme ledAmber] : [UIColor colorWithRed:0.20 green:0.15 blue:0.09 alpha:1.0];
            CGRect segment = CGRectMake(startX + i * (segmentWidth + gap),
                                        8.0 + row * 12.0,
                                        segmentWidth, 8.0);
            [color setFill];
            [[UIBezierPath bezierPathWithRoundedRect:segment cornerRadius:2.0] fill];
        }
    }
    [[Theme muted] setFill];
    [@"L" drawInRect:CGRectMake(40, 7, 10, 10) withFont:[Theme boldTextFontOfSize:7] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    [@"R" drawInRect:CGRectMake(40, 19, 10, 10) withFont:[Theme boldTextFontOfSize:7] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}

@end


@interface SkipButton : UIButton
@property (nonatomic, assign) BOOL pointsLeft;
@end

@implementation SkipButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)setPointsLeft:(BOOL)pointsLeft {
    _pointsLeft = pointsLeft;
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.72 : 1.0;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect bounds = CGRectInset(self.bounds, 2.0, 2.0);
    CGFloat size = MIN(bounds.size.width, bounds.size.height);
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2.5), 3.0,
                                [UIColor colorWithWhite:0.0 alpha:0.65].CGColor);
    CGFloat outer[12] = {0.42, 0.31, 0.16, 1.0,
                         0.25, 0.18, 0.09, 1.0,
                         0.10, 0.07, 0.04, 1.0};
    CGFloat locations[3] = {0.0, 0.65, 1.0};
    CGGradientRef outerGradient = CGGradientCreateWithColorComponents(
        CGColorSpaceCreateDeviceRGB(), outer, locations, 3);
    CGContextDrawRadialGradient(context, outerGradient, center, 0,
                                center, size / 2.0, 0);
    CGGradientRelease(outerGradient);
    CGContextRestoreGState(context);

    CGRect innerRect = CGRectInset(bounds, 4.0, 4.0);
    CGFloat inner[12] = {0.23, 0.17, 0.10, 1.0,
                         0.12, 0.09, 0.05, 1.0,
                         0.055, 0.042, 0.028, 1.0};
    CGGradientRef innerGradient = CGGradientCreateWithColorComponents(
        CGColorSpaceCreateDeviceRGB(), inner, locations, 3);
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, innerRect);
    CGContextClip(context);
    CGContextDrawRadialGradient(context, innerGradient,
                                CGPointMake(CGRectGetMidX(innerRect), CGRectGetMidY(innerRect)),
                                0, center, size / 2.0, 0);
    CGGradientRelease(innerGradient);
    CGContextRestoreGState(context);

    UIColor *brass = [UIColor colorWithRed:0.74 green:0.57 blue:0.28 alpha:1.0];
    CGContextSetStrokeColorWithColor(context, brass.CGColor);
    CGContextSetLineWidth(context, 1.6);
    CGContextStrokeEllipseInRect(context, bounds);

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.16].CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextStrokeEllipseInRect(context, CGRectInset(bounds, 2.0, 2.0));

    CGFloat gap = size * 0.115;
    CGFloat halfHeight = size * 0.17;
    CGFloat chevronWidth = size * 0.145;
    CGFloat startX = center.x + (self.pointsLeft ? gap : -gap);
    for (NSInteger i = 0; i < 2; i++) {
        CGFloat x = startX + (self.pointsLeft ? -i * gap : i * gap);
        UIBezierPath *path = [UIBezierPath bezierPath];
        if (self.pointsLeft) {
            [path moveToPoint:CGPointMake(x, center.y - halfHeight)];
            [path addLineToPoint:CGPointMake(x - chevronWidth, center.y)];
            [path addLineToPoint:CGPointMake(x, center.y + halfHeight)];
        } else {
            [path moveToPoint:CGPointMake(x, center.y - halfHeight)];
            [path addLineToPoint:CGPointMake(x + chevronWidth, center.y)];
            [path addLineToPoint:CGPointMake(x, center.y + halfHeight)];
        }
        path.lineWidth = size * 0.065;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;

        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 1.5), 1.5,
                                    [UIColor colorWithWhite:0.0 alpha:0.8].CGColor);
        [[UIColor colorWithRed:0.28 green:0.19 blue:0.09 alpha:1.0] setStroke];
        [path stroke];
        CGContextRestoreGState(context);

        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0, -1.0);
        [[UIColor colorWithRed:1.0 green:0.92 blue:0.74 alpha:0.55] setStroke];
        path.lineWidth = size * 0.028;
        [path stroke];
        CGContextRestoreGState(context);

        [brass setStroke];
        path.lineWidth = size * 0.055;
        [path stroke];
    }

    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.22].CGColor);
    CGContextSetLineWidth(context, 1.2);
    CGContextAddArc(context, center.x, center.y, size * 0.32,
                    (CGFloat)-M_PI * 0.85, (CGFloat)-M_PI * 0.18, 0);
    CGContextStrokePath(context);
}

@end

@interface PlayerViewController ()
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIView *bezelView;
@property (nonatomic, strong) UIView *displayPanel;
@property (nonatomic, strong) UILabel *brandLabel;
@property (nonatomic, strong) VUMeterView *meterView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *genreLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) TransportButton *transportButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UILabel *hintLabel;
@end

@implementation PlayerViewController

- (UIView *)makeScrew {
    UIView *screw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    screw.backgroundColor = [Theme brass];
    screw.layer.cornerRadius = 3.0;
    screw.layer.borderWidth = 0.5;
    screw.layer.borderColor = [[UIColor colorWithRed:0.25 green:0.17 blue:0.08 alpha:1.0] CGColor];
    return screw;
}

- (UIButton *)makeSkipButtonWithTitle:(NSString *)title action:(SEL)action {
    SkipButton *button = [SkipButton buttonWithType:UIButtonTypeCustom];
    button.pointsLeft = [title hasPrefix:@"◀"];
    button.accessibilityLabel = button.pointsLeft ? @"上一台" : @"下一台";
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)previousTapped:(id)sender {
    [[RadioPlayer sharedPlayer] playPreviousStation];
}

- (void)nextTapped:(id)sender {
    [[RadioPlayer sharedPlayer] playNextStation];
}

- (void)swipeStationLeft:(UISwipeGestureRecognizer *)gesture {
    [[RadioPlayer sharedPlayer] playNextStation];
}

- (void)swipeStationRight:(UISwipeGestureRecognizer *)gesture {
    [[RadioPlayer sharedPlayer] playPreviousStation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"正在播放";
    self.view.backgroundColor = [Theme darkBackground];
    [Theme styleNavigationBar:self.navigationController.navigationBar];

    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    background.backgroundColor = [UIColor colorWithPatternImage:[Theme leatherTexture]];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:background];
    UIView *shade = [[UIView alloc] initWithFrame:self.view.bounds];
    shade.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.18];
    shade.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:shade];

    self.brandLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.brandLabel.backgroundColor = [UIColor clearColor];
    self.brandLabel.text = @"O L D   R A D I O";
    self.brandLabel.textColor = [Theme brass];
    self.brandLabel.font = [Theme displayFontOfSize:10];
    self.brandLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.brandLabel];

    self.meterView = [[VUMeterView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.meterView];

    self.bezelView = [[UIView alloc] initWithFrame:CGRectZero];
    self.bezelView.backgroundColor = [UIColor colorWithPatternImage:[Theme metalTexture]];
    self.bezelView.layer.cornerRadius = 10.0;
    self.bezelView.layer.borderWidth = 2.0;
    self.bezelView.layer.borderColor = [[Theme brass] CGColor];
    self.bezelView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.bezelView.layer.shadowOpacity = 0.65;
    self.bezelView.layer.shadowRadius = 8.0;
    self.bezelView.layer.shadowOffset = CGSizeMake(0, 5);
    [self.view addSubview:self.bezelView];

    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.logoView.contentMode = UIViewContentModeScaleAspectFill;
    self.logoView.clipsToBounds = YES;
    self.logoView.layer.cornerRadius = 6.0;
    self.logoView.layer.borderColor = [[UIColor colorWithRed:0.18 green:0.12 blue:0.06 alpha:1.0] CGColor];
    self.logoView.layer.borderWidth = 1.0;
    self.logoView.backgroundColor = [UIColor colorWithRed:0.18 green:0.13 blue:0.08 alpha:1.0];
    [self.bezelView addSubview:self.logoView];

    for (NSInteger i = 0; i < 4; i++) {
        UIView *screw = [self makeScrew];
        screw.tag = 900 + i;
        [self.bezelView addSubview:screw];
    }

    self.displayPanel = [[UIView alloc] initWithFrame:CGRectZero];
    self.displayPanel.backgroundColor = [UIColor colorWithRed:0.075 green:0.058 blue:0.040 alpha:0.97];
    self.displayPanel.layer.cornerRadius = 5.0;
    self.displayPanel.layer.borderWidth = 1.0;
    self.displayPanel.layer.borderColor = [[Theme brass] CGColor];
    self.displayPanel.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.displayPanel.layer.shadowOpacity = 0.5;
    self.displayPanel.layer.shadowRadius = 3.0;
    self.displayPanel.layer.shadowOffset = CGSizeMake(0, 2);
    [self.view addSubview:self.displayPanel];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [Theme cream];
    self.nameLabel.font = [Theme displayFontOfSize:21];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.minimumFontSize = 14.0;
    [self.displayPanel addSubview:self.nameLabel];

    self.genreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.genreLabel.backgroundColor = [UIColor clearColor];
    self.genreLabel.textColor = [Theme brass];
    self.genreLabel.font = [Theme textFontOfSize:10];
    self.genreLabel.textAlignment = NSTextAlignmentCenter;
    [self.displayPanel addSubview:self.genreLabel];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textColor = [Theme ledAmber];
    self.statusLabel.font = [Theme boldTextFontOfSize:10];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.displayPanel addSubview:self.statusLabel];

    self.transportButton = [[TransportButton alloc] initWithFrame:CGRectZero];
    self.transportButton.drawsCircle = YES;
    self.transportButton.circleColor = [Theme brass];
    self.transportButton.symbolColor = [Theme darkBackground];
    [self.transportButton addTarget:self action:@selector(transportTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.transportButton];

    self.previousButton = [self makeSkipButtonWithTitle:@"◀◀" action:@selector(previousTapped:)];
    self.nextButton = [self makeSkipButtonWithTitle:@"▶▶" action:@selector(nextTapped:)];

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeStationLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.bezelView addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeStationRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.bezelView addGestureRecognizer:swipeRight];

    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    self.volumeView.showsRouteButton = YES;
    self.volumeView.showsVolumeSlider = YES;
    [self.view addSubview:self.volumeView];

    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.hintLabel.backgroundColor = [UIColor clearColor];
    self.hintLabel.textColor = [UIColor colorWithRed:0.93 green:0.88 blue:0.78 alpha:0.72];
    self.hintLabel.font = [Theme textFontOfSize:10];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.text = @"锁屏后继续播放 · 在“选择”里管理首页电台";
    [self.view addSubview:self.hintLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerChanged:)
                                                 name:RadioPlayerStateDidChangeNotification
                                               object:nil];
    [self refresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Theme styleNavigationBar:self.navigationController.navigationBar];
    [self refresh];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat bezelSize = height < 460.0 ? 128.0 : 148.0;
    CGFloat bezelY = 56.0;

    self.brandLabel.frame = CGRectMake(16, 5, width - 32, 16);
    self.meterView.frame = CGRectMake((width - 230.0) / 2.0, 23.0, 230.0, 32.0);
    self.bezelView.frame = CGRectMake((width - bezelSize) / 2.0, bezelY, bezelSize, bezelSize);
    self.logoView.frame = CGRectMake(9.0, 9.0, bezelSize - 18.0, bezelSize - 18.0);

    NSArray *screwFrames = [NSArray arrayWithObjects:
                            [NSValue valueWithCGRect:CGRectMake(5, 5, 6, 6)],
                            [NSValue valueWithCGRect:CGRectMake(bezelSize - 11, 5, 6, 6)],
                            [NSValue valueWithCGRect:CGRectMake(5, bezelSize - 11, 6, 6)],
                            [NSValue valueWithCGRect:CGRectMake(bezelSize - 11, bezelSize - 11, 6, 6)], nil];
    for (NSInteger i = 0; i < 4; i++) {
        UIView *screw = [self.bezelView viewWithTag:900 + i];
        screw.frame = [[screwFrames objectAtIndex:i] CGRectValue];
    }

    CGFloat displayY = bezelY + bezelSize + 8.0;
    self.displayPanel.frame = CGRectMake(24.0, displayY, width - 48.0, 82.0);
    self.nameLabel.frame = CGRectMake(8, 8, width - 64.0, 30.0);
    self.genreLabel.frame = CGRectMake(8, 40, width - 64.0, 16.0);
    self.statusLabel.frame = CGRectMake(8, 58, width - 64.0, 16.0);

    CGFloat buttonSize = height < 460.0 ? 64.0 : 74.0;
    CGFloat buttonY = displayY + 82.0 + 7.0;
    CGFloat centerX = width / 2.0;
    self.transportButton.frame = CGRectMake(centerX - buttonSize / 2.0, buttonY, buttonSize, buttonSize);
    CGFloat skipY = buttonY + (buttonSize - 50.0) / 2.0;
    self.previousButton.frame = CGRectMake(centerX - buttonSize / 2.0 - 78.0, skipY, 50.0, 50.0);
    self.nextButton.frame = CGRectMake(centerX + buttonSize / 2.0 + 28.0, skipY, 50.0, 50.0);
    CGFloat volumeY = height - 58.0;
    self.volumeView.frame = CGRectMake((width - 250.0) / 2.0, volumeY, 250.0, 28.0);
    self.hintLabel.frame = CGRectMake(16.0, height - 25.0, width - 32.0, 16.0);
}

- (void)refresh {
    RadioPlayer *player = [RadioPlayer sharedPlayer];
    Station *station = player.currentStation;
    if (!station) {
        self.nameLabel.text = @"没有正在播放的电台";
        self.genreLabel.text = @"";
        self.statusLabel.text = @"返回列表选择";
        self.transportButton.hidden = YES;
        self.previousButton.hidden = YES;
        self.nextButton.hidden = YES;
        self.logoView.image = nil;
        self.meterView.active = NO;
        return;
    }
    self.transportButton.hidden = NO;
    self.previousButton.hidden = NO;
    self.nextButton.hidden = NO;
    self.nameLabel.text = station.name;
    self.genreLabel.text = [NSString stringWithFormat:@"%@ · %@", station.genre ? station.genre : @"网络电台", station.frequency ? station.frequency : @"在线直播"];
    self.logoView.image = [station logoImage];

    NSString *status = @"已暂停";
    switch (player.state) {
        case RadioPlayerStateConnecting:
            status = @"正在连接…";
            break;
        case RadioPlayerStatePlaying:
            status = @"正在播放";
            break;
        case RadioPlayerStatePaused:
            status = @"已暂停";
            break;
        case RadioPlayerStateFailed:
            status = player.errorMessage ? player.errorMessage : @"连接失败";
            break;
        default:
            status = @"已停止";
            break;
    }
    self.statusLabel.text = status;
    self.meterView.active = (player.state == RadioPlayerStatePlaying || player.state == RadioPlayerStateConnecting);
    self.transportButton.showsPause = self.meterView.active;
}

- (void)playerChanged:(NSNotification *)notification {
    [self refresh];
}

- (void)transportTapped:(id)sender {
    RadioPlayer *player = [RadioPlayer sharedPlayer];
    if (player.state == RadioPlayerStateFailed) {
        [player retry];
    } else {
        [player togglePlayPause];
    }
}

@end

