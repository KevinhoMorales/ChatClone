//
//  QBApi+CallList.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QBApi.h"
#import "CallManager.h"

@implementation QMApi (Calls)

- (void)callToUser:(NSNumber *)userID conferenceType:(QBRTCConferenceType)conferenceType
{
    [self callToUser:userID conferenceType:conferenceType sendPushNotificationIfUserIsOffline:YES];
}

- (void)callToUser:(NSNumber *)userID conferenceType:(QBRTCConferenceType)conferenceType sendPushNotificationIfUserIsOffline:(BOOL)pushEnabled
{
    [self.avCallManager callToUsers:@[userID] withConferenceType:conferenceType pushEnabled:pushEnabled];
}

- (void)acceptCall
{
    [self.avCallManager acceptCall];
}

- (void)rejectCall
{
    [self.avCallManager rejectCall];
}

- (void)finishCall
{
    [self.avCallManager hangUpCall];
}

@end
