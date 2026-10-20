#import "RadioPlayer.h"
#import "Station.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

NSString * const RadioPlayerStateDidChangeNotification = @"RadioPlayerStateDidChangeNotification";

static void *RadioPlayerItemStatusContext = &RadioPlayerItemStatusContext;
static void *RadioPlayerRateContext = &RadioPlayerRateContext;

@interface RadioPlayer () {
    Station *_currentStation;
    RadioPlayerState _state;
    NSString *_errorMessage;
    AVPlayer *_player;
    AVPlayerItem *_item;
    BOOL _pausedByUser;
    BOOL _observingItem;
    BOOL _observingPlayer;
    BOOL _wasPlayingBeforeInterruption;
    BOOL _audioSessionActive;
}

- (void)startPlayback;
- (void)teardownPlayer;
- (void)activateAudioSession;
- (void)deactivateAudioSession;
- (void)setState:(RadioPlayerState)state;
- (void)updateNowPlaying;
- (void)handleFailure:(NSString *)message;

@end

@implementation RadioPlayer

+ (RadioPlayer *)sharedPlayer {
    static RadioPlayer *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[RadioPlayer alloc] init];
    });
    return player;
}

- (id)init {
    self = [super init];
    if (self) {
        _state = RadioPlayerStateIdle;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(audioSessionInterrupted:)
                       name:AVAudioSessionInterruptionNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(audioRouteChanged:)
                       name:AVAudioSessionRouteChangeNotification
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self teardownPlayer];
}

- (Station *)currentStation { return _currentStation; }
- (RadioPlayerState)state { return _state; }
- (NSString *)errorMessage { return _errorMessage; }
- (BOOL)isPlaying { return _state == RadioPlayerStatePlaying; }

- (void)playStation:(Station *)station {
    if (!station || station.streamURL.length == 0) {
        return;
    }
    if (_currentStation && [_currentStation.stationID isEqualToString:station.stationID]) {
        if (_state == RadioPlayerStatePaused || _state == RadioPlayerStateFailed) {
            [self resume];
        }
        return;
    }
    _currentStation = station;
    _errorMessage = nil;
    [self startPlayback];
    [[NSNotificationCenter defaultCenter] postNotificationName:RadioPlayerStateDidChangeNotification object:self];
}

- (void)startPlayback {
    [self teardownPlayer];
    if (!_currentStation) {
        return;
    }

    NSURL *url = [NSURL URLWithString:_currentStation.streamURL];
    if (!url) {
        [self handleFailure:@"直播地址无效"];
        return;
    }

    [self activateAudioSession];
    _item = [AVPlayerItem playerItemWithURL:url];
    [_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:RadioPlayerItemStatusContext];
    _observingItem = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemFailedToPlayToEnd:)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:_item];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification
                                               object:_item];

    _player = [[AVPlayer alloc] initWithPlayerItem:_item];
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:RadioPlayerRateContext];
    _observingPlayer = YES;
    _pausedByUser = NO;
    [self setState:RadioPlayerStateConnecting];
    [_player play];
    [self updateNowPlaying];
}

- (void)teardownPlayer {
    if (_player && _observingPlayer) {
        [_player removeObserver:self forKeyPath:@"rate" context:RadioPlayerRateContext];
        _observingPlayer = NO;
    }
    if (_item && _observingItem) {
        [_item removeObserver:self forKeyPath:@"status" context:RadioPlayerItemStatusContext];
        _observingItem = NO;
    }
    if (_item) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                      object:_item];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemPlaybackStalledNotification
                                                      object:_item];
    }
    [_player pause];
    _player = nil;
    _item = nil;
}

- (void)pause {
    if (_state == RadioPlayerStateIdle || _state == RadioPlayerStateFailed) {
        return;
    }
    _pausedByUser = YES;
    [_player pause];
    [self setState:RadioPlayerStatePaused];
    [self updateNowPlaying];
}

- (void)resume {
    if (!_currentStation) {
        return;
    }
    if (_state == RadioPlayerStateFailed || !_player) {
        [self retry];
        return;
    }
    _pausedByUser = NO;
    [self activateAudioSession];
    [_player play];
    [self setState:RadioPlayerStateConnecting];
    [self updateNowPlaying];
}

- (void)retry {
    if (!_currentStation) {
        return;
    }
    _errorMessage = nil;
    [self startPlayback];
}

