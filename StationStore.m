#import "StationStore.h"
#import "Station.h"

NSString * const StationStoreDidChangeNotification = @"StationStoreDidChangeNotification";
static NSString * const kSelectedIDsKey = @"OldRadioSelectedStationIDs";
static NSString * const kCustomStationsKey = @"OldRadioCustomStations";

@interface StationStore ()
@property (nonatomic, strong, readwrite) NSArray *allStations;
@property (nonatomic, strong, readwrite) NSArray *defaultSelectedIDs;
@property (nonatomic, strong) NSMutableArray *selectedIDs;
@property (nonatomic, strong) NSMutableDictionary *stationByID;
- (void)saveCustomStations;
@end

@implementation StationStore

+ (StationStore *)sharedStore {
    static StationStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[StationStore alloc] init];
    });
    return store;
}

- (id)init {
    self = [super init];
    if (self) {
        [self loadStations];
        [self loadSelection];
    }
    return self;
}

- (void)loadStations {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Stations" ofType:@"plist"];
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *rawStations = [root objectForKey:@"Stations"];
    self.defaultSelectedIDs = [root objectForKey:@"DefaultSelected"];
    if (![self.defaultSelectedIDs isKindOfClass:[NSArray class]]) {
        self.defaultSelectedIDs = [NSArray array];
    }

    NSMutableArray *stations = [NSMutableArray array];
    NSMutableDictionary *byID = [NSMutableDictionary dictionary];
    for (NSDictionary *dictionary in rawStations) {
        Station *station = [Station stationWithDictionary:dictionary];
        if (station) {
            [stations addObject:station];
            [byID setObject:station forKey:station.stationID];
        }
    }
    NSArray *customDictionaries = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomStationsKey];
    if ([customDictionaries isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dictionary in customDictionaries) {
            Station *station = [Station stationWithDictionary:dictionary];
            if (station && ![byID objectForKey:station.stationID]) {
                [stations addObject:station];
                [byID setObject:station forKey:station.stationID];
            }
        }
    }
    self.allStations = stations;
    self.stationByID = byID;
}

- (void)loadSelection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *saved = [defaults objectForKey:kSelectedIDsKey];
    NSArray *candidate = nil;
    if ([saved isKindOfClass:[NSArray class]]) {
        candidate = saved;
    } else {
        candidate = self.defaultSelectedIDs;
    }

    NSMutableArray *valid = [NSMutableArray array];
    NSMutableSet *seen = [NSMutableSet set];
    for (id value in candidate) {
        if (![value isKindOfClass:[NSString class]]) {
            continue;
        }
        if ([self.stationByID objectForKey:value] && ![seen containsObject:value]) {
            [valid addObject:value];
            [seen addObject:value];
        }
    }
    self.selectedIDs = valid;
    if (saved == nil) {
        [self saveSelection];
    }
}

- (NSArray *)selectedStations {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *stationID in self.selectedIDs) {
        Station *station = [self.stationByID objectForKey:stationID];
        if (station) {
            [result addObject:station];
        }
    }
    return result;
}

- (NSArray *)unselectedStations {
    NSMutableArray *result = [NSMutableArray array];
    NSSet *selectedSet = [NSSet setWithArray:self.selectedIDs];
    for (Station *station in self.allStations) {
        if (![selectedSet containsObject:station.stationID]) {
            [result addObject:station];
        }
    }
    return result;
}

- (BOOL)isSelected:(Station *)station {
    return station && [self.selectedIDs containsObject:station.stationID];
}

- (void)setSelected:(BOOL)selected forStation:(Station *)station {
    if (!station) {
        return;
    }
    BOOL currentlySelected = [self.selectedIDs containsObject:station.stationID];
    if (selected == currentlySelected) {
        return;
    }
    if (selected) {
        [self.selectedIDs addObject:station.stationID];
    } else {
        [self.selectedIDs removeObject:station.stationID];
    }
    [self saveSelection];
    [self notifyChange];
}

- (void)moveSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex < 0 || fromIndex >= (NSInteger)self.selectedIDs.count) {
        return;
    }
    if (toIndex < 0 || toIndex >= (NSInteger)self.selectedIDs.count) {
        return;
    }
    if (fromIndex == toIndex) {
        return;
    }
    NSString *stationID = [self.selectedIDs objectAtIndex:fromIndex];
    [self.selectedIDs removeObjectAtIndex:fromIndex];
    [self.selectedIDs insertObject:stationID atIndex:toIndex];
    [self saveSelection];
    [self notifyChange];
}

- (void)resetSelection {
    self.selectedIDs = [NSMutableArray arrayWithArray:self.defaultSelectedIDs];
    [self saveSelection];
    [self notifyChange];
}

- (BOOL)containsStationWithURL:(NSString *)url {
    if (url.length == 0) return NO;
    for (Station *station in self.allStations) {
        if ([station.streamURL isEqualToString:url]) return YES;
    }
    return NO;
}

- (BOOL)addCustomStation:(Station *)station {
    if (!station || station.stationID.length == 0 || station.name.length == 0 || station.streamURL.length == 0) return NO;
    if ([self.stationByID objectForKey:station.stationID]) return NO;
    if ([self containsStationWithURL:station.streamURL]) return NO;
    station.customStation = YES;
    NSMutableArray *stations = [NSMutableArray arrayWithArray:self.allStations];
    [stations addObject:station];
    self.allStations = stations;
    [self.stationByID setObject:station forKey:station.stationID];
    if (![self.selectedIDs containsObject:station.stationID]) {
        [self.selectedIDs addObject:station.stationID];
    }
    [self saveSelection];
    [self saveCustomStations];
    [self notifyChange];
    return YES;
}

- (void)saveCustomStations {
    NSMutableArray *items = [NSMutableArray array];
    for (Station *station in self.allStations) {
        if (station.customStation) [items addObject:[station dictionaryRepresentation]];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:items forKey:kCustomStationsKey];
    [defaults synchronize];
}

- (void)saveSelection {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.selectedIDs forKey:kSelectedIDsKey];
    [defaults synchronize];
}

- (void)notifyChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:StationStoreDidChangeNotification object:self];
}

@end
