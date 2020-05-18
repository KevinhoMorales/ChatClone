//
//  BaseCallsController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "BaseCallsController.h"
#import "CallManager.h"

#define kStopVideoChatCallStatus_OpponentDidNotAnswer @"kStopVideoChatCallStatus_OpponentDidNotAnswer"
#define kStopVideoChatCallStatus_Manually @"kStopVideoChatCallStatus_Manually"
#define kStopVideoChatCallStatus_Cancel @"kStopVideoChatCallStatus_Cancel"
#define kStopVideoChatCallStatus_BadConnection @"kStopVideoChatCallStatus_BadConnection"

@implementation BaseCallsController
{
    AVAudioSessionCategoryOptions categoryOptions;
    AVAudioSessionCategoryOptions defaultCategoryOptions;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnSpeaker.userInteractionEnabled = NO;

    if( QMApi.instance.avCallManager.session ){
        self.session = QMApi.instance.avCallManager.session;
    }
    [QBRTCClient.instance addDelegate:self];
    
    [self subscribeForNotifications];
    !self.isOpponentCaller ? [self startCall] : [self confirmCall];
    
    [self.contentView updateViewWithUser:self.opponent conferenceType:self.session.conferenceType isOpponentCaller:self.isOpponentCaller];
    [self updateButtonsState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionRouteChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

- (void)audioSessionRouteChanged:(NSNotification *)notification {
    
}

- (void)updateButtonsState {
    [self.btnMic setSelected:self.session.localMediaStream.audioTrack.enabled];
    [self.btnSwitchCamera setSelected:!QMApi.instance.avCallManager.isFrontCamera];
    [self.btnSwitchCamera setUserInteractionEnabled:self.session.localMediaStream.videoTrack.enabled];
    [self.btnVideo setSelected:!self.session.localMediaStream.videoTrack.enabled];
    [self.btnSpeaker setSelected:[[AVAudioSession sharedInstance] categoryOptions] == AVAudioSessionCategoryOptionDefaultToSpeaker];
    [self.camOffView setHidden:self.session.localMediaStream.videoTrack.enabled];
}

- (void)subscribeForNotifications {
    
}

#pragma mark - Override actions

// Override this method in child:
- (void)startCall{}

// Override this method in child:
- (void)confirmCall {
    [[QMApi instance] acceptCall];
}

- (IBAction)stopCallTapped:(id)sender {
    [self.contentView stopTimer];
    [[QMApi instance] finishCall];
    [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil)];
    // stop playing sound:
    [[QMApi instance].avCallManager stopAllSounds];
    
    // need a delay to give a time to a WebRTC to unload resources
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [QMSoundManager playEndOfCallSound];
    });
    
    [self stopActivityIndicator];
}

- (void)startActivityIndicator {
    [self.activityIndicator setAlpha:1.0];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
}

- (void)stopActivityIndicator {
    [self.activityIndicator setAlpha:0.0];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Calls notifications

// Override this method in child:
- (void)callStartedWithUser {
    
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    // stop playing sound:
    [[QMApi instance].avCallManager stopAllSounds];
    [self.contentView stopTimer];
    
    if ([reason isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_USER_DOESNT_ANSWER", nil)];
        [QMSoundManager playBusySound];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_BAD_CONNECTION", nil)];
        [QMSoundManager playEndOfCallSound];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_Manually]) {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_USER_IS_BUSY", nil)];
        [QMSoundManager playEndOfCallSound];
    } else {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil)];
        [QMSoundManager playEndOfCallSound];
    }
}

- (IBAction)speakerTapped:(IAButton *)sender {

	QBRTCSoundRouter *router = [QBRTCSoundRouter instance];
	QBRTCSoundRoute  currentRoute = [router currentSoundRoute];
	
	sender.selected =  currentRoute == QBRTCSoundRouteSpeaker;
	
	if( currentRoute == QBRTCSoundRouteSpeaker ){
		[router setCurrentSoundRoute:QBRTCSoundRouteReceiver];
	}
	else{
		[router setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
	}
}

- (IBAction)cameraSwitchTapped:(IAButton *)sender {

    AVCaptureDevicePosition position = [self.cameraCapture currentPosition];
    AVCaptureDevicePosition newPosition = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    [self.cameraCapture selectCameraPosition:newPosition ];
        QMApi.instance.avCallManager.frontCamera = newPosition;
        [sender setSelected:!newPosition];
    
}

- (IBAction)muteTapped:(id)sender {
    
    if (self.session.localMediaStream) {
        
        self.btnMic.selected = !self.session.localMediaStream.audioTrack.enabled;
    }
    
    self.session.localMediaStream.audioTrack.enabled = !self.session.localMediaStream.audioTrack.enabled;
  //  [self.session setAudioEnabled:!self.session.audioEnabled];
    [(IAButton *)sender setSelected:!self.session.localMediaStream.audioTrack.enabled];
}

- (IBAction)videoTapped:(id)sender {
    
  
  //  [self.session setVideoEnabled:!self.session.videoEnabled];
    [(IAButton *)sender setSelected:!self.session.localMediaStream.videoTrack.enabled];
}

- (void)dealloc {
    [QBRTCClient.instance removeDelegate:self];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    self.btnSpeaker.userInteractionEnabled = YES;
    ILog(@"connectedToUser:%@", userID);
    [self.contentView startTimerIfNeeded];
}

- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    ILog(@"disconnectedFromUser:%@", userID);
}

- (void)session:(QBRTCSession *)session disconnectTimeoutForUser:(NSNumber *)userID {
    ILog(@"disconnectTimeoutForUser:%@", userID);
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    if( [userID unsignedIntegerValue] != [[[QMApi instance] currentUser] ID]) {
        // current user not initiated end of call
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
    }
    else{
         [self callStoppedByOpponentForReason:nil];
    }
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo{
    [self.contentView stopTimer];
    [self stopActivityIndicator];
    [self callStoppedByOpponentForReason:nil];
}

- (void)sessionWillClose:(QBRTCSession *)session {
    
    if( self.session != session ){
        return;
    }
    
    QBRTCConnectionState state = [session connectionStateForUser:@(self.opponent.ID)];
    
    if( state == QBRTCConnectionFailed ){
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_BadConnection];
    }
    else if( state == QBRTCConnectionRejected ){
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
    }
    else if( state == QBRTCConnectionNoAnswer ){
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_OpponentDidNotAnswer];
    }
    else if( state != QBRTCConnectionUnknown && state != QBRTCConnectionClosed ){
        [self callStoppedByOpponentForReason:nil];
    }
}
-(void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID{
    self.opponentVideoTrack = videoTrack;
}
//- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
//    self.localVideoTrack = videoTrack;
//}
//
//- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
//    self.opponentVideoTrack = videoTrack;
//}

- (void)sessionDidClose:(QBRTCSession *)session {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

@end