- (void)togglePlayPause {
    switch (_state) {
        case RadioPlayerStatePlaying:
        case RadioPlayerStateConnecting:
            [self pause];
            break;
        case RadioPlayerStatePaused:
            [self resume];
            break;
        case RadioPlayerStateFailed:
            [self retry];
            break;
        default:
            break;
    }
}

- (void)stop {
    [self teardownPlayer];
    [self deactivateAudioSession];
    _currentStation = nil;
    _errorMessage = nil;
    _pausedByUser = NO;
    [self setState:RadioPlayerStateIdle];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
}

- (void)handleFailure:(NSString *)message {
    _errorMessage = message ? message : @"无法连接这个电台";
    [self setState:RadioPlayerStateFailed];
    [self updateNowPlaying];
}

- (void)setState:(RadioPlayerState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:RadioPlayerStateDidChangeNotification object:self];
    [self updateNowPlaying];
}

- (void)activateAudioSession {
    if (_audioSessionActive) {
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    [session setActive:YES error:&error];
    _audioSessionActive = YES;
}

- (void)deactivateAudioSession {
    if (!_audioSessionActive) {
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:NULL];
    _audioSessionActive = NO;
}

- (void)updateNowPlaying {
    if (!_currentStation) {
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        return;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setObject:_currentStation.name forKey:MPMediaItemPropertyTitle];
    [info setObject:(_currentStation.genre.length ? _currentStation.genre : @"网络电台") forKey:MPMediaItemPropertyArtist];
    [info setObject:(_currentStation.detail.length ? _currentStation.detail : @"") forKey:MPMediaItemPropertyAlbumTitle];
    [info setObject:[NSNumber numberWithDouble:(_state == RadioPlayerStatePlaying ? 1.0 : 0.0)]
             forKey:MPNowPlayingInfoPropertyPlaybackRate];
    UIImage *artwork = [_currentStation logoImage];
    if (artwork) {
        [info setObject:[[MPMediaItemArtwork alloc] initWithImage:artwork] forKey:MPMediaItemPropertyArtwork];
    }
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == RadioPlayerItemStatusContext) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if (item.status == AVPlayerItemStatusFailed) {
            [self handleFailure:@"无法连接这个电台"];
        } else if (item.status == AVPlayerItemStatusReadyToPlay) {
            if (!_pausedByUser && _player.rate == 0.0f) {
                [_player play];
            }
            if (!_pausedByUser && _player.rate > 0.0f) {
                [self setState:RadioPlayerStatePlaying];
            }
        }
    } else if (context == RadioPlayerRateContext) {
        float rate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (rate > 0.0f) {
            if (!_pausedByUser) {
                [self setState:RadioPlayerStatePlaying];
            }
        } else if (!_pausedByUser && _state == RadioPlayerStatePlaying) {
            [self setState:RadioPlayerStateConnecting];
        }
    }
}

- (void)itemFailedToPlayToEnd:(NSNotification *)notification {
    [self handleFailure:@"播放中断，请重试"];
}

- (void)itemStalled:(NSNotification *)notification {
    if (_pausedByUser) {
        return;
    }
    [self setState:RadioPlayerStateConnecting];
}

- (void)audioSessionInterrupted:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *type = [userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    if ([type unsignedIntegerValue] == AVAudioSessionInterruptionTypeBegan) {
        _wasPlayingBeforeInterruption = (_state == RadioPlayerStatePlaying || _state == RadioPlayerStateConnecting);
        _audioSessionActive = NO;
        if (_wasPlayingBeforeInterruption) {
            _pausedByUser = YES;
            [_player pause];
            [self setState:RadioPlayerStatePaused];
        }
    } else {
        NSNumber *options = [userInfo objectForKey:AVAudioSessionInterruptionOptionKey];
        if (_wasPlayingBeforeInterruption &&
            ([options unsignedIntegerValue] & AVAudioSessionInterruptionOptionShouldResume)) {
            [self resume];
        }
        _wasPlayingBeforeInterruption = NO;
    }
}

- (void)audioRouteChanged:(NSNotification *)notification {
    NSNumber *reason = [notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
    if ([reason unsignedIntegerValue] == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        [self pause];
    }
}

- (void)handleRemoteControlEvent:(UIEvent *)event {
    if (event.type != UIEventTypeRemoteControl) {
        return;
    }
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self togglePlayPause];
            break;
        case UIEventSubtypeRemoteControlStop:
            [self stop];
            break;
        default:
            break;
    }
}

@end
