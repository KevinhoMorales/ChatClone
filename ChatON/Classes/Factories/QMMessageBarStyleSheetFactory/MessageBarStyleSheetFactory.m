//
//  MessageBarStyleSheetFactoryVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "MessageBarStyleSheetFactory.h"
#import "QBApi.h"
#import "ChatUtils.h"


@implementation MessageBarStyleSheetFactoryVC



+ (void)showMessageBarNotificationWithMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block
{
    UIImage *img = nil;
    NSString *title = @"";
    
    if (chatDialog == nil) {
        // for some reason chat dialog was not find
        // no reason to show message notification
        return;
    }
    if (chatDialog.type ==  QBChatDialogTypeGroup) {
        
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = chatDialog.name;
    }
    else if (chatDialog.type == QBChatDialogTypePrivate) {
        
      BFTask *user_ =  [[QMApi instance].usersService getUserWithID:message.senderID];
       // QBUUser *user = [[QMApi instance] userWithID:message.senderID];

        QBUUser *user = user_.result;
        if(user != nil){
        
            title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
            img = [UIImage imageNamed:@"upic_placeholderr"];

        }
        
       
        //BFTask *task = [[QMApi instance].usersService getUserWithID:message.senderID];
        
        
    }
    
    NSString *messageText = [NSString string];
    if (message.isNotificatonMessage && message.messageType != QMMessageTypeUpdateGroupDialog) {
        messageText = [ChatUtils messageTextForNotification:message];
    }
    else {
        messageText = message.encodedText;
    }

    MPGNotification *newNotification = [MPGNotification notificationWithTitle:title subtitle:messageText backgroundColor:[UIColor colorWithRed:0.32 green:0.33 blue:0.34 alpha:0.86] iconImage:img];
    [newNotification setButtonConfiguration:MPGNotificationButtonConfigrationOneButton withButtonTitles:@[@"Reply"]];
    newNotification.duration = 2.0;
    
    newNotification.buttonHandler = block;
    [newNotification show];
}



@end
