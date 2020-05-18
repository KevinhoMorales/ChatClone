//
//  Device.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.

#import "Device.h"

@implementation Device

+ (BOOL)isIphone6
{
    CGSize rectSize = [UIScreen mainScreen].bounds.size;
    return rectSize.width == 375.0f;
}

+ (BOOL)isIphone6Plus
{
    CGSize rectSize = [UIScreen mainScreen].bounds.size;
    return rectSize.width == 414.0f;
}

@end
