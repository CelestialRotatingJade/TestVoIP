//
//  CRJAudioManager.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 用来管理音频，铃声的播放。
 */
@interface CRJAudioManager : NSObject

+ (instancetype)shared;

- (void)configureAudioSession;

- (void)startAudio;

- (void)stopAudio;

@end

NS_ASSUME_NONNULL_END
