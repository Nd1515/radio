#import "AddStationViewController.h"
#import "Station.h"
#import "StationStore.h"
#import "Theme.h"

@interface AddStationViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *urlField;
@property (nonatomic, strong) UITextField *genreField;
@end

@implementation AddStationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加电台";
    [Theme styleNavigationBar:self.navigationController.navigationBar];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[Theme woodTexture]];
    self.tableView.separatorColor = [Theme separator];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(saveTapped:)];

    self.nameField = [self makeFieldWithPlaceholder:@"例如：我的电台"];
    self.urlField = [self makeFieldWithPlaceholder:@"http://...m3u8 或 .mp3"];
    self.urlField.keyboardType = UIKeyboardTypeURL;
    self.urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.genreField = [self makeFieldWithPlaceholder:@"音乐、新闻（可不填）"];
}

- (UITextField *)makeFieldWithPlaceholder:(NSString *)placeholder {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectZero];
    field.placeholder = placeholder;
    field.font = [Theme textFontOfSize:15];
    field.textColor = [Theme ink];
    field.delegate = self;
    field.returnKeyType = UIReturnKeyNext;
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    return field;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.nameField becomeFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"自定义直播源";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"支持 http/https 的 MP3、AAC、M3U8 直播地址。保存后会直接加入首页，可在“首页电台”里取消或排序。";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 28)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, tableView.bounds.size.width - 32, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"自定义直播源";
    label.textColor = [Theme cream];
    label.font = [Theme boldTextFontOfSize:11];
    [header addSubview:label];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 54)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 4, tableView.bounds.size.width - 32, 46)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"支持 http/https 的 MP3、AAC、M3U8 直播地址。保存后会直接加入首页，可在“首页电台”里取消或排序。";
    label.textColor = [Theme cream];
    label.font = [Theme textFontOfSize:10];
    label.numberOfLines = 3;
    [footer addSubview:label];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"AddStationFieldCell-%ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [Theme paper];
        cell.contentView.backgroundColor = [Theme paper];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 78, 50)];
        label.backgroundColor = [UIColor clearColor];
        label.font = [Theme boldTextFontOfSize:14];
        label.textColor = [Theme ink];
        label.tag = 1001;
        [cell.contentView addSubview:label];

        UITextField *field = nil;
        if (indexPath.row == 0) {
            field = self.nameField;
        } else if (indexPath.row == 1) {
            field = self.urlField;
        } else {
            field = self.genreField;
        }
        field.frame = CGRectMake(96, 0, cell.contentView.bounds.size.width - 111, 50);
        field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:field];
    }

    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    if (indexPath.row == 0) {
        label.text = @"名称";
    } else if (indexPath.row == 1) {
        label.text = @"直播地址";
    } else {
        label.text = @"分类";
    }
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [self.urlField becomeFirstResponder];
    } else if (textField == self.urlField) {
        [self.genreField becomeFirstResponder];
    } else {
        [self saveTapped:nil];
    }
    return YES;
}

- (NSString *)trimmedString:(NSString *)string {
    if (![string isKindOfClass:[NSString class]]) {
        return @"";
    }
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)saveTapped:(id)sender {
    NSString *name = [self trimmedString:self.nameField.text];
    NSString *urlString = [self trimmedString:self.urlField.text];
    NSString *genre = [self trimmedString:self.genreField.text];

    if (name.length == 0) {
        [self showError:@"请填写电台名称"];
        return;
    }
    if (urlString.length == 0) {
        [self showError:@"请填写直播地址"];
        return;
    }
    if ([urlString rangeOfString:@"://"].location == NSNotFound) {
        urlString = [@"http://" stringByAppendingString:urlString];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = [[url scheme] lowercaseString];
    if (!url || !([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"])) {
        [self showError:@"地址必须是 http:// 或 https:// 开头"];
        return;
    }
    if ([[StationStore sharedStore] containsStationWithURL:urlString]) {
        [self showError:@"这个直播地址已经在列表里了"];
        return;
    }

    Station *station = [[Station alloc] init];
    station.stationID = [NSString stringWithFormat:@"custom-%ld-%u", (long)[[NSDate date] timeIntervalSince1970], arc4random()];
    station.name = name;
    station.streamURL = urlString;
    station.genre = genre.length ? genre : @"自定义";
    station.detail = @"自定义直播源";
    station.frequency = @"在线直播";
    station.customStation = YES;

    if (![[StationStore sharedStore] addCustomStation:station]) {
        [self showError:@"添加失败，请检查名称和地址"];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showError:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法添加"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
