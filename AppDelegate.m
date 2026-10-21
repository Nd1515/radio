#import "AppDelegate.h"
#import "StationsViewController.h"
#import "Theme.h"
#import "RadioPlayer.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [Theme cream];

    StationsViewController *stations = [[StationsViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:stations];
    [Theme styleNavigationBar:navigation.navigationBar];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];

    [application beginReceivingRemoteControlEvents];
    return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    [[RadioPlayer sharedPlayer] handleRemoteControlEvent:event];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [application endReceivingRemoteControlEvents];
}

@end

