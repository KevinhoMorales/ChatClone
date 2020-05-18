//
//  ChatUtils.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatUtils : NSObject

+ (NSString *)messageTextForNotification:(QBChatMessage *)notification;
+ (NSString *)messageTextForPushWithNotification:(QBChatMessage *)notification;
+ (NSString *)idsStringWithoutSpaces:(NSArray *)users;
+ (NSString *)messageForText:(NSString *)text participants:(NSArray *)participants;

@end
