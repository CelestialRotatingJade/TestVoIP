//
//  CRJProviderDelegate.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>
#import <UIKit/UIKit.h>
#import <Intents/Intents.h>
NS_ASSUME_NONNULL_BEGIN

@interface CRJProviderDelegate : NSObject<CXProviderDelegate>

+ (instancetype)shared;

- (void)setup:(NSDictionary *)options;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_AVAILABLE_IOS(9_0);

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
  restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler;


//这个方法需要在所有接电话的地方手动调用，需要根据自己的业务逻辑来判断。还有就是不要忘了iOS的版本兼容哦。。
- (void)reportIncomingCall:(NSUUID *)uuid
                    handle:(NSString *)handle
                  hasVideo:(BOOL)hasVideo
                completion:(void (^)(NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
