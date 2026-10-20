#import <Foundation/Foundation.h>

@class Station;

extern NSString * const StationStoreDidChangeNotification;

@interface StationStore : NSObject

@property (nonatomic, readonly) NSArray *allStations;
@property (nonatomic, readonly) NSArray *selectedStations;
@property (nonatomic, readonly) NSArray *unselectedStations;
@property (nonatomic, readonly) NSArray *defaultSelectedIDs;

+ (StationStore *)sharedStore;

- (BOOL)isSelected:(Station *)station;
- (void)setSelected:(BOOL)selected forStation:(Station *)station;
- (void)moveSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (void)resetSelection;

@end
