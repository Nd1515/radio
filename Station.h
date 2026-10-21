#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Station : NSObject

@property (nonatomic, copy) NSString *stationID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, copy) NSString *frequency;
@property (nonatomic, copy) NSString *streamURL;
@property (nonatomic, copy) NSString *logoName;
@property (nonatomic, assign) BOOL customStation;

+ (Station *)stationWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;
- (UIImage *)logoImage;

@end
