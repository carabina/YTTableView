//
//  ViewController.m
//  TestYTTableView
//
//  Created by songyutao on 2016/11/25.
//  Copyright © 2016年 Creditease. All rights reserved.
//

#import "ViewController.h"
#import "YTTableView.h"

@interface ViewController ()

@property(nonatomic, strong)YTTableView         *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView = [[YTTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = (id <UITableViewDelegate>)self;
    self.tableView.dataSource = (id <UITableViewDataSource>)self;
    self.tableView.menuDelegate = (id<YTTableViewMenuDelegate>)self;
    self.tableView.menuItemLayout = EMenuItemLayoutIconTop;
    self.tableView.menuTitleColor = [UIColor yellowColor];
    [self.view addSubview:self.tableView];

}

#pragma - mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"reimbursementListIndentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:indentifier];
        cell.backgroundColor = [UIColor grayColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"row%ld", (long)indexPath.row];
    cell.detailTextLabel.text = @"bbb";
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    return cell;
}

#pragma - mark - YTTableViewMenuDelegate
- (BOOL)tableView:(YTTableView *)tableView supportMenuAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row % 2 == 0 ? YES : NO;
}

- (NSUInteger)tableView:(YTTableView *)tableView menuItemCountAtIndexPath:(NSIndexPath *)indexPath
{
    return 2;
}

- (NSString *)tableView:(YTTableView *)tableView menuTitleAtIndex:(NSUInteger)index
{
    return index == 0 ? @"abc" : @"12";
}

- (UIColor *)tableView:(YTTableView *)tableView menuColorAtIndex:(NSUInteger)index
{
    return index == 0 ? [UIColor redColor] : [UIColor greenColor];
}

- (void)tableView:(YTTableView *)tableView menuDidSelected:(NSUInteger)index atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d", index);
}


@end
