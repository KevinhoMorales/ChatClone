//
//  QBApi+Users.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"
#import "ContentService.h"
#import "FacebookService.h"
#import "SettingsManager.h"
#import "AddressBook.h"
#import "ABPerson.h"


@implementation QMApi (Users)

- (void)addUserToContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.contactListService addUserToContactListRequest:user completion:^(BOOL success) {
        //
        [[QMApi instance].usersService.usersMemoryStorage addUser:user];
        [[QMUsersCache instance] insertOrUpdateUser:user];
        [weakSelf createPrivateChatDialogIfNeededWithOpponent:user completion:^(QBChatDialog *chatDialog) {
            [weakSelf sendContactRequestSendNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
                
                if (completion) completion(success, notification);
            }];
        }];
    }];
}

- (void)removeUserFromContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.contactListService removeUserFromContactListWithUserID:user.ID completion:^(BOOL success) {
        //
        
        [[QMUsersCache instance] deleteUser:user];
        [weakSelf sendContactRequestDeleteNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
            // delete chat dialog:
            QBChatDialog *dialog = [weakSelf.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
            [weakSelf deleteChatDialog:dialog completion:^(BOOL succeed) {
                if (!succeed) {
                    completion(succeed, nil);
                    return;
                }
                completion(success, notification);
            }];
        }];

    }];
}

- (void)confirmAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    [self.contactListService acceptContactRequest:user.ID completion:^(BOOL success) {
        //
        [self.chatService sendMessageAboutAcceptingContactRequest:YES toOpponentID:user.ID completion:^(NSError * _Nullable error) {
            
            completion(error == nil ? YES : NO);
        }];
       
    }];
}

- (void)rejectAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    [self.contactListService rejectContactRequest:user.ID completion:^(BOOL success) {
        //
        [self.chatService sendMessageAboutAcceptingContactRequest:NO toOpponentID:user.ID completion:^(NSError * _Nullable error) {
            
            completion(error == nil ? YES : NO);
            
        }];
        
    }];
}

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    return [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
}

- (NSArray *)idsWithUsers:(NSArray *)users {
    
    NSMutableSet *ids = [NSMutableSet set];
    for (QBUUser *user in users) {
        [ids addObject:@(user.ID)];
    }
    return [ids allObjects];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    
   return [self.usersService.usersMemoryStorage userWithID:userID];
   
}

- (NSArray *)usersWithIDs:(NSArray *)ids {
    
    NSMutableArray *allFriends = [NSMutableArray array];
    for (NSNumber * friendID in ids) {
        QBUUser *user = [self userWithID:friendID.integerValue];
        if (user) {
            [allFriends addObject:user];
        }
    }
    
    return allFriends;
}

- (NSArray *)friends {
    
    NSArray *ids = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allFriends = [self usersWithIDs:ids];
    
    return allFriends;
}

- (NSArray *)idsOfContactsOnly {
    
    NSMutableSet *IDs = [NSMutableSet new];
    NSArray *contactItems = [QBChat instance].contactList.contacts;
    
    for (QBContactListItem *item in contactItems) {
        [IDs addObject:@(item.userID)];
    }
    
    for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
        
        if (item.subscriptionState == QBPresenceSubscriptionStateFrom) {
            [IDs addObject:@(item.userID)];
        }
    }
    return IDs.allObjects;
}

- (NSArray *)contactsOnly
{
    
    NSArray *IDs = [self idsOfContactsOnly];
    NSArray *contacts = [self usersWithIDs:IDs];
    return contacts;
}

