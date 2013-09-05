//
//  LoadingStateView.h
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-5.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DLLoadingViewState) {
    DLLoadingViewStateLoading = 0,
    DLLoadingViewStateWithoutData,
    DLLoadingViewStateFail,
    DLLoadingViewStateHide
};

@interface DLLoadingStateView : UIView

@property (nonatomic, assign) DLLoadingViewState state;

- (BOOL)isVisible;

@end
