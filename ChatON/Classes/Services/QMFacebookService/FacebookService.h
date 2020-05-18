//
//  FacebookService.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBSDKAppInviteDialogDelegate;

@interface FacebookService : NSObject
/**
 */
+ (void)connectToFacebook:(void(^)(NSString *sessionToken))completion;

/**
 */
+ (void)inviteFriendsWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate;

/**
 */
+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion;

/**
 */
+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion;

/**
 */
+ (NSURL *)userImageUrlWithUserID:(NSString *)userID;

/**
 */
+ (void)loadMe:(void(^)(NSDictionary *user))completion;

/**
 */
+ (void)logout;

@end
