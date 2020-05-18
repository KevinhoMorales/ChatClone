//
//  QBApi+Fb.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"
#import "FacebookService.h"

@implementation QMApi (Facebook)

- (void)fbFriends:(void(^)(NSArray *fbFriends))completion {
    [FacebookService connectToFacebook:^(NSString *sessionToken) {
        [FacebookService fetchMyFriends:completion];
    }];
}

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID {
    return [FacebookService userImageUrlWithUserID:userID];
}

- (void)fbLogout {
    [FacebookService logout];
}

- (void)fbInviteDialogWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate {
    
    [FacebookService inviteFriendsWithDelegate:delegate];
}

@end
