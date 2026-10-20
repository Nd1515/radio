#import "RadioApplication.h"
#import "RadioPlayer.h"

@implementation RadioApplication

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    [[RadioPlayer sharedPlayer] handleRemoteControlEvent:event];
}

@end
