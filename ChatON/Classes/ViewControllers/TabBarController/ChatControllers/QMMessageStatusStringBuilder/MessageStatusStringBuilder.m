//
//  MessageStatusStringBuilder.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "MessageStatusStringBuilder.h"
#import "QBApi.h"

@implementation MessageStatusStringBuilder

- (NSString *)statusFromMessage:(QBChatMessage *)message
{
    NSNumber* currentUserID = @([QMApi instance].currentUser.ID);
    
    NSMutableArray* readIDs = [message.readIDs mutableCopy];
    [readIDs removeObject:currentUserID];
    
    NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:currentUserID];
    
    [deliveredIDs removeObjectsInArray:readIDs];
    
    if (readIDs.count > 0 || deliveredIDs.count > 0) {
        NSMutableString* statusString = [NSMutableString string];

        if (readIDs.count > 0) {
            if (message.attachments.count > 0) {
                readIDs.count > 1 ? [statusString appendFormat:@"Seen: %lu", (unsigned long)readIDs.count] : [statusString appendFormat:@"Seen"];
            } else {
                readIDs.count > 1 ? [statusString appendFormat:@"Read: %lu", (unsigned long)readIDs.count] : [statusString appendFormat:@"Read"];
            }
        }

        if (deliveredIDs.count > 0) {
            if (readIDs.count > 0) [statusString appendString:@"\n"];
            deliveredIDs.count > 1 ? [statusString appendFormat:@"Delivered: %lu", (unsigned long)deliveredIDs.count] : [statusString appendFormat:@"Delivered"];
        }
        
        return [statusString copy];
    }
    return @"Sent";
}

@end
