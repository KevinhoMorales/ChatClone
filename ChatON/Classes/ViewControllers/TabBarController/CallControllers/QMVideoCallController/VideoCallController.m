//
//  VideoCallController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "VideoCallController.h"
#import "CallManager.h"

@implementation VideoCallController

NSString *const kGoToDuringVideoCallControllerSegue= @"goToDuringVideoCallSegueIdentifier";

#pragma mark - Overridden methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [[QBRTCClient instance] addDelegate:self];
    if( QMApi.instance.avCallManager.localVideoTrack ){
        [self.opponentsView setVideoTrack:QMApi.instance.avCallManager.localVideoTrack];
    }
}

- (IBAction)stopCallTapped:(id)sender {
    [self.opponentsView setHidden:YES];
    [self.opponentsView setVideoTrack:nil];
    
    [super stopCallTapped:sender];
}

- (void)startCall {
    [[QMApi instance] callToUser:@(self.opponent.ID) conferenceType:QBRTCConferenceTypeVideo sendPushNotificationIfUserIsOffline:YES];
}

- (void)confirmCall {
    [super confirmCall];
    [self callStartedWithUser];
}

- (void)callStartedWithUser {
    [self.contentView hide];
    [self.opponentsView setVideoTrack:nil];
    [self performSegueWithIdentifier:kGoToDuringVideoCallControllerSegue sender:nil];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    [self.contentView show];
    [self.opponentsView setHidden:YES];
    [super callStoppedByOpponentForReason:reason];
}

#pragma mark QBRTCSession delegate -
- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    
    if (self.session != session) {
        
        return;
    }
    
    // user is being able to interact with buttons before local media stream
    // would initialize. Therefore we are capturing user decision on track been enabled
    mediaStream.audioTrack.enabled = !self.btnMic.selected;
    
   
        // capturing user desicion on video track been enabled
        mediaStream.videoTrack.enabled = !self.btnSwitchCamera.selected;
        
        // setting current video capture
        mediaStream.videoTrack.videoCapture = self.cameraCapture;
    
}
- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    [super session:session connectedToUser:userID];
    [self callStartedWithUser];
}
-(void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID{
     [self.opponentsView setVideoTrack:videoTrack];
    
}
//- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
//  //  [super session:session didReceiveLocalVideoTrack:videoTrack];
//    [self.opponentsView setVideoTrack:videoTrack];
//}

@end
