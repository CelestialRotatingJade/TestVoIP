//
//  AppDelegate.m
//  VoIPTest
//
//  Created by Tg W on 17/2/21.
//  Copyright © 2017年 oopsr. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoTalkManager.h"
#import "PARNCallKit.h"
#import "CRJVoIPPushManager.h"
#import "CRJProviderDelegate.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //注册VoIp
//    [[VideoTalkManager sharedClinet] initWithSever];
    
    ///
    [CRJVoIPPushManager registryVoIPWithVoIPMessageBlock:^(PKPushRegistry * _Nonnull registry, PKPushPayload * _Nonnull payload, NSString * _Nullable type) {
        
    }];
    
    
    // app关闭时，收到推送， 程序未启动，退出状态(如果是点击推送消息进入应用，launchOptions 会包含推送消息的内容。如果是点击图标进入则 launchOptions 不包含)
    if (launchOptions) {
        NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if (userInfo) {
           //TODO...
            
        }
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken

}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    [[CRJProviderDelegate shared] application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    return [PARNCallKit application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

//应用在后台挂起时，点击消息进入应用也会执行下面的方法。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    [JPUSHService setBadge:0];
//    [JPUSHService handleRemoteNotification:userInfo];
    if (application.applicationState == UIApplicationStateActive) {
          //如果是在前台运行，可以将推送消息转换为本地推送消息，实现类似远程推送的效果
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    } else if (application.applicationState == UIApplicationStateInactive){
       //如果是在后台挂起，用户点击进入是UIApplicationStateInactive这个状态
       // TODO...
        
    }
    // 这个方法必须调用
    completionHandler(UIBackgroundFetchResultNewData);
}

/*
 iOS 10 之后，接受推送消息的方法变为：
 iOS 10 的远程推送消息不在区分应用的状态了。无论当应用是在前台运行还是后台挂起状态，当接收到推送消息时，
 都会以横幅的形式提示用户（挂起时屏幕未锁定是横幅提示，屏幕锁定就会在通知中心里面），所以用户点击消息的
 处理可以放在一起不用再区分状态。

 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}



@end
