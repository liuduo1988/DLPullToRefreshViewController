//
//  DLPullToRefreshView.m
//  PullToRefreshAndPage
//
//  Created by Derek Liu on 13-9-2.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import "DLPullToRefreshView.h"
#import <QuartzCore/QuartzCore.h>

@interface DLPullToRefreshView ()
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@end

@implementation DLPullToRefreshView {
    NSString *_keyNameForDataStore;
}

static NSDateFormatter *refreshFormatter;

+ (void)initialize {
    /* Formatter for last refresh date */
    refreshFormatter = [[NSDateFormatter alloc] init];
    [refreshFormatter setDateFormat:@"yyyy.MM.dd HH:mm"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setKeyNameForDataStore:[NSString stringWithFormat:@"%@_LastRefresh", [self class]]];
}

- (void)setKeyNameForDataStore:(NSString *)theKeyNameForDataStore {
    if (_keyNameForDataStore != theKeyNameForDataStore) {
        _keyNameForDataStore = [theKeyNameForDataStore copy];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:_keyNameForDataStore]) {
			self.lastUpdatedLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:_keyNameForDataStore];
		} else {
			self.lastUpdatedLabel.text = @"上次更新：从未更新";
		}
    }
}

//- (void)setLastRefreshDate:(NSDate*)date {
//    if (!date) {
//        [self.lastUpdatedLabel setText:@"无上次更新时间"];
//        return;
//    }
//    
//	self.lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", [refreshFormatter stringFromDate:date]];
//}

- (void)setCurrentDate {
	self.lastUpdatedLabel.text = [NSString stringWithFormat:@"上次更新: %@", [refreshFormatter stringFromDate:[NSDate date]]];
	[[NSUserDefaults standardUserDefaults] setObject:self.lastUpdatedLabel.text forKey:_keyNameForDataStore];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setState:(DLPullRefreshState)state {
    switch (state) {
        case DLPullRefreshPulling:
            self.statusLabel.text = @"释放立即更新...";
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.18];
            self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            [UIView commitAnimations];
            break;
            
        case DLPullRefreshNormal:
            if (_state == DLPullRefreshPulling) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.18];
                self.arrowImageView.transform = CGAffineTransformIdentity;
                [UIView commitAnimations];
            }
            self.statusLabel.text = @"下拉以更新";
            [self.activityIndicatorView stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            self.arrowImageView.hidden = NO;
            self.arrowImageView.layer.transform = CATransform3DIdentity;
            [CATransaction commit];
            break;
            
        case DLPullRefreshLoading:
            self.statusLabel.text = @"加载中...";
			[self.activityIndicatorView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			self.arrowImageView.hidden = YES;
			[CATransaction commit];
            break;
            
        case DLPullRefreshUpToDate:
            self.statusLabel.text = @"Up-to-date.";
			[self.activityIndicatorView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			self.arrowImageView.hidden = YES;
			[CATransaction commit];
            break;
            
        default:
            break;
    }
    
    _state = state;
}

@end
