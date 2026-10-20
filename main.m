#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RadioApplication.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv,
                                 NSStringFromClass([RadioApplication class]),
                                 NSStringFromClass([AppDelegate class]));
    }
}
