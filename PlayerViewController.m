#import "PlayerViewController.h"
#import "RadioPlayer.h"
#import "Station.h"
#import "TransportButton.h"
#import "Theme.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

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
    CGContextRef context = UIGraphicsGetCurrentContext();
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
    self.transportButton.frame = CGRectMake((width - buttonSize) / 2.0,
                                             displayY + 82.0 + 7.0,
                                             buttonSize, buttonSize);
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
        self.logoView.image = nil;
        self.meterView.active = NO;
        return;
    }
    self.transportButton.hidden = NO;
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
