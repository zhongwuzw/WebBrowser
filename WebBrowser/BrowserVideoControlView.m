//
//  BrowserVideoControlView.m
//  WebBrowser
//
//  Created by 钟武 on 2017/5/25.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "BrowserVideoControlView.h"
#import "BrowserVideoView.h"

#import <AVFoundation/AVFoundation.h>

@interface BrowserVideoControlView ()

@property (weak, nonatomic) IBOutlet UIButton *pausePlayButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@end

@implementation BrowserVideoControlView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.currentTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.totalTimeLabel.adjustsFontForContentSizeCategory = YES;
}

- (void)setPlayPauseIfNeeded:(BOOL)isPause{
    [self.pausePlayButton setImage:isPause ? [UIImage imageNamed:@"video_pause"] : [UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
}

- (IBAction)playPauseButtonWasPressed:(UIButton *)sender {
    BOOL isPause = NO;
    
    if (self.videoView.player.rate == 1.0f){
        isPause = YES;
    }
    
    [self setPlayPauseIfNeeded:isPause];
    [self.videoView setPlayOrPause:isPause];
}

- (void)updateControlWithCMTime:(CMTime)newDuration currentTime:(CMTime)currentTime{
    BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
    double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
    
    self.progressSlider.maximumValue = newDurationSeconds;
    self.progressSlider.value = hasValidDuration ? CMTimeGetSeconds(currentTime) : 0.0;
    self.pausePlayButton.enabled = hasValidDuration;
    self.progressSlider.enabled = hasValidDuration;
    self.currentTimeLabel.enabled = hasValidDuration;
    self.totalTimeLabel.enabled = hasValidDuration;
    int wholeMinutes = (int)trunc(newDurationSeconds / 60);
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(newDurationSeconds) - wholeMinutes * 60];
}

- (void)updateCurrentTime:(CMTime)currentTime{
    BOOL hasValidTime = CMTIME_IS_NUMERIC(currentTime) && currentTime.value != 0;
    double newTimeSeconds = hasValidTime ? CMTimeGetSeconds(currentTime) : 0.0;
    
    self.progressSlider.value = hasValidTime ? CMTimeGetSeconds(currentTime) : 0.0;
    self.pausePlayButton.enabled = hasValidTime;
    self.progressSlider.enabled = hasValidTime;
    self.currentTimeLabel.enabled = hasValidTime;
    self.currentTimeLabel.enabled = hasValidTime;
    int wholeMinutes = (int)trunc(newTimeSeconds / 60);
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, (int)trunc(newTimeSeconds) - wholeMinutes * 60];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self.videoView updateCurrentTime:sender.value];
}

@end
