//
//  BrowserVideoView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BrowserVideoView.h"
#import "BrowserVideoPlayerView.h"
#import "BrowserVideoControlView.h"

#import <AVFoundation/AVFoundation.h>

static int BrowserVideoViewKVOContext = 0;
CGFloat const BrowserVideoViewWidth = 300.f;
CGFloat const BrowserVideoViewHeight = 168.f;

@interface BrowserVideoView ()

@property (nonatomic, readonly) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) BrowserVideoPlayerView *playerView;
@property (nonatomic, strong) BrowserVideoControlView *controlView;
@property (nonatomic, strong) id timeObserverToken;
@property (nonatomic, assign) CMTime currentTime;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) CGPoint lastScalePoint;
@property (nonatomic, assign) CGPoint lastPanPoint;

@end

@implementation BrowserVideoView

@synthesize player = _player, playerItem = _playerItem;

- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super initWithFrame:CGRectZero]) {
        [self addObserver];
        [self initPlayerWithURL:url];
        [self addGesture];
    }
    return self;
}

- (void)addObserver{
    [self addObserver:self forKeyPath:@"asset" options:NSKeyValueObservingOptionNew context:&BrowserVideoViewKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&BrowserVideoViewKVOContext];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&BrowserVideoViewKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&BrowserVideoViewKVOContext];
}

- (void)addGesture{
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:_pinchGesture];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:_panGesture];
}

- (void)initPlayerWithURL:(NSURL *)url{
    if (!url) {
        return;
    }
    
    self.backgroundColor = [UIColor blackColor];
    self.playerView = [BrowserVideoPlayerView new];
    [self addSubview:self.playerView];
    [self.playerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_playerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_playerView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_playerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_playerView)]];
    
    self.controlView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([BrowserVideoControlView class]) owner:self options:nil] lastObject];
    self.controlView.videoView = self;
    [self addSubview:self.controlView];
    [self.controlView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_controlView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_controlView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_controlView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_controlView)]];
    
    self.closeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:button];
        [button addTarget:self action:@selector(handleCloseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:@"video_close"] forState:UIControlStateNormal];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
        
        button;
    });
    
    self.playerView.playerLayer.player = self.player;
    self.asset = [AVURLAsset assetWithURL:url];
    
    WEAK_REF(self)
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
        STRONG_REF(self_)
        if (self__) {
            [self__.controlView updateCurrentTime:time];
        }
    }];
}

#pragma mark - Handle Close Button

- (void)handleCloseButtonClicked:(UIButton *)btn{
    [self removeFromSuperview];
}

#pragma mark - Gesture

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastScale = 1.0f;
        self.lastScalePoint = [gesture locationInView:self];
    }
    
    CGFloat scale = 1.0f - (self.lastScale - gesture.scale);
    DDLogDebug(@"scale is %f",gesture.scale);
}

- (void)handlePanGesture:(UIPinchGestureRecognizer *)gesture{
    CGPoint point = [gesture locationInView:self.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastPanPoint = point;
    }
    else{
        CGFloat xDelta = point.x - self.lastPanPoint.x;
        CGFloat yDelta = point.y - self.lastPanPoint.y;
        
        self.center = CGPointMake(self.centerX + xDelta, self.centerY + yDelta);
        
        self.lastPanPoint = point;
    }
}

#pragma mark - Getter/Setter

- (void)setURL:(NSURL *)url{
    self.asset = [AVURLAsset assetWithURL:url];
}

- (AVPlayer *)player{
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}

+ (NSArray *)assetKeysRequiredToPlay {
    return @[ @"playable", @"hasProtectedContent" ];
}

- (CMTime)currentTime {
    return self.player.currentTime;
}
- (void)setCurrentTime:(CMTime)newCurrentTime {
    [self.player seekToTime:newCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (CMTime)duration {
    return self.player.currentItem ? self.player.currentItem.duration : kCMTimeZero;
}

- (AVPlayerLayer *)playerLayer {
    return self.playerView.playerLayer;
}

- (AVPlayerItem *)playerItem{
    return _playerItem;
}

- (void)setPlayerItem:(AVPlayerItem *)newPlayerItem {
    if (_playerItem != newPlayerItem) {
        
        _playerItem = newPlayerItem;
        
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

- (void)setPlayOrPause:(BOOL)isPause{
    if (isPause) {
        [self.player pause];
    }
    else{
        if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
            self.currentTime = kCMTimeZero;
        }
        [self.player play];
    }
}

- (void)updateCurrentTime:(float)value{
    self.currentTime = CMTimeMakeWithSeconds(value, 1000);
}

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {
    [newAsset loadValuesAsynchronouslyForKeys:BrowserVideoView.assetKeysRequiredToPlay completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (newAsset != self.asset) {
                return;
            }
            
            for (NSString *key in self.class.assetKeysRequiredToPlay) {
                if ([newAsset statusOfValueForKey:key error:nil] == AVKeyValueStatusFailed) {
                    return;
                }
            }
            
            if (!newAsset.playable || newAsset.hasProtectedContent) {
                return;
            }
            
            self.playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
        });
    }];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context != &BrowserVideoViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"asset"]) {
        if (self.asset) {
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }
    else if ([keyPath isEqualToString:@"player.currentItem.duration"]) {
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        
        [self.controlView updateControlWithCMTime:newDuration currentTime:self.currentTime];
        
    }
    else if ([keyPath isEqualToString:@"player.rate"]) {
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        [self.controlView setPlayPauseIfNeeded:(newRate == 1.0f)];
    }
    else if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            DDLogError(@"AVPlayer error");
        }
        else if (newStatus == AVPlayerItemStatusReadyToPlay){
            [self.player play];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"duration"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.duration" ]];
    } else if ([key isEqualToString:@"currentTime"]) {
        return [NSSet setWithArray:@[ @"player.currentItem.currentTime" ]];
    } else {
        return [super keyPathsForValuesAffectingValueForKey:key];
    }
}

#pragma mark - Hit Test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        CGPoint p = [self.closeButton convertPoint:point fromView:self];
        if (CGRectContainsPoint(self.closeButton.bounds, p)) {
            view = self.closeButton;
        }
    }
    return view;
}

#pragma mark - Touch Events


#pragma mark - Dealloc

- (void)dealloc{
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    [self removeObserver:self forKeyPath:@"asset" context:&BrowserVideoViewKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.duration" context:&BrowserVideoViewKVOContext];
    [self removeObserver:self forKeyPath:@"player.rate" context:&BrowserVideoViewKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:&BrowserVideoViewKVOContext];
}

@end
