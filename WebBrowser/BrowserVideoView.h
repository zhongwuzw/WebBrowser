//
//  BrowserVideoView.h
//  WebBrowser
//
//  Created by 钟武 on 2017/5/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayerItem, AVPlayer;

extern CGFloat const BrowserVideoViewWidth;
extern CGFloat const BrowserVideoViewHeight;

@interface BrowserVideoView : UIView

@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic, readonly) AVPlayer *player;

- (instancetype)initWithURL:(NSURL *)url;
- (void)setURL:(NSURL *)url;
- (void)setPlayOrPause:(BOOL)isPause;
- (void)updateCurrentTime:(float)value;

@end
