//
//  PARNCallIKitConfig.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PARNCallIKitConfig : NSObject

//系统来电页面显示的app名称和系统通讯记录的信息
@property(nonatomic, strong) NSString *localizedName;

//来电铃声
@property(nonatomic, strong) NSString *ringtoneSound;
//锁屏接听时，系统界面右下角的app图标，要求40 x 40大小
@property(nonatomic, strong) NSData *iconTemplateImageData;

//最大通话组
@property(nonatomic, assign) NSUInteger maximumCallGroups; // Default 2

//是否支持视频
@property(nonatomic, assign) BOOL supportsVideo; // Default NO

//支持的Handle类型
@property(nonatomic, strong) NSSet<NSNumber *> *supportedHandleTypes;

@end

NS_ASSUME_NONNULL_END
