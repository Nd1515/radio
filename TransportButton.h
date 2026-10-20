#import <UIKit/UIKit.h>

@interface TransportButton : UIButton

@property (nonatomic, assign) BOOL showsPause;
@property (nonatomic, assign) BOOL drawsCircle;
@property (nonatomic, strong) UIColor *symbolColor;
@property (nonatomic, strong) UIColor *circleColor;

@end
