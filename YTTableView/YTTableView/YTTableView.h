//
//  YTTableView.h
//
//
//  实例：
//    self.tableView = [[YTTableView alloc] initWithFrame:self.view.bounds];
//    self.tableView.delegate = (id <UITableViewDelegate>)self;
//    self.tableView.dataSource = (id <UITableViewDataSource>)self;
//    self.tableView.menuDelegate = (id<YXTableViewMenuDelegate>)self;
//    self.tableView.menuItemLayout = EMenuItemLayoutIconTop;
//    [self.view addSubview:self.tableView];
//
//  Created by songyutao on 14-12-14.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YTTableView;

typedef NS_ENUM(NSUInteger, MenuItemLayout)
{
    EMenuItemLayoutIconTop,
    EMenuItemLayoutIconBottom,
};


@protocol YTTableViewMenuDelegate <NSObject>

//那个indexPath支持滑动菜单
- (BOOL)tableView:(YTTableView *)tableView supportMenuAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)tableView:(YTTableView *)tableView menuItemCountAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(YTTableView *)tableView menuTitleAtIndex:(NSUInteger)index;
- (UIImage *)tableView:(YTTableView *)tableView menuIconAtIndex:(NSUInteger)index;
//菜单背景颜色
- (UIColor *)tableView:(YTTableView *)tableView menuColorAtIndex:(NSUInteger)index;
- (void)tableView:(YTTableView *)tableView menuDidSelected:(NSUInteger)index atIndexPath:(NSIndexPath *)indexPath;

@end

@interface YTTableView : UITableView

@property(nonatomic, strong)UIColor                         *menuTitleColor         UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign)CGFloat                         menuItemWidth           UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign)MenuItemLayout                  menuItemLayout          UI_APPEARANCE_SELECTOR;
@property(nonatomic, weak  )id<YTTableViewMenuDelegate>     menuDelegate;

@end
