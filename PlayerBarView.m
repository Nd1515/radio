#import "PlayerBarView.h"
#import "Station.h"
#import "TransportButton.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@interface PlayerBarView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) TransportButton *playButton;
@property (nonatomic, strong) UILabel *chevronLabel;
@end

@implementation PlayerBarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[Theme metalTexture]];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 2)];
        topLine.backgroundColor = [Theme brass];
        topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:topLine];

        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.55];
        bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bottomLine];

        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 44, 44)];
        self.logoView.contentMode = UIViewContentModeScaleAspectFill;
        self.logoView.clipsToBounds = YES;
        self.logoView.layer.cornerRadius = 4.0;
        self.logoView.layer.borderWidth = 2.0;
        self.logoView.layer.borderColor = [[Theme brass] CGColor];
        self.logoView.backgroundColor = [UIColor colorWithRed:0.20 green:0.14 blue:0.08 alpha:1.0];
        [self addSubview:self.logoView];

        self.displayView = [[UIView alloc] initWithFrame:CGRectMake(58, 7, frame.size.width - 118, 44)];
        self.displayView.backgroundColor = [UIColor colorWithRed:0.10 green:0.075 blue:0.045 alpha:0.94];
        self.displayView.layer.cornerRadius = 3.0;
        self.displayView.layer.borderWidth = 1.0;
        self.displayView.layer.borderColor = [[UIColor colorWithRed:0.30 green:0.22 blue:0.10 alpha:1.0] CGColor];
        self.displayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.displayView];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, frame.size.width - 138, 20)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [Theme cream];
        self.nameLabel.font = [Theme boldTextFontOfSize:14];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.displayView addSubview:self.nameLabel];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 24, frame.size.width - 138, 15)];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textColor = [Theme ledAmber];
        self.statusLabel.font = [Theme textFontOfSize:10];
        self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.displayView addSubview:self.statusLabel];

        self.playButton = [[TransportButton alloc] initWithFrame:CGRectMake(frame.size.width - 50, 9, 40, 40)];
        self.playButton.symbolColor = [Theme darkBackground];
        self.playButton.circleColor = [Theme brass];
        self.playButton.drawsCircle = YES;
        self.playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.playButton addTarget:self action:@selector(playTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];

        self.chevronLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 14, 14, 12, 28)];
        self.chevronLabel.backgroundColor = [UIColor clearColor];
        self.chevronLabel.text = @"›";
        self.chevronLabel.textColor = [Theme brass];
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
    self.displayView.frame = CGRectMake(58, 7, width - 118, 44);
    self.nameLabel.frame = CGRectMake(8, 5, width - 138, 20);
    self.statusLabel.frame = CGRectMake(8, 24, width - 138, 15);
    self.playButton.frame = CGRectMake(width - 50, 9, 40, 40);
    self.chevronLabel.frame = CGRectMake(width - 14, 14, 12, 28);
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
            color = [Theme ledAmber];
            break;
        case RadioPlayerStatePlaying:
            status = [NSString stringWithFormat:@"正在播放 · %@", station.genre ? station.genre : @"网络电台"];
            color = [Theme ledAmber];
            break;
        case RadioPlayerStatePaused:
            status = @"已暂停";
            color = [Theme cream];
            break;
        case RadioPlayerStateFailed:
            status = @"连接失败，点按重试";
            color = [Theme ledRed];
            break;
        default:
            status = @"已停止";
            color = [Theme cream];
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
