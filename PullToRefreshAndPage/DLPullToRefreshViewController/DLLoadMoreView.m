//
//  DLLoadMoreView.m
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import "DLLoadMoreView.h"

@interface DLLoadMoreView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end

@implementation DLLoadMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setState:(DLLoadMoreState)state {
    switch (state) {
        case DLLoadMoreStateNormal:
            self.statusLabel.text = @"上拉加载更多";
            [self.activityIndicatorView stopAnimating];
            break;
        case DLLoadMoreStateDraging:
            self.statusLabel.text = @"释放立即加载";
            [self.activityIndicatorView stopAnimating];
            break;
        case DLLoadMoreStateLoading:
            self.statusLabel.text = @"加载中...";
            [self.activityIndicatorView startAnimating];
            break;
            
        default:
            break;
    }
}

@end
