//
//  CRJAudioManager.m
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import "CRJAudioManager.h"
#import <AVFoundation/AVFoundation.h>
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
#ifdef DEBUG
    NSLog(@"[RNCallKit][configureAudioSession] Activating audio session");
#endif
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
#ifdef DEBUG
    NSLog(@"[RNCallKit][startAudio] startAudio");
#endif
}

- (void)stopAudio {
#ifdef DEBUG
    NSLog(@"[RNCallKit][stopAudio] stopAudio");
#endif
}

@end
