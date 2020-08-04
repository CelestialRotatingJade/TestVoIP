//
//  ViewController.m
//  VoIPTest
//
//  Created by Tg W on 17/2/21.
//  Copyright © 2017年 oopsr. All rights reserved.
//

#import "ViewController.h"
#import "CRJProviderDelegate.h"
#import "CRJCallKitManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[CRJProviderDelegate shared] setup:@{
        @"appName":@"VoIPTest",
        @"imageName":@"icon_audio_bank_small",
        @"ringtoneSound":@"voip_call.caf",
    }];
    
    
    NSDictionary *dictionaryPayload = @{
        @"UUID":@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
        @"handle":@"18515353943",
        @"":@(NO),
    };

    NSString *uuidString = dictionaryPayload[@"UUID"];
    NSString *handle = dictionaryPayload[@"handle"];
    NSNumber *hasVideo = dictionaryPayload[@"hasVideo"];

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    [[CRJCallKitManager shared] startCall:@"zhangsan_voip" video:YES];
    
    
//    [[CRJProviderDelegate shared] reportIncomingCall:uuid
//                                              handle:handle
//                                            hasVideo:hasVideo
//                                          completion:^(NSError *_Nonnull error){
//
//                                          }];
    
    
}

@end
