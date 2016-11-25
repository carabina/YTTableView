//
//  YXTableView.m
//  TestTableView
//
//  Created by songyutao on 14-12-14.
//  Copyright (c) 2014年 Creditease. All rights reserved.
//

#import "YTTableView.h"

static const CGFloat KMenuItemWidth = 60;

@interface MenuItemView : UIView

- (id)initWithTitle:(NSString *)title icon:(UIImage *)icon;

@property(nonatomic, strong)UILabel             *menuTitle;
@property(nonatomic, strong)UIImageView         *menuIcon;
@property(nonatomic, assign)MenuItemLayout      itemLayout;

@end

@implementation MenuItemView

- (id)initWithTitle:(NSString *)title icon:(UIImage *)icon
{
    self = [super init];
    if (self) {
        
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:self.menuTitle.font}];
        self.menuTitle.text = title;
        self.menuTitle.frame = CGRectMake(0, 0, size.width, size.height);
        
        self.menuIcon.image = icon;
        self.menuIcon.frame = CGRectMake(0, 0, icon.size.width, icon.size.height);
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.menuTitle = [[UILabel alloc] init];
        self.menuTitle.numberOfLines = 0;
        self.menuTitle.textAlignment = NSTextAlignmentCenter;
        self.menuTitle.font = [UIFont systemFontOfSize:15];
        self.menuTitle.textColor = [UIColor whiteColor];
        self.menuTitle.backgroundColor = [UIColor clearColor];
        [self addSubview:self.menuTitle];
        
        self.menuIcon = [[UIImageView alloc] init];
        [self addSubview:self.menuIcon];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.itemLayout) {
        case EMenuItemLayoutIconTop:
        {
            CGFloat height = self.bounds.size.height-self.menuTitle.bounds.size.height-self.menuIcon.bounds.size.height;
            self.menuIcon.frame = CGRectMake((self.bounds.size.width-self.menuIcon.bounds.size.width)/2, height/2, self.menuIcon.bounds.size.width, self.menuIcon.bounds.size.height);
            self.menuTitle.frame = CGRectMake(0, CGRectGetMaxY(self.menuIcon.frame), self.bounds.size.width, self.menuTitle.font.lineHeight);
            break;
        }
        case EMenuItemLayoutIconBottom:
        {
            CGFloat height = self.bounds.size.height-self.menuTitle.bounds.size.height-self.menuIcon.bounds.size.height;
            self.menuTitle.frame = CGRectMake(0, height/2, self.menuTitle.bounds.size.width, self.menuTitle.bounds.size.height);
            self.menuIcon.frame = CGRectMake((self.bounds.size.width-self.menuIcon.bounds.size.width)/2, CGRectGetMaxY(self.menuTitle.frame) , self.menuIcon.bounds.size.width, self.menuIcon.bounds.size.height);
            break;
        }
        default:
            break;
    }
    
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface YTTableView ()

@property(nonatomic, strong)UIPanGestureRecognizer          *panRecognizer;
@property(nonatomic, strong)UITapGestureRecognizer          *tapRecognizer;
@property(nonatomic, strong)UIView                          *menuView;
@property(nonatomic, strong)UIView                          *menuBgView;
@property(nonatomic, assign)CGPoint                         startPoint;
@property(nonatomic, assign)UITableViewCell                 *slideCell;
@property(nonatomic, assign)CGFloat                         slideCellInitialX;
@property(nonatomic, assign)BOOL                            canExpandSelf;

@end

@implementation YTTableView

+ (void)initialize
{
    [[self appearance] setMenuTitleColor:[UIColor blackColor]];
    [[self appearance] setMenuItemWidth:KMenuItemWidth];
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
        self.delaysContentTouches = NO;
        
        if ([UIDevice currentDevice].systemVersion.intValue >= 8)
        {
            for (UIView *currentView in self.subviews)
            {
                if ([currentView isKindOfClass:[UIScrollView class]])
                {
                    ((UIScrollView *)currentView).delaysContentTouches = NO;
                    break;
                }
            }
        }
        
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecognizer:)];
        self.panRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
        self.panRecognizer.enabled = NO;
        [self addGestureRecognizer:self.panRecognizer];
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRecognizer:)];
        self.tapRecognizer.delegate = (id <UIGestureRecognizerDelegate>)self;
        self.tapRecognizer.enabled = NO;
        [self addGestureRecognizer:self.tapRecognizer];
    }
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}

- (void)setMenuDelegate:(id<YTTableViewMenuDelegate>)menuDelegate
{
    _menuDelegate = menuDelegate;
    
    self.panRecognizer.enabled = menuDelegate != nil;
    self.tapRecognizer.enabled = menuDelegate != nil;
}

- (void)loadMenuView:(NSUInteger)count inTableViewCell:(UITableViewCell *)cell
{
    [self.menuBgView removeFromSuperview];
    self.menuBgView = [[UIView alloc] initWithFrame:cell.frame];
    self.menuBgView.backgroundColor = cell.backgroundColor;
    [self addSubview:self.menuBgView];
    
    [self.menuView removeFromSuperview];
    self.menuView = [[UIView alloc] init];
    [self.menuBgView addSubview:self.menuView];
    
    [self sendSubviewToBack:self.menuBgView];

    self.menuView.frame = CGRectMake(cell.frame.size.width-count * self.menuItemWidth, 0, count * self.menuItemWidth, cell.frame.size.height);

}

