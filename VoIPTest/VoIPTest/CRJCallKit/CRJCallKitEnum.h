//
//  CRJCallKitEnum.h
//  VoIPTest
//
//  Created by 朱玉辉(EX-ZHUYUHUI001) on 2020/7/31.
//  Copyright © 2020 oopsr. All rights reserved.
//

#ifndef CRJCallKitEnum_h
#define CRJCallKitEnum_h

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, CRJCallState) {
    CRJCallStateConnecting,
    CRJCallStateActive,
    CRJCallStateHeld,
    CRJCallStateEnded,
    CRJCallStateMuted
};

typedef NS_ENUM(NSUInteger, CRJCallConnectedState) {
    CRJCallConnectedStatePending,
    CRJCallConnectedStateComplete,
};


#endif /* CRJCallKitEnum_h */
