#import "StationCell.h"
#import "Station.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@interface StationCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *topHighlight;
@end

@implementation StationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.opaque = NO;

        self.cardView = [[UIView alloc] initWithFrame:CGRectZero];
        self.cardView.backgroundColor = [UIColor colorWithPatternImage:[Theme paperTexture]];
        self.cardView.layer.cornerRadius = 7.0;
        self.cardView.layer.borderWidth = 1.0;
        self.cardView.layer.borderColor = [[UIColor colorWithRed:0.42 green:0.30 blue:0.16 alpha:1.0] CGColor];
        self.cardView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.cardView.layer.shadowOpacity = 0.42;
        self.cardView.layer.shadowRadius = 3.0;
        self.cardView.layer.shadowOffset = CGSizeMake(0, 2);
        self.cardView.clipsToBounds = NO;
        [self.contentView addSubview:self.cardView];

        self.topHighlight = [[UIView alloc] initWithFrame:CGRectZero];
        self.topHighlight.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.42];
        [self.cardView addSubview:self.topHighlight];

        self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.logoView.contentMode = UIViewContentModeScaleAspectFill;
        self.logoView.clipsToBounds = YES;
        self.logoView.layer.cornerRadius = 4.0;
        self.logoView.layer.borderWidth = 2.0;
        self.logoView.layer.borderColor = [[Theme brass] CGColor];
        self.logoView.backgroundColor = [UIColor colorWithRed:0.24 green:0.17 blue:0.10 alpha:1.0];
        self.logoView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.logoView.layer.shadowOpacity = 0.45;
        self.logoView.layer.shadowRadius = 2.0;
        self.logoView.layer.shadowOffset = CGSizeMake(0, 1);
        [self.cardView addSubview:self.logoView];

        self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        self.placeholderLabel.textColor = [Theme cream];
        self.placeholderLabel.font = [Theme displayFontOfSize:22];
        [self.logoView addSubview:self.placeholderLabel];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [Theme ink];
        self.nameLabel.font = [Theme boldTextFontOfSize:16];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
        self.nameLabel.layer.shadowOpacity = 0.55;
        self.nameLabel.layer.shadowRadius = 0;
        self.nameLabel.layer.shadowOffset = CGSizeMake(0, 1);
        [self.cardView addSubview:self.nameLabel];

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.textColor = [Theme muted];
        self.detailLabel.font = [Theme textFontOfSize:12];
        self.detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.cardView addSubview:self.detailLabel];

        self.nowLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nowLabel.backgroundColor = [Theme ledRed];
        self.nowLabel.textColor = [Theme cream];
        self.nowLabel.font = [Theme boldTextFontOfSize:9];
        self.nowLabel.textAlignment = NSTextAlignmentCenter;
        self.nowLabel.text = @"ON AIR";
        self.nowLabel.hidden = YES;
        self.nowLabel.layer.cornerRadius = 2.0;
        self.nowLabel.layer.borderWidth = 1.0;
        self.nowLabel.layer.borderColor = [[UIColor colorWithRed:0.35 green:0.06 blue:0.04 alpha:1.0] CGColor];
        self.nowLabel.layer.shadowColor = [[Theme ledRed] CGColor];
        self.nowLabel.layer.shadowOpacity = 0.8;
        self.nowLabel.layer.shadowRadius = 3.0;
        self.nowLabel.layer.shadowOffset = CGSizeZero;
        self.nowLabel.clipsToBounds = YES;
        [self.cardView addSubview:self.nowLabel];

        for (NSInteger i = 0; i < 2; i++) {
            UIView *screw = [[UIView alloc] initWithFrame:CGRectZero];
            screw.backgroundColor = [Theme brass];
            screw.layer.cornerRadius = 2.0;
            screw.layer.borderWidth = 0.5;
            screw.layer.borderColor = [[UIColor colorWithRed:0.25 green:0.17 blue:0.08 alpha:1.0] CGColor];
            screw.tag = 700 + i;
            [self.cardView addSubview:screw];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    self.cardView.frame = CGRectMake(8.0, 4.0, width - 16.0, height - 8.0);
    self.cardView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardView.bounds cornerRadius:7.0].CGPath;
    self.topHighlight.frame = CGRectMake(8.0, 1.0, self.cardView.bounds.size.width - 16.0, 1.0);

    self.logoView.frame = CGRectMake(10.0, 10.0, 48.0, 48.0);
    self.placeholderLabel.frame = CGRectMake(0, 0, 48.0, 48.0);
    self.nameLabel.frame = CGRectMake(68.0, 11.0, width - 156.0, 22.0);
    self.detailLabel.frame = CGRectMake(68.0, 34.0, width - 156.0, 18.0);
    self.nowLabel.frame = CGRectMake(self.cardView.bounds.size.width - 66.0, 25.0, 52.0, 19.0);

    UIView *leftScrew = [self.cardView viewWithTag:700];
    UIView *rightScrew = [self.cardView viewWithTag:701];
    leftScrew.frame = CGRectMake(5.0, 5.0, 4.0, 4.0);
    rightScrew.frame = CGRectMake(self.cardView.bounds.size.width - 9.0, 5.0, 4.0, 4.0);
}

- (void)setStation:(Station *)station nowPlaying:(BOOL)nowPlaying {
    self.nameLabel.text = station.name;
    NSString *genre = station.genre ? station.genre : @"网络电台";
    NSString *frequency = station.frequency ? station.frequency : @"在线直播";
    self.detailLabel.text = [NSString stringWithFormat:@"%@  ·  %@", genre, frequency];
    self.nowLabel.hidden = !nowPlaying;
    self.nameLabel.textColor = nowPlaying ? [Theme accent] : [Theme ink];

    UIImage *image = [station logoImage];
    self.logoView.image = image;
    if (image) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
        self.placeholderLabel.text = station.name.length > 0 ? [station.name substringToIndex:1] : @"?";
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.cardView.alpha = highlighted ? 0.78 : 1.0;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.logoView.image = nil;
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"";
    self.nowLabel.hidden = YES;
    self.cardView.alpha = 1.0;
}

@end
