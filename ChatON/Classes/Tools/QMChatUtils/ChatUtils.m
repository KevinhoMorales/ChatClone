//
//  ChatUtils.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ChatUtils.h"
#import "QBApi.h"

@implementation ChatUtils


+ (NSString *)messageTextForNotification:(QBChatMessage *)notification
{
    NSString *messageText = nil;
    QBUUser *sender = [[QMApi instance] userWithID:notification.senderID];
    QBUUser *recipient = [[QMApi instance] userWithID:notification.recipientID];
    
    switch (notification.messageType) {
        case QMMessageTypeContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ?  NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_ME",nil) : [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", @"{FullName}"), sender.fullName];
        }
            break;
            
        case QMMessageTypeAcceptContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ? NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_ME", nil) : NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_OPPONENT", nil);
        }
            break;
            
        case QMMessageTypeRejectContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ? NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_ME",nil) : NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_OPPONENT", nil);
        }
            break;
            
        case QMMessageTypeDeleteContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ?
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_ME", @"{FullName}"), recipient.fullName] :
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_OPPONENT", @"{FullName}"), sender.fullName];
        }
            break;
            
        case QMMessageTypeCreateGroupDialog:
        {
#warning not in use
            NSArray *users = [[QMApi instance] usersWithIDs:notification.dialog.occupantIDs];
            QBUUser *currentUser = [[QMApi instance] userWithID:notification.senderID];
            for (QBUUser *usr in users) {
                if (usr.ID == currentUser.ID) {
                    currentUser = usr;
                    break;
                }
            }
            
            NSMutableArray *usersArray = [users mutableCopy];
            [usersArray removeObject:currentUser];
            
            NSString *fullNameString = [self fullNamesString:usersArray];
            messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", nil), sender.fullName, fullNameString];
        }
            break;
        default:
            break;
    }
    return messageText;
}

+ (NSString *)messageTextForPushWithNotification:(QBChatMessage *)notification
{
    NSString *message = nil;
    QBUUser *sender = [[QMApi instance] userWithID:notification.senderID];
    if (notification.messageType == QMMessageTypeContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", @"{FullName}"), sender.fullName];
    } else if (notification.messageType == QMMessageTypeAcceptContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_PUSH", @"{FullName}"), sender.fullName];
    } else if (notification.messageType == QMMessageTypeRejectContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_PUSH", @"{FullName}"), sender.fullName];
    } else if (notification.messageType == QMMessageTypeDeleteContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_OPPONENT", @"{FullName}"), sender.fullName];
    }
    
    return message;
}

+ (NSString *)fullNamesString:(NSArray *)users
{
    if (users.count == 0) {
        return @"Unknown users";
    }
    NSMutableString *mutableString = [NSMutableString new];
    for (QBUUser *usr in users) {
        [mutableString appendString:usr.fullName];
        [mutableString appendString:@", "];
    }
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 2, 2)];
    return mutableString;
}

+ (NSString *)idsStringWithoutSpaces:(NSArray *)users
{
    NSMutableString *mutableString = [NSMutableString new];
    for (QBUUser *usr in users) {
        [mutableString appendString:[NSString stringWithFormat:@"%lu", (unsigned long)usr.ID]];
        [mutableString appendString:@","];
    }
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 1, 1)];
    return mutableString;
}

+ (NSString *)messageForText:(NSString *)text participants:(NSArray *)participants
{
    NSString *addedUsersNames = [self fullNamesString:participants];
    return [NSString stringWithFormat:text, [QMApi instance].currentUser.fullName, addedUsersNames];
}

@end
