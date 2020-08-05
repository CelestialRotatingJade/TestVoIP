//
//
//CallPermissions.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CRJCallKitEnum.h"
NS_ASSUME_NONNULL_BEGIN

@interface CallPermissions : NSObject

+ (void)checkPermissionsWithConferenceType:(CRJCConferenceType)conferenceType
                                completion:(PermissionBlock)completion;

@end

NS_ASSUME_NONNULL_END
