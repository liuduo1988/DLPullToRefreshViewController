//
//  DLPullToRefreshView.h
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DLPullRefreshState) {
    DLPullRefreshPulling = 0,
	DLPullRefreshNormal,
	DLPullRefreshLoading,
	DLPullRefreshUpToDate,
};

@interface DLPullToRefreshView : UIView

@property (nonatomic, assign) DLPullRefreshState state;

- (void)setCurrentDate;

@end
