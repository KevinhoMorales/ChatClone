//
//  RageIAPHelper.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.

#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import <Quickblox/Quickblox.h>
#import "QBApi.h"


@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance {
    static dispatch_once_t once = 0;
    static RageIAPHelper *sharedInstance = nil;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      
                                      @"com.heelo.inapprage.12monthlyrageface",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


@end
