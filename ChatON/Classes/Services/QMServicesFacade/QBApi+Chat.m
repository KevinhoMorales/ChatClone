//
//  QMApi+Messages.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"
#import "SettingsManager.h"
#import "QBApi+Notif.m"
#import "ContentService.h"
#import "ChatUtils.h"

static NSString *const kQMDialogsUpdateNotificationMessage = @"Notification message";

@implementation QMApi (Chat)


/**
 *  Messages
 */

#pragma mark - Messages

- (void)loginChat:(void(^)(BOOL success))block {
    
    //change
    [self.chatService connectWithCompletionBlock:^(NSError * _Nullable error) {
        
        if (error != nil) {
            block(YES);
        }
        else {
            block(NO);
        }
    }];
   
}

- (void)logoutFromChat {
    //change
    [self.chatService disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        
    }];
   
    [self.settingsManager setLastActivityDate:[NSDate date]];
}

/**
 *  ChatDialog
 */

#pragma mark - ChatDialog

NSString const *kQMEditDialogExtendedNameParameter = @"name";
NSString const *kQMEditDialogExtendedPushOccupantsParameter = @"push[occupants_ids][]";
NSString const *kQMEditDialogExtendedPullOccupantsParameter = @"pull_all[occupants_ids][]";

- (void)fetchAllDialogs:(void(^)(void))completion {

    __weak __typeof(self)weakSelf = self;
//    if (self.settingsManager.lastActivityDate != nil) {
//        NSLog(@"last activity date %@",self.settingsManager.lastActivityDate);
//        [self.chatService fetchDialogsUpdatedFromDate:self.settingsManager.lastActivityDate andPageLimit:kQMDialogsPageLimit iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
//            
//            //change
//            [self.usersService getUsersWithIDs:[self.contactListService.contactListMemoryStorage userIDsFromContactList]];
//            // [weakSelf.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
//          
//        } completionBlock:^(QBResponse *response) {
//            //
//            if (response != nil && response.success) weakSelf.settingsManager.lastActivityDate = [NSDate date];
//            if (completion) completion();
//        }];
//    }
 //   else {
        [self.chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            
            //change
            [[QMApi instance].usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];

           // [weakSelf.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];

        } completion:^(QBResponse *response) {
            //
            if (response != nil && response.success) weakSelf.settingsManager.lastActivityDate = [NSDate date];
            if (completion) completion();
        }];
   // }
}

- (void)fetchChatDialogWithID:(NSString *)dialogID completion:(void(^)(QBChatDialog *chatDialog))completion
{
    
    __weak typeof(self)weakSelf = self;
    
    [weakSelf.chatService fetchDialogWithID:dialogID completion:^(QBChatDialog *dialog) {
        //
        if (!dialog) {
            if (completion) completion(dialog);
            return;
        }
      BFTask *completion_ =  [self.usersService getUsersWithIDs:dialog.occupantIDs forceLoad:NO];
        
            if (completion_) completion(dialog);
        
    }];
}


#pragma mark - Create Chat Dialogs


- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion
{
    [self.chatService createPrivateChatDialogWithOpponent:opponent completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        if (completion) completion(createdDialog);
    }];
}

- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(void(^)(QBChatDialog *chatDialog))completion {
    
    
    __weak typeof(self)weakSelf = self;
    [self.chatService createGroupChatDialogWithName:name photo:nil occupants:occupants completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        NSString *messageTypeText = NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", @"{Full name}");
        NSString *text = [ChatUtils messageForText:messageTypeText participants:occupants];
        
        createdDialog.lastMessageDate = [NSDate date];
        [weakSelf sendGroupChatDialogDidCreateNotificationToUsers:createdDialog.occupantIDs toChatDialog:createdDialog withMessage:text];
        
 
        
        if (completion) completion(createdDialog);
    }];
}


#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService changeDialogName:dialogName forChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            NSString *notificationText = NSLocalizedString(@"QM_STR_UPDATE_GROUP_NAME_TEXT", nil);
            NSString *text = [NSString stringWithFormat:notificationText, self.currentUser.fullName, dialogName];
            
            
     //       NSString *str ;
            
//            for(QBUUser *user in chatDialog.occupantIDs){
//                
//                str = [NSString stringWithFormat:@"%d,",user.ID];
//            }
//            NSLog(@"ids: %@",str);
             [self.chatService sendNotificationMessageAboutChangingDialogName:updatedDialog withNotificationText:text];
        }
        if (completion) completion(response,updatedDialog);
    }];
}

- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion
{
    __weak typeof(self)weakSelf = self;
    [self.contentService uploadPNGImage:avatar progress:^(float progress) {
        //
    } completion:^(QBResponse *response, QBCBlob *blob) {
        //
        // update chat dialog:
        if (!response.success) {
            return;
        }
        
        [weakSelf.chatService changeDialogAvatar:blob.publicUrl forChatDialog:chatDialog completion:^(QBResponse *updateResponse, QBChatDialog *updatedDialog) {
            //
            if (updateResponse.success) {
                // send notification:
                NSString *notificationText = NSLocalizedString(@"QM_STR_UPDATE_GROUP_AVATAR_TEXT", @"{Full name}");
                NSString *text = [NSString stringWithFormat:notificationText, self.currentUser.fullName];

                [self.chatService sendNotificationMessageAboutChangingDialogPhoto:updatedDialog withNotificationText:text];
                //[weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:updatedDialog updateType:nil content:nil];
                if (completion) completion(updateResponse, updatedDialog);
            }

        }];
    }];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    NSArray *occupantsToJoinIDs = [self idsWithUsers:occupants];
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService joinOccupantsWithIDs:occupantsToJoinIDs toChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            NSString *messageTypeText = NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", @"{Full name}");
            NSString *text = [ChatUtils messageForText:messageTypeText participants:occupants];
            
            [weakSelf sendGroupChatDialogDidCreateNotificationToUsers:[self idsWithUsers:occupants] toChatDialog:updatedDialog withMessage:text];
           // [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"occupants_ids" content:[updatedDialog.occupantIDs componentsJoinedByString:@","]];
        }
        if (completion) completion(response,updatedDialog);
    }];
}

- (void)joinGroupDialogs {
    NSArray *allDialogs = [self.chatService.dialogsMemoryStorage unsortedDialogs];
    for (QBChatDialog* dialog in allDialogs) {
        if (dialog.type != QBChatDialogTypePrivate) {
            // Joining to group chat dialogs.
            
            //change
            [self.chatService joinToGroupDialog:dialog completion:^(NSError * _Nullable error) {
                NSLog(@"Failed to join room with error: %@", error.localizedDescription);
            }];
            
        }
    }
}

- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    NSString *messageTypeText = NSLocalizedString(@"QM_STR_LEAVE_GROUP_CONVERSATION_TEXT", @"{Full name}");
    NSString *text = [NSString stringWithFormat:messageTypeText, self.currentUser.fullName];
    NSString *myID = [NSString stringWithFormat:@"%lu", (unsigned long)self.currentUser.ID];
    
    // remove current user from occupants
    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
    for (NSNumber *identifier in chatDialog.occupantIDs) {
        if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
            [occupantsWithoutCurrentUser addObject:identifier];
        }
    }
    chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:text];
   // [self sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"deleted_id" content:myID];
    [weakSelf.chatService deleteDialogWithID:chatDialog.ID completion:^(QBResponse *response) {
        //
        if (completion) completion(response,nil);
    }];
}

- (NSUInteger )occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.type == QBChatDialogTypePrivate, @"Chat dialog type != QBChatDialogTypePrivate");
    
    NSInteger myID = self.currentUser.ID;
    
    for (NSNumber *ID in chatDialog.occupantIDs) {
        
        if (ID.integerValue != myID) {
            return ID.integerValue;
        }
    }
    
    NSAssert(nil, @"Need update this case");
    return 0;
}

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler
{
    [self.chatService deleteDialogWithID:dialog.ID completion:^(QBResponse *response) {
        //
        completionHandler(response.success);
    }];
}


#pragma mark - Notifications

- (void)sendGroupChatDialogDidCreateNotificationToUsers:(NSArray *)users toChatDialog:(QBChatDialog *)chatDialog withMessage:(NSString *)text {
    
    
    [[self.chatService sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:users withText:text] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused systemNotificationTask) {
        
        return [self.chatService sendNotificationMessageAboutAddingOccupants:users toDialog:chatDialog withNotificationText:text];
    }];
    //change
//    [self.chatService sendNotificationMessageAboutAddingOccupants:users toDialog:chatDialog withNotificationText:text];
//    
//    if (text != nil) {
//        QBChatMessage *message = [QBChatMessage message];
//        message.text = text;
//        message.dateSent = [NSDate date];
//        [message updateCustomParametersWithDialog:chatDialog];
//        //change
//        [self.chatService sendMessage:message type:QMMessageTypeUpdateGroupDialog toDialog:chatDialog saveToHistory:YES saveToStorage:YES];
//        
//    }
}

- (void)sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:(NSString *)text toChatDialog:(QBChatDialog *)chatDialog updateType:(NSString *)updateType content:(NSString *)content
{
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    if (updateType != nil && content != nil) {
        [customParams setObject:content forKey:updateType];
    }
    QBChatMessage *message = [QBChatMessage message];
    message.messageType = QMMessageTypeUpdateGroupDialog;
    message.text = text;
    //change
    [self.chatService sendMessage:message toDialog:chatDialog saveToHistory:YES saveToStorage:YES];
   }

#pragma mark - Dialogs toos

- (NSArray *)dialogHistory {
    return [self.chatService.dialogsMemoryStorage unsortedDialogs];
}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    
    return [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
}

- (NSArray *)allOccupantIDsFromDialogsHistory{
    
    NSArray *allDialogs = [self.chatService.dialogsMemoryStorage unsortedDialogs];
    NSMutableSet *ids = [NSMutableSet set];
    
    for (QBChatDialog *dialog in allDialogs) {
        [ids addObjectsFromArray:dialog.occupantIDs];
    }
    
    return ids.allObjects;
}

@end
