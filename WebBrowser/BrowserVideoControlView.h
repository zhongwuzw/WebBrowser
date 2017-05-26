//
//  BrowserVideoControlView.h
//  WebBrowser
//
//  Created by 钟武 on 2017/5/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class BrowserVideoView;

@interface BrowserVideoControlView : UIView

@property (nonatomic, weak) BrowserVideoView *videoView;

- (void)setPlayPauseIfNeeded:(BOOL)isPause;
- (void)updateControlWithCMTime:(CMTime)newDuration currentTime:(CMTime)currentTime;
- (void)updateCurrentTime:(CMTime)currentTime;

@end
