#import "StationStore.h"
#import "Station.h"

NSString * const StationStoreDidChangeNotification = @"StationStoreDidChangeNotification";
static NSString * const kSelectedIDsKey = @"OldRadioSelectedStationIDs";
static NSString * const kCustomStationsKey = @"OldRadioCustomStations";
static NSString * const kMusicMigrationKey = @"OldRadioMusicMigrationV1";

@interface StationStore ()
@property (nonatomic, strong, readwrite) NSArray *allStations;
@property (nonatomic, strong, readwrite) NSArray *defaultSelectedIDs;
@property (nonatomic, strong) NSMutableArray *builtInStations;
@property (nonatomic, strong) NSMutableArray *customStations;
@property (nonatomic, strong) NSMutableArray *selectedIDs;
@property (nonatomic, strong) NSMutableDictionary *stationByID;
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
        [self loadBuiltInStations];
        [self loadCustomStations];
        [self rebuildStationIndex];
        [self loadSelection];
        [self migrateMusicStationsIfNeeded];
    }
    return self;
}

- (void)loadBuiltInStations {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Stations" ofType:@"plist"];
    NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *rawStations = [root objectForKey:@"Stations"];
    self.defaultSelectedIDs = [root objectForKey:@"DefaultSelected"];
    if (![self.defaultSelectedIDs isKindOfClass:[NSArray class]]) {
        self.defaultSelectedIDs = [NSArray array];
    }

    self.builtInStations = [NSMutableArray array];
    for (NSDictionary *dictionary in rawStations) {
        Station *station = [Station stationWithDictionary:dictionary];
        if (station) {
            station.customStation = NO;
            [self.builtInStations addObject:station];
        }
    }
}

- (void)loadCustomStations {
    self.customStations = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *raw = [defaults objectForKey:kCustomStationsKey];
    if (![raw isKindOfClass:[NSArray class]]) {
        return;
    }
    for (NSDictionary *dictionary in raw) {
        Station *station = [Station stationWithDictionary:dictionary];
        if (station) {
            station.customStation = YES;
            [self.customStations addObject:station];
        }
    }
}

- (void)rebuildStationIndex {
    NSMutableArray *all = [NSMutableArray arrayWithArray:self.builtInStations];
    [all addObjectsFromArray:self.customStations];
    self.allStations = all;

    NSMutableDictionary *byID = [NSMutableDictionary dictionary];
    for (Station *station in all) {
        if (station.stationID.length > 0) {
            [byID setObject:station forKey:station.stationID];
        }
    }
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

- (void)migrateMusicStationsIfNeeded {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kMusicMigrationKey]) {
        return;
    }
    BOOL changed = NO;
    NSArray *musicIDs = [NSArray arrayWithObjects:@"musicradio", @"gd-music", nil];
    for (NSString *stationID in musicIDs) {
        if ([self.stationByID objectForKey:stationID] &&
            ![self.selectedIDs containsObject:stationID]) {
            [self.selectedIDs addObject:stationID];
            changed = YES;
        }
    }
    [defaults setBool:YES forKey:kMusicMigrationKey];
    if (changed) {
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
    NSMutableArray *ids = [NSMutableArray arrayWithArray:self.defaultSelectedIDs];
    NSArray *musicIDs = [NSArray arrayWithObjects:@"musicradio", @"gd-music", nil];
    for (NSString *stationID in musicIDs) {
        if ([self.stationByID objectForKey:stationID] && ![ids containsObject:stationID]) {
            [ids addObject:stationID];
        }
    }
    self.selectedIDs = ids;
    [self saveSelection];
    [self notifyChange];
}

- (BOOL)containsStationWithURL:(NSString *)urlString {
    if (urlString.length == 0) {
        return NO;
    }
    NSString *target = [[urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    for (Station *station in self.allStations) {
        NSString *url = [[station.streamURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        if ([url isEqualToString:target]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)addCustomStation:(Station *)station {
    if (!station || station.name.length == 0 || station.streamURL.length == 0) {
        return NO;
    }
    if ([self containsStationWithURL:station.streamURL]) {
        return NO;
    }
    if (station.stationID.length == 0) {
        station.stationID = [NSString stringWithFormat:@"custom-%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    station.customStation = YES;
    station.frequency = station.frequency.length ? station.frequency : @"在线直播";
    station.genre = station.genre.length ? station.genre : @"自定义";
    station.detail = station.detail.length ? station.detail : @"自定义直播源";

    [self.customStations addObject:station];
    [self rebuildStationIndex];
    [self.selectedIDs addObject:station.stationID];
    [self saveCustomStations];
    [self saveSelection];
    [self notifyChange];
    return YES;
}

- (void)removeStation:(Station *)station {
    if (!station || !station.isCustomStation) {
        return;
    }
    NSUInteger index = NSNotFound;
    for (NSUInteger i = 0; i < self.customStations.count; i++) {
        Station *candidate = [self.customStations objectAtIndex:i];
        if ([candidate.stationID isEqualToString:station.stationID]) {
            index = i;
            break;
        }
    }
    if (index == NSNotFound) {
        return;
    }
    [self.customStations removeObjectAtIndex:index];
    [self.selectedIDs removeObject:station.stationID];
    [self rebuildStationIndex];
    [self saveCustomStations];
    [self saveSelection];
    [self notifyChange];
}

- (void)saveCustomStations {
    NSMutableArray *raw = [NSMutableArray array];
    for (Station *station in self.customStations) {
        [raw addObject:[station dictionaryRepresentation]];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:raw forKey:kCustomStationsKey];
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
