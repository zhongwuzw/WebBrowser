//
//  BrowserVideoPlayerView.h
//  WebBrowser
//
//  Created by 钟武 on 2017/5/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer, AVPlayerLayer;

@interface BrowserVideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, readonly) AVPlayerLayer *playerLayer;

@end
