#import "Station.h"

@implementation Station

+ (Station *)stationWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    Station *station = [[Station alloc] init];
    station.stationID = [dictionary objectForKey:@"id"];
    station.name = [dictionary objectForKey:@"name"];
    station.genre = [dictionary objectForKey:@"genre"];
    station.detail = [dictionary objectForKey:@"detail"];
    station.frequency = [dictionary objectForKey:@"frequency"];
    station.streamURL = [dictionary objectForKey:@"url"];
    station.logoName = [dictionary objectForKey:@"logo"];
    if (station.stationID.length == 0 || station.name.length == 0 || station.streamURL.length == 0) {
        return nil;
    }
    return station;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.stationID) [dictionary setObject:self.stationID forKey:@"id"];
    if (self.name) [dictionary setObject:self.name forKey:@"name"];
    if (self.genre) [dictionary setObject:self.genre forKey:@"genre"];
    if (self.detail) [dictionary setObject:self.detail forKey:@"detail"];
    if (self.frequency) [dictionary setObject:self.frequency forKey:@"frequency"];
    if (self.streamURL) [dictionary setObject:self.streamURL forKey:@"url"];
    if (self.logoName) [dictionary setObject:self.logoName forKey:@"logo"];
    return dictionary;
}

- (UIImage *)logoImage {
    if (self.logoName.length == 0) {
        return nil;
    }
    UIImage *image = [UIImage imageNamed:self.logoName];
    if (!image) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[self.logoName stringByDeletingPathExtension]
                                                        ofType:[self.logoName pathExtension]];
        if (path) {
            image = [UIImage imageWithContentsOfFile:path];
        }
    }
    return image;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[Station class]]) {
        return NO;
    }
    return [self.stationID isEqualToString:[(Station *)object stationID]];
}

- (NSUInteger)hash {
    return [self.stationID hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Station %@ %@>", self.stationID, self.name];
}

@end
