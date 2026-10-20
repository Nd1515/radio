#import "PlayerBarView.h"
#import "Station.h"
#import "TransportButton.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@interface PlayerBarView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) TransportButton *playButton;
@property (nonatomic, strong) UILabel *chevronLabel;
@end

@implementation PlayerBarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.165 green:0.129 blue:0.102 alpha:1.0];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        topLine.backgroundColor = [UIColor colorWithRed:0.50 green:0.40 blue:0.30 alpha:1.0];
        topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:topLine];

        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 40, 40)];
        self.logoView.contentMode = UIViewContentModeScaleAspectFill;
        self.logoView.clipsToBounds = YES;
        self.logoView.layer.cornerRadius = 4.0;
        self.logoView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
        [self addSubview:self.logoView];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 10, frame.size.width - 120, 20)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [Theme cream];
        self.nameLabel.font = [Theme boldTextFontOfSize:14];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.nameLabel];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 30, frame.size.width - 120, 16)];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textColor = [Theme muted];
        self.statusLabel.font = [Theme textFontOfSize:11];
        self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.statusLabel];

        self.playButton = [[TransportButton alloc] initWithFrame:CGRectMake(frame.size.width - 52, 9, 38, 38)];
        self.playButton.symbolColor = [Theme cream];
        self.playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.playButton addTarget:self action:@selector(playTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];

        self.chevronLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 18, 15, 12, 26)];
        self.chevronLabel.backgroundColor = [UIColor clearColor];
        self.chevronLabel.text = @"›";
        self.chevronLabel.textColor = [Theme muted];
        self.chevronLabel.font = [Theme textFontOfSize:24];
        self.chevronLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.chevronLabel];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barTapped:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];

        [self updateWithStation:nil state:RadioPlayerStateIdle];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    self.nameLabel.frame = CGRectMake(62, 9, width - 122, 21);
    self.statusLabel.frame = CGRectMake(62, 29, width - 122, 16);
    self.playButton.frame = CGRectMake(width - 52, 9, 38, 38);
    self.chevronLabel.frame = CGRectMake(width - 18, 14, 12, 28);
}

- (void)updateWithStation:(Station *)station state:(RadioPlayerState)state {
    if (!station) {
        self.logoView.image = nil;
        self.nameLabel.text = @"还没有选择电台";
        self.statusLabel.text = @"点右上角“选择”";
        self.playButton.hidden = YES;
        self.chevronLabel.hidden = YES;
        return;
    }
    self.logoView.image = [station logoImage];
    self.nameLabel.text = station.name;
    self.playButton.hidden = NO;
    self.chevronLabel.hidden = NO;
    self.playButton.showsPause = (state == RadioPlayerStatePlaying || state == RadioPlayerStateConnecting);

    NSString *status = @"已暂停";
    UIColor *color = [Theme muted];
    switch (state) {
        case RadioPlayerStateConnecting:
            status = @"正在连接…";
            color = [Theme accent];
            break;
        case RadioPlayerStatePlaying:
            status = [NSString stringWithFormat:@"正在播放 · %@", station.genre ? station.genre : @"网络电台"];
            color = [Theme accent];
            break;
        case RadioPlayerStatePaused:
            status = @"已暂停";
            color = [Theme muted];
            break;
        case RadioPlayerStateFailed:
            status = @"连接失败，点按重试";
            color = [Theme accent];
            break;
        default:
            status = @"已停止";
            color = [Theme muted];
            break;
    }
    self.statusLabel.text = status;
    self.statusLabel.textColor = color;
}

- (void)playTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(playerBarDidTapPlayButton:)]) {
        [self.delegate playerBarDidTapPlayButton:self];
    }
}

- (void)barTapped:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(playerBarDidTap:)]) {
        [self.delegate playerBarDidTap:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:self.playButton];
}

@end
