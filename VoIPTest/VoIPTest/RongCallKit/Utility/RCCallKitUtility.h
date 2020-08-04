//
//  RCCallKitUtility.h
//  VoIPTest
//
//  Created by zhuyuhui on 2020/8/4.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RCStatusDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCCallKitUtility : NSObject
+ (NSString *)getReadableStringForTime:(long)sec;

+ (UIImage *)getScaleImage:(UIImage *)image size:(CGSize)size;

+ (UIColor *)getScaleImageColor:(UIImage *)image size:(CGSize)size;

//+ (UIImage *)imageFromVoIPBundle:(NSString *)imageName;
//
//+ (UIImage *)getDefaultPortraitImage;
//
//+ (NSString *)getReadableStringForMessageCell:(RCCallDisconnectReason)hangupReason;
//
//+ (NSString *)getReadableStringForCallViewController:(RCCallDisconnectReason)hangupReason;

+ (BOOL)isLandscape;

+ (void)setScreenForceOn;
+ (void)clearScreenForceOnStatus;
+ (void)checkSystemPermission:(RCCallMediaType)mediaType success:(void (^)(void))successBlock error:(void (^)(void))errorBlock;
+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2;

@end

NS_ASSUME_NONNULL_END
