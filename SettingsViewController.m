#import "SettingsViewController.h"
#import "StationStore.h"
#import "Station.h"
#import "StationCell.h"
#import "AddStationViewController.h"
#import "Theme.h"
#import <QuartzCore/QuartzCore.h>

@interface SettingsViewController ()
@property (nonatomic, strong) NSArray *selected;
@property (nonatomic, strong) NSArray *unselected;
@property (nonatomic, strong) UIBarButtonItem *sortButton;
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
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[Theme woodTexture]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 72.0;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(closeTapped:)];
    self.sortButton = [[UIBarButtonItem alloc] initWithTitle:@"排序"
                                                       style:UIBarButtonItemStyleBordered
                                                      target:self
                                                      action:@selector(editTapped:)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(addTapped:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.sortButton, addButton, nil];
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

- (void)addTapped:(id)sender {
    if (self.isEditing) {
        [self setEditing:NO animated:YES];
    }
    AddStationViewController *controller = [[AddStationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    self.sortButton.title = editing ? @"完成" : @"排序";
    self.tableView.allowsSelectionDuringEditing = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 28)];
    header.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, tableView.bounds.size.width - 32, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textColor = [Theme cream];
    label.font = [Theme boldTextFontOfSize:11];
    label.layer.shadowColor = [[UIColor blackColor] CGColor];
    label.layer.shadowOpacity = 0.8;
    label.layer.shadowRadius = 1.0;
    label.layer.shadowOffset = CGSizeMake(0, 1);
    [header addSubview:label];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 42.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 42)];
    footer.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 2, tableView.bounds.size.width - 32, 38)];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:tableView titleForFooterInSection:section];
    label.textColor = [Theme cream];
    label.font = [Theme textFontOfSize:10];
    label.numberOfLines = 2;
    [footer addSubview:label];
    return footer;
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
    return @"点按加入首页。右上角“+”可以添加自己的直播源；左滑可删除自定义台。";
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
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (selected) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        UILabel *check = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        check.backgroundColor = [UIColor clearColor];
        check.text = @"✓";
        check.textAlignment = NSTextAlignmentCenter;
        check.textColor = [Theme accent];
        check.font = [Theme boldTextFontOfSize:20];
        cell.accessoryView = check;
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
    if (indexPath.section == 0) {
        return YES;
    }
    Station *station = [self.unselected objectAtIndex:indexPath.row];
    return station.isCustomStation;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewCellEditingStyleDelete;
    }
    Station *station = [self.unselected objectAtIndex:indexPath.row];
    return station.isCustomStation ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    StationStore *store = [StationStore sharedStore];
    if (indexPath.section == 0) {
        Station *station = [self.selected objectAtIndex:indexPath.row];
        [store setSelected:NO forStation:station];
    } else {
        Station *station = [self.unselected objectAtIndex:indexPath.row];
        [store removeStation:station];
    }
    [self reloadData];
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
