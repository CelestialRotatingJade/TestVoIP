//
//  CRJAudioManager.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJAudioManager.h"
#import "CRJCallKitEnum.h"
#import <AVFoundation/AVFoundation.h>

@interface CRJAudioManager ()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation CRJAudioManager

+ (instancetype)shared {
    static CRJAudioManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CRJAudioManager alloc] init];
    });
    return instance;
}

- (void)configureAudioSession {
    CRJCallKitLog(@"configureAudioSession");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setMode:AVAudioSessionModeVoiceChat error:nil];

    double sampleRate = 44100.0;
    [audioSession setPreferredSampleRate:sampleRate error:nil];

    NSTimeInterval bufferDuration = .005;
    [audioSession setPreferredIOBufferDuration:bufferDuration error:nil];
    [audioSession setActive:TRUE error:nil];
}

- (void)startAudio {
    CRJCallKitLog(@"startAudio...");
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playkSystemSound) userInfo:nil repeats:YES];
}

- (void)stopAudio {
    CRJCallKitLog(@"stopAudio...");
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
}

//振动
- (void)playkSystemSound{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
