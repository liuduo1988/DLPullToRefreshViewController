//
//  ViewController.m
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import "ViewController.h"
#import "DLLoadingStateView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"DLPullToRefreshViewController";
    
    self.forbidRefreshAndLoadMoreSimultaneously = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startLoadData)];
    
    [self startLoadData];
    
    self.loadingStateView.state = DLLoadingViewStateLoading;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareMockData {
    [self.items removeAllObjects];
    self.pageIndex = 0;
    
    for (NSInteger i = 0; i < arc4random() % 2; i++) {
        [self.items addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

- (NSArray *)getDataAtPageIndex:(NSUInteger)pageIndex {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:NumberOfItemsPerPage];
    for (NSInteger i = pageIndex * NumberOfItemsPerPage; i < pageIndex * NumberOfItemsPerPage + NumberOfItemsPerPage; i++) {
        [result addObject:[NSString stringWithFormat:@"%d", i]];
        
        if (i == 35) {
            return result;
        }
    }
    return result;
}

- (void)doRefresh {
    self.endReached = NO;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self prepareMockData];
        if (self.items.count < NumberOfItemsPerPage) {
            self.endReached = YES;
        }
        if (self.items.count == 0) {
            self.loadingStateView.state = DLLoadingViewStateWithoutData;
        } else {
            self.loadingStateView.state = DLLoadingViewStateHide;
        }
        [self.tableView reloadData];
        self.refreshing = NO;
//        [self firstLoadingEnd];
    });
}

- (void)loadMore {
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.pageIndex++;
        NSArray *moreDatas = [self getDataAtPageIndex:self.pageIndex];
        if (moreDatas.count < NumberOfItemsPerPage) {
            self.endReached = YES;
        }
        [self.items addObjectsFromArray:moreDatas];
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = self.items.count - moreDatas.count; i < self.items.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        if (self.endReached) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationBottom];
        }
        [self.tableView endUpdates];
        
        self.loadingMore = NO;
    });
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    
    return cell;
}

@end
