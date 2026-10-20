#import <UIKit/UIKit.h>
#import "RadioPlayer.h"

@class Station;
@class PlayerBarView;

@protocol PlayerBarViewDelegate <NSObject>
- (void)playerBarDidTap:(PlayerBarView *)bar;
- (void)playerBarDidTapPlayButton:(PlayerBarView *)bar;
@end

@interface PlayerBarView : UIView

@property (nonatomic, weak) id<PlayerBarViewDelegate> delegate;

- (void)updateWithStation:(Station *)station state:(RadioPlayerState)state;

@end
