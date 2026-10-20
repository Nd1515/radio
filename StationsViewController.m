#import "StationsViewController.h"
#import "StationStore.h"
#import "Station.h"
#import "StationCell.h"
#import "RadioPlayer.h"
#import "PlayerBarView.h"
#import "PlayerViewController.h"
#import "SettingsViewController.h"
#import "Theme.h"

@interface StationsViewController () <UITableViewDataSource, UITableViewDelegate, PlayerBarViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PlayerBarView *playerBar;
@property (nonatomic, strong) NSArray *stations;
@end

@implementation StationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"老收音机";
    self.view.backgroundColor = [Theme cream];
    [Theme styleNavigationBar:self.navigationController.navigationBar];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(openSettings:)];

    CGFloat height = self.view.bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height - 58.0)
                                                   style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [Theme cream];
    self.tableView.separatorColor = [Theme separator];
    self.tableView.rowHeight = 64.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];

    self.playerBar = [[PlayerBarView alloc] initWithFrame:CGRectMake(0, height - 58.0, self.view.bounds.size.width, 58.0)];
    self.playerBar.delegate = self;
    [self.view addSubview:self.playerBar];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(storeChanged:) name:StationStoreDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(playerChanged:) name:RadioPlayerStateDidChangeNotification object:nil];

    [self reloadStations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Theme styleNavigationBar:self.navigationController.navigationBar];
    [self reloadStations];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = self.view.bounds.size.height;
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height - 58.0);
    self.playerBar.frame = CGRectMake(0, height - 58.0, self.view.bounds.size.width, 58.0);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadStations {
    self.stations = [[StationStore sharedStore] selectedStations];
    [self.tableView reloadData];
    [self updatePlayerBar];

    if (self.stations.count == 0) {
        UILabel *empty = [[UILabel alloc] initWithFrame:self.tableView.bounds];
        empty.backgroundColor = [UIColor clearColor];
        empty.textColor = [Theme muted];
        empty.font = [Theme textFontOfSize:15];
        empty.textAlignment = NSTextAlignmentCenter;
        empty.numberOfLines = 0;
        empty.text = @"还没有选择电台\n点右上角“选择”，勾选你常听的几个";
        self.tableView.backgroundView = empty;
    } else {
        self.tableView.backgroundView = nil;
    }
}

- (void)updatePlayerBar {
    RadioPlayer *player = [RadioPlayer sharedPlayer];
    [self.playerBar updateWithStation:player.currentStation state:player.state];
}

- (void)storeChanged:(NSNotification *)notification {
    [self reloadStations];
}

- (void)playerChanged:(NSNotification *)notification {
    [self updatePlayerBar];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.stations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"StationCell";
    StationCell *cell = (StationCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[StationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    Station *station = [self.stations objectAtIndex:indexPath.row];
    RadioPlayer *player = [RadioPlayer sharedPlayer];
    BOOL current = player.currentStation && [player.currentStation.stationID isEqualToString:station.stationID];
    BOOL active = current && (player.state == RadioPlayerStatePlaying || player.state == RadioPlayerStateConnecting);
    [cell setStation:station nowPlaying:active];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Station *station = [self.stations objectAtIndex:indexPath.row];
    [[RadioPlayer sharedPlayer] playStation:station];
}

- (void)openSettings:(id)sender {
    SettingsViewController *settings = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:settings];
    [Theme styleNavigationBar:navigation.navigationBar];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)playerBarDidTap:(PlayerBarView *)bar {
    RadioPlayer *player = [RadioPlayer sharedPlayer];
    if (!player.currentStation) {
        [self openSettings:nil];
        return;
    }
    PlayerViewController *playerController = [[PlayerViewController alloc] init];
    [self.navigationController pushViewController:playerController animated:YES];
}

- (void)playerBarDidTapPlayButton:(PlayerBarView *)bar {
    RadioPlayer *player = [RadioPlayer sharedPlayer];
    if (!player.currentStation) {
        if (self.stations.count > 0) {
            [player playStation:[self.stations objectAtIndex:0]];
        } else {
            [self openSettings:nil];
        }
        return;
    }
    [player togglePlayPause];
}

@end
