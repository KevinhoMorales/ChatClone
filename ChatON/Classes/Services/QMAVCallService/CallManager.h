//
//  CallManager.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IncomingCallController.h"
#import <QMBaseService.h>
#import "IncomingCallViewController.h"

@interface CallManager : QMBaseService <QBRTCClientDelegate, UIAlertViewDelegate,QMUsersMemoryStorageDelegate,IncomingCallViewControllerDelegate>

@property (strong, nonatomic) QBRTCSession *session;

@property (assign, nonatomic, getter=isFrontCamera) BOOL frontCamera;

@property (strong, nonatomic) QBRTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) QBRTCVideoTrack *remoteVideoTrack;

- (void)acceptCall;
- (void)rejectCall;
- (void)hangUpCall;
- (void)stopAllSounds;

/**
 *  call to users ids
 *
 *  @param users          array of QBUUser instances
 *  @param conferenceType QBConferenceType
 *  @param pushEnabled is user if offline he will receive a push notifications
 */
- (void)callToUsers:(NSArray *)users withConferenceType:(QBRTCConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled;

- (NSArray *)quickbloxICE;
/**
 *  check permissions and show alert if permissions are denied
 *
 *  @param conferenceType QBConferenceType
 */
- (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(void(^)(BOOL canContinue))completion;

@end