- (void)handleRecognizer:(UIGestureRecognizer *)recognizer
{
    CGPoint pt = [recognizer locationInView:self];
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:pt];
    
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        switch (recognizer.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                if (self.slideCell)
                {
                    self.canExpandSelf = NO;
                    [self closeCurrentMenu];
                    return;
                }
            
                self.slideCell = [self cellForRowAtIndexPath:indexPath];
                self.slideCellInitialX = self.slideCell.frame.origin.x;
            
                if ([self.menuDelegate respondsToSelector:@selector(tableView:supportMenuAtIndexPath:)] &&
                    [self.menuDelegate tableView:self supportMenuAtIndexPath:indexPath])
                {
                    
                    if ([self.menuDelegate respondsToSelector:@selector(tableView:menuItemCountAtIndexPath:)])
                    {
                        NSUInteger menuCount = [self.menuDelegate tableView:self menuItemCountAtIndexPath:indexPath];
                        if (menuCount != 0)
                        {
                            [self loadMenuView:menuCount inTableViewCell:self.slideCell];
                            
                            CGFloat offX = 0;
                            for (NSUInteger i=0; i<menuCount; i++)
                            {
                                NSString *itemTitle = nil;
                                UIImage *itemIcon = nil;
                                if ([self.menuDelegate respondsToSelector:@selector(tableView:menuTitleAtIndex:)])
                                {
                                    itemTitle = [self.menuDelegate tableView:self menuTitleAtIndex:i];
                                }
                                
                                if ([self.menuDelegate respondsToSelector:@selector(tableView:menuIconAtIndex:)])
                                {
                                    itemIcon = [self.menuDelegate tableView:self menuIconAtIndex:i];
                                }
                                
                                if (itemTitle || itemIcon)
                                {
                                    self.startPoint = pt;
                                    self.canExpandSelf = YES;
                                    
                                    MenuItemView *menuItem = [[MenuItemView alloc] initWithTitle:itemTitle icon:itemIcon];
                                    menuItem.itemLayout = self.menuItemLayout;
                                    menuItem.frame = CGRectMake(offX, menuItem.frame.origin.y, self.menuItemWidth, self.menuView.bounds.size.height);
                                    menuItem.menuTitle.textColor = self.menuTitleColor;
                                    if ([self.menuDelegate respondsToSelector:@selector(tableView:menuColorAtIndex:)])
                                    {
                                        menuItem.backgroundColor = [self.menuDelegate tableView:self menuColorAtIndex:i];
                                    }
                                    [self.menuView addSubview:menuItem];
                                    
                                    offX += self.menuItemWidth;
                                }
                            }
                        }
                        else
                        {
                            self.canExpandSelf = NO;
                        }
                    }
                    else
                    {
                        self.canExpandSelf = NO;
                    }
                }
                else
                {
                    self.canExpandSelf = NO;
                }

                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                if (pt.x-self.startPoint.x < 0 && self.canExpandSelf)
                {
                    self.slideCell.frame = CGRectMake(self.slideCellInitialX + (pt.x-self.startPoint.x), self.slideCell.frame.origin.y, self.slideCell.frame.size.width, self.slideCell.frame.size.height);
                }
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateFailed:
            {
                if (!self.canExpandSelf)
                {
                    return;
                }
                
                if (pt.x-self.startPoint.x < 0 && abs(pt.x-self.startPoint.x) > self.menuItemWidth)
                {
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.slideCell.frame = CGRectMake(self.bounds.origin.x-self.menuView.frame.size.width, self.slideCell.frame.origin.y, self.slideCell.frame.size.width, self.slideCell.frame.size.height);
                    } completion:nil];
                }
                else
                {
                    [self closeCurrentMenu];
                }
                
                break;
            }
            default:
                break;
        }
    }
    else
    {
        if (!CGRectContainsPoint(self.menuBgView.frame, pt) && self.slideCell)
        {
            [self closeCurrentMenu];
        }
        else
        {
            [self closeCurrentMenu];
            
            CGPoint clickPt = [self convertPoint:pt toView:self.menuView];
            for (NSInteger i=0; i<self.menuView.subviews.count; i++)
            {
                MenuItemView *menuItem = [self.menuView.subviews objectAtIndex:i];
                if (CGRectContainsPoint(menuItem.frame, clickPt))
                {
                    if ([self.menuDelegate respondsToSelector:@selector(tableView:menuDidSelected:atIndexPath:)])
                    {
                        NSIndexPath *indexPath = [self indexPathForCell:self.slideCell];
                        [self.menuDelegate tableView:self menuDidSelected:i atIndexPath:indexPath];
                    }
                    break;
                }
            }
        }
    }
}

- (void)reloadData
{
    [super reloadData];
    
    [self closeCurrentMenu];
}

- (void)closeCurrentMenu
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.slideCell.frame = CGRectMake(0, self.slideCell.frame.origin.y, self.slideCell.frame.size.width, self.slideCell.frame.size.height);
    } completion:^(BOOL finished) {
        [self.menuBgView removeFromSuperview];
        self.menuBgView = nil;
        self.slideCell = nil;
        self.canExpandSelf = NO;
    }];
}

#pragma - mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if ( recognizer == self.panRecognizer )
    {
        if (self.slideCell)
        {
            return YES;
        }
        
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        CGPoint translation = [panRecognizer translationInView:self.superview];
        return fabs(translation.y) <= fabs(translation.x);
    }
    else if (recognizer == self.tapRecognizer)
    {
        return self.slideCell != nil ? YES : NO;
    }
    else
    {
        return YES;
    }
}

@end
