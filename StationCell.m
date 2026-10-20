#import "StationCell.h"
#import "Station.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@implementation StationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [Theme paper];
        self.contentView.backgroundColor = [Theme paper];
        self.selectionStyle = UITableViewCellSelectionStyleGray;

        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 48, 48)];
        self.logoView.contentMode = UIViewContentModeScaleAspectFill;
        self.logoView.clipsToBounds = YES;
        self.logoView.layer.cornerRadius = 5.0;
        self.logoView.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
        [self.contentView addSubview:self.logoView];

        self.placeholderLabel = [[UILabel alloc] initWithFrame:self.logoView.bounds];
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        self.placeholderLabel.textAlignment = NSTextAlignmentCenter;
        self.placeholderLabel.textColor = [Theme brown];
        self.placeholderLabel.font = [Theme displayFontOfSize:22];
        [self.logoView addSubview:self.placeholderLabel];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 11, 220, 22)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [Theme ink];
        self.nameLabel.font = [Theme boldTextFontOfSize:16];
        self.nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.nameLabel];

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 33, 220, 18)];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.textColor = [Theme muted];
        self.detailLabel.font = [Theme textFontOfSize:12];
        self.detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.detailLabel];

        self.nowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52, 18)];
        self.nowLabel.backgroundColor = [Theme accent];
        self.nowLabel.textColor = [UIColor whiteColor];
        self.nowLabel.font = [Theme boldTextFontOfSize:10];
        self.nowLabel.textAlignment = NSTextAlignmentCenter;
        self.nowLabel.text = @"直播中";
        self.nowLabel.hidden = YES;
        self.nowLabel.layer.cornerRadius = 3.0;
        self.nowLabel.clipsToBounds = YES;
        [self.contentView addSubview:self.nowLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
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

- (void)prepareForReuse {
    [super prepareForReuse];
    self.logoView.image = nil;
    self.placeholderLabel.hidden = NO;
    self.placeholderLabel.text = @"";
    self.nowLabel.hidden = YES;
}

@end
