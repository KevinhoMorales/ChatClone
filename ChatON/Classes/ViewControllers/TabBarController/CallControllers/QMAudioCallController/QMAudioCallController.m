//
//  QMAudioCallController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"
#import "CallManager.h"

@implementation QMAudioCallController
{
    BOOL isFirstRun;
}

#pragma mark - Overridden methods

- (void)startCall {
    [[QMApi instance] callToUser:@(self.opponent.ID) conferenceType:QBRTCConferenceTypeAudio];
    [QMSoundManager playCallingSound];
    isFirstRun = YES;
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID{
    [super session:session connectedToUser:userID];
    
    if( isFirstRun ){
        isFirstRun = NO;
        // Me is not a caller
    
        if( [QMApi instance].currentUser.ID != [userID unsignedIntegerValue] ){
            [[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteReceiver];
        }
        [self updateButtonsState];
    }
}
@end
