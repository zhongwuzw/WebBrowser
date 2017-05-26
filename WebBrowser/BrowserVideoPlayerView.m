//
//  BrowserVideoPlayerView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BrowserVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation BrowserVideoPlayerView

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
