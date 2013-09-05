//
//  DLLoadMoreView.h
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DLLoadMoreState) {
    DLLoadMoreStateNormal,
    DLLoadMoreStateDraging,
    DLLoadMoreStateLoading
};

@interface DLLoadMoreView : UIView

@property (nonatomic, assign) DLLoadMoreState state;

@end
