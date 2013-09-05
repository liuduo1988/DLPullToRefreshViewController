//
//  DLPullToRefreshViewController.m
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import "DLPullToRefreshViewController.h"
#import "DLPullToRefreshView.h"
#import "DLLoadMoreView.h"
#import "DLLoadingStateView.h"

@interface DLPullToRefreshViewController ()
@property (nonatomic, strong) DLPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) DLLoadMoreView *loadMoreView;
@end

@implementation DLPullToRefreshViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.showFirstLoadingView = NO;
        self.forbidRefreshAndLoadMoreSimultaneously = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshing = NO;
    self.loadingMore = NO;
    self.pageIndex = 0;
    
    self.items = [NSMutableArray array];
    
    self.pullToRefreshView = [[NSBundle mainBundle] loadNibNamed:@"DLPullToRefreshView" owner:self options:nil][0];
    self.pullToRefreshView.frame = CGRectMake(0,
                                              0 - CGRectGetHeight(self.pullToRefreshView.frame),
                                              CGRectGetWidth(self.tableView.bounds),
                                              CGRectGetHeight(self.pullToRefreshView.frame));
    [self.tableView addSubview:self.pullToRefreshView];
    
    self.loadingStateView = [[NSBundle mainBundle] loadNibNamed:@"DLLoadingStateView" owner:self options:nil][0];
    [self.loadingStateView setState:DLLoadingViewStateLoading];
    [self.tableView addSubview:self.loadingStateView];
    
    [self addObserver:self forKeyPath:@"refreshing" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"loadingMore" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"refreshing"];
    [self removeObserver:self forKeyPath:@"loadingMore"];
}

- (void)startLoadData {
    if ([self.loadingStateView isVisible]) {
        self.refreshing = NO;
        self.loadingStateView.state = DLLoadingViewStateLoading;
    } else {
        self.refreshing = YES;
    }
    
    [self doRefresh];
}

// Override this method
// 子类的此方法中，要在开头把endReached设为NO，要在数据加载结束后把refreshing设为NO
- (void)doRefresh {
    NSLog(@"doRefresh : You must override this method in subclass. If this log appears, there is a mistake.");
}

- (void)setRefreshing:(BOOL)refreshing {
    _refreshing = refreshing;
    
    if (self.loadingStateView.state == DLLoadingViewStateLoading) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    
    if (refreshing) {
        [self.pullToRefreshView setState:DLPullRefreshLoading];
        [UIView setAnimationDuration:0.2];
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, CGRectGetWidth(self.pullToRefreshView.frame), CGRectGetHeight(self.pullToRefreshView.frame)) animated:NO];
    } else {
        [self.pullToRefreshView setState:DLPullRefreshNormal];
        [self.pullToRefreshView setCurrentDate];
        [UIView setAnimationDuration:0.3];
        [self.tableView setContentInset:UIEdgeInsetsZero];
    }

    [UIView commitAnimations];
}

// Override this method
// 子类的此方法中，要在数据加载结束后把loadingMore设为NO
- (void)loadMore {
    NSLog(@"loadMore : You must override this method in subclass. If this log appears, there is a mistake.");
}

- (BOOL)isLoadMoreViewCanDisplay {    
    return (!self.endReached && self.items.count > 0);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.forbidRefreshAndLoadMoreSimultaneously) {
        if ([keyPath isEqualToString:@"refreshing"]) {
            if ([change[@"new"] boolValue]) { // refreshing = YES
                if ([self.tableView numberOfSections] == 2) {
                    [self.tableView beginUpdates];
                    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView endUpdates];
                }
            } else { // refreshing = NO
                if ([self isLoadMoreViewCanDisplay] && [self.tableView numberOfSections] == 1) {
                    [self.tableView beginUpdates];
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView endUpdates];
                }
            }
        } else if ([keyPath isEqualToString:@"loadingMore"]) {
            if ([change[@"new"] boolValue]) { // loadingMore = YES
                self.pullToRefreshView.hidden = YES;
            } else { // loadingMore = NO
                self.pullToRefreshView.hidden = NO;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.endReached             // 数据已经全部加载完，不显示上拉加载更多
        || self.items.count == 0    // 当没有数据时，不显示上拉加载更多
        || (self.forbidRefreshAndLoadMoreSimultaneously && self.refreshing)) { 
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 1;
    }
    return self.items.count;
}

// override this method in subclass
// 子类的此方法中，如果indexPath.section == 1，要调用父类的此方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        static NSString *CellIdentifier = @"LoadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (self.loadMoreView == nil) {
            self.loadMoreView = [[NSBundle mainBundle] loadNibNamed:@"DLLoadMoreView" owner:self options:nil][0];
            [cell.contentView addSubview:self.loadMoreView];
        }
        
        if (self.loadingMore) {
            [self.loadMoreView setState:DLLoadMoreStateLoading];
        } else {
            [self.loadMoreView setState:DLLoadMoreStateNormal];
        }
        
        return cell;
    }

    // should never reach here
    return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 50;
    } else {
        return 44;
    }
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullToRefreshView.state == DLPullRefreshLoading) {
        
    } else if (scrollView.isDragging) {
        if (self.pullToRefreshView.state == DLPullRefreshPulling
            && (scrollView.contentOffset.y > -65.0 && scrollView.contentOffset.y < 0.0)) {
            [self.pullToRefreshView setState:DLPullRefreshNormal];
        } else if (self.pullToRefreshView.state == DLPullRefreshNormal && scrollView.contentOffset.y < -65.0) {
            [self.pullToRefreshView setState:DLPullRefreshPulling];
        }
        
        if (!self.loadingMore) {
            if (self.loadMoreView.state == DLLoadMoreStateNormal
                && (scrollView.contentOffset.y >= (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame)) + 65.0f)) {
                [self.loadMoreView setState:DLLoadMoreStateDraging];
            } else {
                [self.loadMoreView setState:DLLoadMoreStateNormal];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y <= -65.0
        && !self.refreshing // 防止重复操作
        && (!self.forbidRefreshAndLoadMoreSimultaneously || (self.forbidRefreshAndLoadMoreSimultaneously && !self.loadingMore))) {
        self.refreshing = YES;
        [self.pullToRefreshView setState:DLPullRefreshLoading];        
        [self doRefresh];
    }
    
    if (scrollView.contentOffset.y >= (scrollView.contentSize.height - CGRectGetHeight(scrollView.frame)) + 65.0f
        && !self.endReached && self.items.count > 0
        && !self.loadingMore // 防止重复操作
        && (!self.forbidRefreshAndLoadMoreSimultaneously || (self.forbidRefreshAndLoadMoreSimultaneously && !self.refreshing))) {
        self.loadingMore = YES;
        [self.loadMoreView setState:DLLoadMoreStateLoading];
        [self loadMore];
    }
}

@end
