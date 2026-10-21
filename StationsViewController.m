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
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PlayerBarView *playerBar;
@property (nonatomic, strong) NSArray *stations;
@end

@implementation StationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"📻";
    self.view.backgroundColor = [Theme walnut];
    [Theme styleNavigationBar:self.navigationController.navigationBar];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(openSettings:)];

    self.backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[Theme woodTexture]];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.backgroundView];

    CGFloat height = self.view.bounds.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height - 64.0)
                                                   style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [Theme styleTableView:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 78.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [self buildHeaderView];
    [self.view addSubview:self.tableView];

    self.playerBar = [[PlayerBarView alloc] initWithFrame:CGRectMake(0, height - 64.0, self.view.bounds.size.width, 64.0)];
    self.playerBar.delegate = self;
    [self.view addSubview:self.playerBar];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(storeChanged:) name:StationStoreDidChangeNotification object:nil];
    [center addObserver:self selector:@selector(playerChanged:) name:RadioPlayerStateDidChangeNotification object:nil];

    [self reloadStations];
}

- (UIView *)buildHeaderView {
    CGFloat width = self.view.bounds.size.width;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 62.0)];
    header.backgroundColor = [UIColor colorWithPatternImage:[Theme metalTexture]];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 2)];
    top.backgroundColor = [Theme brass];
    top.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [header addSubview:top];

    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 60, width, 2)];
    bottom.backgroundColor = [Theme brass];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [header addSubview:bottom];

    UILabel *brand = [[UILabel alloc] initWithFrame:CGRectMake(14, 9, 260, 26)];
    brand.backgroundColor = [UIColor clearColor];
    brand.text = @"📻";
    brand.textColor = [Theme cream];
    brand.font = [Theme displayFontOfSize:22];
    brand.layer.shadowColor = [[UIColor blackColor] CGColor];
    brand.layer.shadowOpacity = 0.7;
    brand.layer.shadowRadius = 1.0;
    brand.layer.shadowOffset = CGSizeMake(0, 1);
    [header addSubview:brand];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 300, 15)];
    subtitle.backgroundColor = [UIColor clearColor];
    subtitle.text = @"AM · FM · INTERNET RECEIVER";
    subtitle.textColor = [Theme brass];
    subtitle.font = [Theme boldTextFontOfSize:9];
    [header addSubview:subtitle];

    UIView *led = [[UIView alloc] initWithFrame:CGRectMake(width - 76, 17, 8, 8)];
    led.backgroundColor = [Theme ledRed];
    led.layer.cornerRadius = 4.0;
    led.layer.borderWidth = 1.0;
    led.layer.borderColor = [[UIColor colorWithRed:0.30 green:0.03 blue:0.02 alpha:1.0] CGColor];
    led.layer.shadowColor = [[Theme ledRed] CGColor];
    led.layer.shadowOpacity = 0.9;
    led.layer.shadowRadius = 4.0;
    led.layer.shadowOffset = CGSizeZero;
    led.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [header addSubview:led];

    UILabel *onAir = [[UILabel alloc] initWithFrame:CGRectMake(width - 64, 14, 58, 16)];
    onAir.backgroundColor = [UIColor clearColor];
    onAir.text = @"ON AIR";
    onAir.textColor = [Theme ledRed];
    onAir.font = [Theme boldTextFontOfSize:10];
    onAir.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [header addSubview:onAir];

    return header;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Theme styleNavigationBar:self.navigationController.navigationBar];
    [self reloadStations];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat height = self.view.bounds.size.height;
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, height - 64.0);
    self.playerBar.frame = CGRectMake(0, height - 64.0, self.view.bounds.size.width, 64.0);
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
        empty.textColor = [Theme cream];
        empty.font = [Theme textFontOfSize:15];
        empty.textAlignment = NSTextAlignmentCenter;
        empty.numberOfLines = 0;
        empty.text = @"还没有选择电台\n点右上角“选择”，勾选你常听的几个\n也可以点“＋”添加自己的直播源";
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
