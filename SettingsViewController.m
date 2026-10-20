#import "SettingsViewController.h"
#import "StationStore.h"
#import "Station.h"
#import "StationCell.h"
#import "Theme.h"

@interface SettingsViewController ()
@property (nonatomic, strong) NSArray *selected;
@property (nonatomic, strong) NSArray *unselected;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页电台";
    [Theme styleNavigationBar:self.navigationController.navigationBar];
    self.tableView.backgroundColor = [Theme cream];
    self.tableView.separatorColor = [Theme separator];
    self.tableView.rowHeight = 64.0;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(closeTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"排序"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(editTapped:)];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)reloadData {
    StationStore *store = [StationStore sharedStore];
    self.selected = [store selectedStations];
    self.unselected = [store unselectedStations];
    [self.tableView reloadData];
}

- (void)closeTapped:(id)sender {
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editTapped:(id)sender {
    [self setEditing:!self.isEditing animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    self.navigationItem.rightBarButtonItem.title = editing ? @"完成" : @"排序";
    self.tableView.allowsSelectionDuringEditing = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? (NSInteger)self.selected.count : (NSInteger)self.unselected.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [NSString stringWithFormat:@"首页显示（%lu 个，拖动排序）", (unsigned long)self.selected.count];
    }
    return [NSString stringWithFormat:@"更多电台（%lu 个，点按加入）", (unsigned long)self.unselected.count];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"首页只显示这一组。点按可取消；点右上角“排序”后，按住右侧 ≡ 上下拖动。";
    }
    return @"点按加入首页。列表来自随 App 预装的 46 个电台，无需再复制配置。";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"StationSettingCell";
    StationCell *cell = (StationCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[StationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    Station *station = nil;
    BOOL selected = (indexPath.section == 0);
    station = selected ? [self.selected objectAtIndex:indexPath.row] : [self.unselected objectAtIndex:indexPath.row];
    [cell setStation:station nowPlaying:NO];
    cell.nameLabel.textColor = [Theme ink];
    cell.detailLabel.textColor = [Theme muted];
    cell.backgroundColor = [Theme paper];
    cell.contentView.backgroundColor = [Theme paper];

    if (selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *plus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        plus.backgroundColor = [UIColor clearColor];
        plus.text = @"＋";
        plus.textAlignment = NSTextAlignmentCenter;
        plus.textColor = [Theme accent];
        plus.font = [Theme boldTextFontOfSize:20];
        cell.accessoryView = plus;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isEditing) {
        return;
    }
    StationStore *store = [StationStore sharedStore];
    if (indexPath.section == 0) {
        Station *station = [self.selected objectAtIndex:indexPath.row];
        [store setSelected:NO forStation:station];
    } else {
        Station *station = [self.unselected objectAtIndex:indexPath.row];
        [store setSelected:YES forStation:station];
    }
    [self reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0) {
        Station *station = [self.selected objectAtIndex:indexPath.row];
        [[StationStore sharedStore] setSelected:NO forStation:station];
        [self reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.section != 0 || destinationIndexPath.section != 0) {
        return;
    }
    [[StationStore sharedStore] moveSelectedFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    self.selected = [[StationStore sharedStore] selectedStations];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.section != 0) {
        NSInteger row = (NSInteger)self.selected.count - 1;
        if (row < 0) {
            row = 0;
        }
        return [NSIndexPath indexPathForRow:row inSection:0];
    }
    return proposedDestinationIndexPath;
}

@end
