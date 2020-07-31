//
//  CRJVoIPPushManager.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CRJVoIPPushManager : NSObject
/// 注册VoIP服务  不需要VoIP服务，或者要上架App Store的请移除该文件
/// @param VoIPMessageBlock VoIP消息回调
+ (void)registryVoIPWithVoIPMessageBlock:(void (^)(PKPushRegistry *registry, PKPushPayload *payload,  NSString * _Nullable type))VoIPMessageBlock;
                                        
@end

NS_ASSUME_NONNULL_END
