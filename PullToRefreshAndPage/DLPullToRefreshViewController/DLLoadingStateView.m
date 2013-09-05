//
//  LoadingStateView.m
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-5.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import "DLLoadingStateView.h"

@interface DLLoadingStateView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@end

@implementation DLLoadingStateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setState:(DLLoadingViewState)state {
    _state = state;
    
    UITableView *tableView = (UITableView *)self.superview;
    
    switch (state) {
        case DLLoadingViewStateLoading:
            self.hidden = NO;
            [self.activityIndicatorView startAnimating];
            self.loadingLabel.hidden = NO;
            self.tipLabel.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.scrollEnabled = NO;
            break;
        case DLLoadingViewStateWithoutData:
            self.hidden = NO;
            [self.activityIndicatorView stopAnimating];
            self.loadingLabel.hidden = YES;
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"无数据";
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.scrollEnabled = NO;
            break;
        case DLLoadingViewStateFail:
            self.hidden = NO;
            [self.activityIndicatorView stopAnimating];
            self.loadingLabel.hidden = YES;
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"加载失败";
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.scrollEnabled = NO;
            break;
        case DLLoadingViewStateHide:
            self.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.scrollEnabled = YES;
            break;
            
        default:
            break;
    }
}

- (BOOL)isVisible {
    NSLog(@"当前状态: %d", self.state);
    return (self.state != DLLoadingViewStateHide);
}

@end
