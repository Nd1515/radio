#import <UIKit/UIKit.h>

@class Station;

@interface StationCell : UITableViewCell

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *nowLabel;
@property (nonatomic, strong) UILabel *placeholderLabel;

- (void)setStation:(Station *)station nowPlaying:(BOOL)nowPlaying;

@end
