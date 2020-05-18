//
//  QBApi+Notif.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"
#import "ChatUtils.h"
#import "QMServicesManager.h"
//#import <QMChatService+AttachmentService.h>


@implementation QMApi (Notifications)


#pragma mark - Private chat notifications

- (void)sendContactRequestSendNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.messageType = QMMessageTypeContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (void)sendContactRequestDeleteNotificationToUser:(QBUUser *)user completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatMessage *notification = [self notificationForUser:user];
    notification.messageType = QMMessageTypeDeleteContactRequest;
    [self sendNotification:notification completion:completionBlock];
}

- (QBChatMessage *)notificationForUser:(QBUUser *)user
{
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.senderID = self.currentUser.ID;
    notification.text = @"Contact request";  // contact request
    notification.dateSent = [NSDate date];
    return notification;
}

- (void)sendNotification:(QBChatMessage *)notification completion:(void(^)(NSError *error, QBChatMessage *notification))completionBlock
{
    QBChatDialog *dialog = [self.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:notification.recipientID];
    NSAssert(dialog, @"Dialog not found");
    [notification updateCustomParametersWithDialog:dialog];
    
    //change
    
   
  BFTask *completion_ =  [self.chatService sendMessage:notification type:notification.messageType toDialog:dialog saveToHistory:YES saveToStorage:YES];
    
    if(completion_) completionBlock(nil,notification);
  
    //    [self.chatService  sendMessage:notification toDialog:dialog saveToHistory:YES saveToStorage:YES completion:^(NSError * _Nullable error) {
//        
//        if (!error) {
//            if (completionBlock) completionBlock(nil, notification);
//        } else {
//            if (completionBlock) completionBlock(error, nil);
//        }
//    }];
    
        [self sendPushContactRequestNotification:notification];
}

#pragma mark - Push Notifications

- (void)sendPushContactRequestNotification:(QBChatMessage *)notification
{
    NSString *message = [ChatUtils messageTextForPushWithNotification:notification];
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%zd", notification.recipientID];
    event.type = QBMEventTypeOneShot;
    //
    // custom params
    NSDictionary  *dictPush = @{@"message" : message,
                                @"ios_badge": @"1",
                                @"ios_sound": @"default",
                                };
    //
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *response, NSArray *events) {
        //
    } errorBlock:^(QBResponse *response) {
        //
    }];
}

- (void)handlePushNotificationWithDelegate:(id<QMNotificationHandlerDelegate>)delegate {
    if (self.pushNotification == nil) return;
    
    NSString *dialogID = self.pushNotification[kPushNotificationDialogIDKey];
    self.pushNotification = nil;
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService fetchDialogWithID:dialogID completion:^(QBChatDialog *chatDialog) {
        
        if (chatDialog != nil) {
           
            //change
            
            [self.usersService getUsersWithIDs:chatDialog.occupantIDs];
           // [weakSelf.contactListService retrieveIfNeededUsersWithIDs:chatDialog.occupantIDs completion:^(BOOL retrieveWasNeeded) {
                //
                if ([delegate respondsToSelector:@selector(notificationHandlerDidSucceedFetchingDialog:)]) {
                    [delegate notificationHandlerDidSucceedFetchingDialog:chatDialog];
                }
            //}];
        }
        else {
            //
            if ([delegate respondsToSelector:@selector(notificationHandlerDidStartLoadingDialogFromServer)]) {
                [delegate notificationHandlerDidStartLoadingDialogFromServer];
            }
            [weakSelf.chatService loadDialogWithID:dialogID completion:^(QBChatDialog *loadedDialog) {
                //
                if ([delegate respondsToSelector:@selector(notificationHandlerDidFinishLoadingDialogFromServer)]) {
                    [delegate notificationHandlerDidFinishLoadingDialogFromServer];
                }
                if (loadedDialog != nil) {
                    //
                    [self.usersService getUsersWithIDs:chatDialog.occupantIDs];
                    //[weakSelf.contactListService retrieveIfNeededUsersWithIDs:chatDialog.occupantIDs completion:^(BOOL retrieveWasNeeded) {
                        //
                        if ([delegate respondsToSelector:@selector(notificationHandlerDidSucceedFetchingDialog:)]) {
                            [delegate notificationHandlerDidSucceedFetchingDialog:loadedDialog];
                        }
                   // }];
                }
                else {
                    //
                    if ([delegate respondsToSelector:@selector(notificationHandlerDidFailFetchingDialog)]) {
                        [delegate notificationHandlerDidFailFetchingDialog];
                    }
                }
            }];
        }
    }];
}

@end
