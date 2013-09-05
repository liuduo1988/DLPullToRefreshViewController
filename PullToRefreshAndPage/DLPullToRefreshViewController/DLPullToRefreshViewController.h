//
//  DLPullToRefreshViewController.h
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLLoadingStateView;

const static NSUInteger NumberOfItemsPerPage = 10; // 每页条数

@interface DLPullToRefreshViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *items; // 表数据

@property (nonatomic, assign) BOOL showFirstLoadingView; // 第一次进入界面加载数据时隐藏TableView，直到加载成功
@property (nonatomic, assign) BOOL forbidRefreshAndLoadMoreSimultaneously; // 禁止同时进行下拉刷新和上拉加载更多操作（同一时刻只能存在一个操作）

#pragma mark - 首次加载相关

@property (nonatomic, strong) DLLoadingStateView *loadingStateView;

- (void)addLoadingStateView;

- (void)loadingSuccess;

- (void)loadingFail;

#pragma mark - 下拉刷新相关

@property (nonatomic, assign) BOOL refreshing; // 是否下拉刷新中

/**
 * Must override this method in subclass.
 */
- (void)doRefresh;

- (void)startLoadData;

#pragma mark - 上拉分页相关

@property (nonatomic, assign) NSUInteger pageIndex; // 当前页码
@property (nonatomic, assign) BOOL loadingMore; // 是否上拉加载更多中
@property (nonatomic, assign) BOOL endReached; // 是否已经到底（数据已经全加载完）

/**
 * Must override this method in subclass.
 */
- (void)loadMore;

@end