- (BOOL)isContactRequestUserWithID:(NSInteger)userID
{
    QBChatDialog *privateDialog = [self.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:userID];
    if (privateDialog == nil) return NO;
    
    QBChatMessage *lastMessage = [self.chatService.messagesMemoryStorage lastMessageFromDialogID:privateDialog.ID];
    if (lastMessage.messageType == QMMessageTypeContactRequest) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)userIDIsInPendingList:(NSUInteger)userID {
    QBContactListItem *contactlistItem = [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    if (contactlistItem.subscriptionState != QBPresenceSubscriptionStateNone) {
        return NO;
    }
    return YES;
}

- (BOOL)isFriend:(QBUUser *)user
{
    NSArray *friends = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    for (NSUInteger i = 0; i < friends.count; i++) {
        if ([friends[i]  isEqual: @(user.ID)]) return YES;
    }
    return NO;
}

#pragma mark - Update current User

- (void)changePasswordForCurrentUser:(QBUpdateUserParameters *)updateParams completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateCurrentUser:updateParams successBlock:^(QBResponse *response, QBUUser *user) {
        //
        if (response.success) {
            weakSelf.currentUser.password = updateParams.password;
            [weakSelf.settingsManager setLogin:user.email andPassword:updateParams.password];
        }
        completion(response.success);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response.success);
    }];
}

- (void)updateCurrentUser:(QBUpdateUserParameters *)updateParams image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __block QBUpdateUserParameters *params = updateParams;
    __weak __typeof(self)weakSelf = self;
    
    void (^updateUserProfile)(QBCBlob *) =^(QBCBlob *blob) {
        
        if (!params) {
            params = [QBUpdateUserParameters new];
            params.customData = weakSelf.currentUser.customData;
        }
        
        if (blob.publicUrl.length > 0) {
            params.avatarUrl = blob.publicUrl;
        }
        params.blobID = blob.ID;
        NSString *password = weakSelf.currentUser.password;
        
        [QBRequest updateCurrentUser:params successBlock:^(QBResponse *response, QBUUser *updatedUser) {
            //
            if (response.success) {
                weakSelf.currentUser.password = password;
            }
            completion(response.success);
        } errorBlock:^(QBResponse *response) {
            //
            completion(response.success);
        }];
    };
    
    if (image) {
        [self.contentService uploadJPEGImage:image progress:progress completion:^(QBResponse *response, QBCBlob *blob) {
            //
            if (response.success) {
                updateUserProfile(blob);
            }
            else {
                updateUserProfile(nil);
            }
        }];
    }
    else {
        updateUserProfile(nil);
    }
}

- (void)updateCurrentUser:(QBUpdateUserParameters *)params imageUrl:(NSURL *)imageUrl progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.contentService downloadFileWithUrl:imageUrl completion:^(NSData *data) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [weakSelf updateCurrentUser:params image:image progress:progress completion:completion];
        }
    }];
}

#pragma mark - Import friends

- (void)importFriendsFromFacebook:(void (^)(BOOL))completion {
    __weak __typeof(self)weakSelf = self;
    [FacebookService fetchMyFriendsIDs:^(NSArray *facebookFriendsIDs) {
        
        if ([facebookFriendsIDs count] == 0) {
            if (completion) completion(NO);
            return;
        }
        
        //change
        
//       QBUUser *users =   [self.usersService getUsersWithFacebookIDs:facebookFriendsIDs];
//        NSArray *user_ = (NSArray*)users;
//        
//            if ([user_ count] == 0) {
//                if (completion) completion(NO);
//                return;
//            }
//        
//            // sending contact requests:
//            for (QBUUser *user in user_) {
//                [weakSelf addUserToContactList:user completion:nil];
//            }
//            if (completion) completion(YES);
        }];
   
}

- (void)importFriendsFromAddressBookWithCompletion:(void(^)(BOOL succeded, NSError *error))completionBlock
{
    __weak __typeof(self)weakSelf = self;
    [AddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contacts, BOOL success, NSError *error) {
        
        if ([contacts count] == 0) {
            completionBlock(NO, error);
            return;
        }
        NSMutableArray *emails = [NSMutableArray array];
        for (ABPerson *person in contacts) {
            [emails addObjectsFromArray:person.phonenumbers];
        }
        
        // post request for emails to QB server:
        
        //change
        
     
        BFTask<NSArray<QBUUser*>*> *users = [self.usersService getUsersWithEmails:emails];
       
            
//            if ([users count] == 0) {
//                completionBlock(NO, nil);
//                return;
//            }
        
            // sending contact requests:
//            for (QBUUser *user in users) {
//                [weakSelf addUserToContactList:user completion:^(BOOL successed, QBChatMessage *notification) {}];
//            }
            completionBlock(YES, nil);
        }];
    
}

@end
