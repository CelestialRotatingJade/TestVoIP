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

NS_ASSUME_NONNULL_BEGIN

@interface CRJProviderDelegate : NSObject<CXProviderDelegate>

+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
