//
//  PARNCallKit.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CallKit/CallKit.h>
#import <Intents/Intents.h>

NS_ASSUME_NONNULL_BEGIN

@interface PARNCallKit : NSObject<CXProviderDelegate>

@property (nonatomic, strong) CXCallController *callKitCallController;
@property (nonatomic, strong) CXProvider *callKitProvider;

+ (instancetype)shareManager;

- (void)setup:(NSDictionary *)options;



+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options NS_AVAILABLE_IOS(9_0);

+ (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
  restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler;


@end

NS_ASSUME_NONNULL_END
