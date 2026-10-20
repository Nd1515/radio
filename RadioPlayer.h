#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Station;

typedef enum {
    RadioPlayerStateIdle = 0,
    RadioPlayerStateConnecting,
    RadioPlayerStatePlaying,
    RadioPlayerStatePaused,
    RadioPlayerStateFailed
} RadioPlayerState;

extern NSString * const RadioPlayerStateDidChangeNotification;

@interface RadioPlayer : NSObject

@property (nonatomic, readonly) Station *currentStation;
@property (nonatomic, readonly) RadioPlayerState state;
@property (nonatomic, readonly) NSString *errorMessage;

+ (RadioPlayer *)sharedPlayer;

- (BOOL)isPlaying;
- (void)playStation:(Station *)station;
- (void)togglePlayPause;
- (void)pause;
- (void)resume;
- (void)retry;
- (void)stop;
- (void)handleRemoteControlEvent:(UIEvent *)event;

@end
