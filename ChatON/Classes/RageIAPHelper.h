//
//  QMRageIAPHelper.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"

UIKIT_EXTERN NSString *const kSubscriptionExpirationDateKey;

@interface RageIAPHelper :IAPHelper

+ (RageIAPHelper *)sharedInstance;

@end
