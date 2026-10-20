#import "PlayerViewController.h"
#import "RadioPlayer.h"
#import "Station.h"
#import "TransportButton.h"
#import "Theme.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

@interface PlayerGradientView : UIView
@end

@implementation PlayerGradientView
+ (Class)layerClass {
    return [CAGradientLayer class];
}
@end

@interface PlayerViewController ()
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *genreLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) TransportButton *transportButton;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UILabel *hintLabel;
@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"正在播放";
    self.view.backgroundColor = [Theme darkBackground];
    [Theme styleNavigationBar:self.navigationController.navigationBar];

    PlayerGradientView *background = [[PlayerGradientView alloc] initWithFrame:self.view.bounds];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CAGradientLayer *gradient = (CAGradientLayer *)background.layer;
    gradient.colors = [NSArray arrayWithObjects:
                       (__bridge id)[UIColor colorWithRed:0.20 green:0.15 blue:0.12 alpha:1.0].CGColor,
                       (__bridge id)[UIColor colorWithRed:0.075 green:0.060 blue:0.050 alpha:1.0].CGColor,
                       nil];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.5, 1.0);
    [self.view addSubview:background];

    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.logoView.contentMode = UIViewContentModeScaleAspectFill;
    self.logoView.clipsToBounds = YES;
    self.logoView.layer.cornerRadius = 10.0;
    self.logoView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.18].CGColor;
    self.logoView.layer.borderWidth = 1.0;
    self.logoView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    [self.view addSubview:self.logoView];

    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [Theme cream];
    self.nameLabel.font = [Theme displayFontOfSize:28];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.minimumFontSize = 17.0;
    [self.view addSubview:self.nameLabel];

    self.genreLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.genreLabel.backgroundColor = [UIColor clearColor];
    self.genreLabel.textColor = [Theme accent];
    self.genreLabel.font = [Theme textFontOfSize:13];
    self.genreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.genreLabel];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textColor = [Theme muted];
    self.statusLabel.font = [Theme textFontOfSize:13];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];

    self.transportButton = [[TransportButton alloc] initWithFrame:CGRectZero];
    self.transportButton.drawsCircle = YES;
    self.transportButton.circleColor = [Theme accent];
    self.transportButton.symbolColor = [Theme darkBackground];
    [self.transportButton addTarget:self action:@selector(transportTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.transportButton];

    self.volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
    self.volumeView.showsRouteButton = YES;
    self.volumeView.showsVolumeSlider = YES;
    [self.view addSubview:self.volumeView];

    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.hintLabel.backgroundColor = [UIColor clearColor];
    self.hintLabel.textColor = [Theme muted];
    self.hintLabel.font = [Theme textFontOfSize:11];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.text = @"在“选择”里管理首页电台；锁屏后可继续播放";
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
    CGFloat logoSize = height < 460.0 ? 142.0 : 158.0;
    self.logoView.frame = CGRectMake((width - logoSize) / 2.0, 20.0, logoSize, logoSize);
    self.nameLabel.frame = CGRectMake(22.0, 20.0 + logoSize + 8.0, width - 44.0, 36.0);
    self.genreLabel.frame = CGRectMake(22.0, 20.0 + logoSize + 48.0, width - 44.0, 20.0);
    self.statusLabel.frame = CGRectMake(22.0, 20.0 + logoSize + 74.0, width - 44.0, 20.0);
    self.transportButton.frame = CGRectMake((width - 80.0) / 2.0, 20.0 + logoSize + 106.0, 80.0, 80.0);
    CGFloat volumeY = MAX(348.0, height - 96.0);
    self.volumeView.frame = CGRectMake((width - 260.0) / 2.0, volumeY, 260.0, 30.0);
    self.hintLabel.frame = CGRectMake(16.0, height - 30.0, width - 32.0, 18.0);
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
    self.transportButton.showsPause = (player.state == RadioPlayerStatePlaying || player.state == RadioPlayerStateConnecting);
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
