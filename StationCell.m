#import "StationCell.h"
#import "Station.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@interface StationCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) CAGradientLayer *cardGradient;
@end

@implementation StationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.cardView = [[UIView alloc] initWithFrame:CGRectZero];
        self.cardView.backgroundColor = [UIColor clearColor];
        self.cardView.layer.cornerRadius = 7.0;
        self.cardView.layer.borderWidth = 1.0;
        self.cardView.layer.borderColor = [[UIColor colorWithRed:0.52 green:0.39 blue:0.20 alpha:0.65] CGColor];
        self.cardView.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.cardView.layer.shadowOpacity = 0.45;
        self.cardView.layer.shadowRadius = 3.0;
        self.cardView.layer.shadowOffset = CGSizeMake(0, 2);
        self.backgroundView = self.cardView;

        self.cardGradient = [CAGradientLayer layer];
        self.cardGradient.colors = [NSArray arrayWithObjects:
            (id)[UIColor colorWithRed:0.21 green:0.14 blue:0.085 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.14 green:0.095 blue:0.058 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:0.085 green:0.055 blue:0.032 alpha:1.0].CGColor, nil];
        self.cardGradient.locations = [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:0.0],
            [NSNumber numberWithFloat:0.55],
            [NSNumber numberWithFloat:1.0], nil];
        self.cardGradient.startPoint = CGPointMake(0.5, 0.0);
        self.cardGradient.endPoint = CGPointMake(0.5, 1.0);
        self.cardGradient.cornerRadius = 7.0;
        [self.cardView.layer insertSublayer:self.cardGradient atIndex:0];

        UIView *selected = [[UIView alloc] initWithFrame:CGRectZero];
        selected.backgroundColor = [UIColor colorWithRed:0.24 green:0.16 blue:0.09 alpha:0.85];
        selected.layer.cornerRadius = 7.0;
        self.selectedBackgroundView = selected;

        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 48, 48)];
        self.logoView.contentMode = UIViewContentModeScaleAspectFill;
        self.logoView.clipsToBounds = YES;
        self.logoView.layer.cornerRadius = 5.0;
        self.logoView.layer.borderWidth = 1.0;
        self.logoView.layer.borderColor = [[UIColor colorWithRed:0.55 green:0.42 blue:0.22 alpha:0.8] CGColor];
        self.logoView.backgroundColor = [UIColor colorWithRed:0.74 green:0.64 blue:0.48 alpha:1.0];
        [self.contentView addSubview:self.logoView];

        self.placeholderLabel = [[UILabel alloc] initWithFrame:self.logoView.bounds];
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        self.placeholderLabel.textColor = [Theme brown];
        self.placeholderLabel.font = [Theme displayFontOfSize:22];
        [self.logoView addSubview:self.placeholderLabel];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 11, 220, 22)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [Theme cream];
        self.nameLabel.font = [Theme boldTextFontOfSize:16];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.nameLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.nameLabel.layer.shadowOpacity = 0.65;
        self.nameLabel.layer.shadowRadius = 1.0;
        self.nameLabel.layer.shadowOffset = CGSizeMake(0, 1);
        [self.contentView addSubview:self.nameLabel];

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 33, 220, 18)];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.textColor = [UIColor colorWithRed:0.66 green:0.55 blue:0.38 alpha:1.0];
        self.detailLabel.font = [Theme textFontOfSize:12];
        self.detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.detailLabel];

        self.nowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52, 18)];
        self.nowLabel.backgroundColor = [UIColor colorWithRed:0.55 green:0.31 blue:0.09 alpha:1.0];
        self.nowLabel.textColor = [UIColor colorWithRed:0.96 green:0.84 blue:0.62 alpha:1.0];
        self.nowLabel.font = [Theme boldTextFontOfSize:10];
        self.nowLabel.textAlignment = NSTextAlignmentCenter;
        self.nowLabel.text = @"直播中";
        self.nowLabel.hidden = YES;
        self.nowLabel.layer.cornerRadius = 3.0;
        self.nowLabel.layer.borderWidth = 0.5;
        self.nowLabel.layer.borderColor = [[UIColor colorWithRed:0.78 green:0.62 blue:0.32 alpha:0.8] CGColor];
        self.nowLabel.clipsToBounds = YES;
        [self.contentView addSubview:self.nowLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect cardFrame = CGRectInset(self.bounds, 6.0, 4.0);
    self.backgroundView.frame = cardFrame;
    self.selectedBackgroundView.frame = cardFrame;
    self.cardGradient.frame = self.cardView.bounds;
    CGFloat width = self.contentView.bounds.size.width;
    self.nameLabel.frame = CGRectMake(72, 10, width - 146, 22);
    self.detailLabel.frame = CGRectMake(72, 32, width - 146, 18);
    self.nowLabel.frame = CGRectMake(width - 62, 21, 50, 18);
}

- (void)setStation:(Station *)station nowPlaying:(BOOL)nowPlaying {
    self.nameLabel.text = station.name;
    NSString *genre = station.genre ? station.genre : @"网络电台";
    NSString *frequency = station.frequency ? station.frequency : @"在线直播";
    self.detailLabel.text = [NSString stringWithFormat:@"%@ · %@", genre, frequency];
    self.nowLabel.hidden = !nowPlaying;
    self.nameLabel.textColor = nowPlaying ? [Theme ledAmber] : [Theme cream];

    UIImage *image = [station logoImage];
    self.logoView.image = image;
    if (image) {
        self.placeholderLabel.hidden = YES;
    } else {
        self.placeholderLabel.hidden = NO;
        self.placeholderLabel.text = station.name.length > 0 ? [station.name substringToIndex:1] : @"?";
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.logoView.image = nil;
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"";
    self.nowLabel.hidden = YES;
}

@end
