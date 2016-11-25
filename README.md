# YTTableView
a custom tableview with a sliding menu

Examples:
----
```
self.tableView = [[YTTableView alloc] initWithFrame:self.view.bounds];
self.tableView.delegate = (id <UITableViewDelegate>)self;
self.tableView.dataSource = (id <UITableViewDataSource>)self;

self.tableView.menuDelegate = (id<YTTableViewMenuDelegate>)self;
self.tableView.menuItemLayout = EMenuItemLayoutIconTop;
self.tableView.menuTitleColor = [UIColor yellowColor];

[self.view addSubview:self.tableView];

```

