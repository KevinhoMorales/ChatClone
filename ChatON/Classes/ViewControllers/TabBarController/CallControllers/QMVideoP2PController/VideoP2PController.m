////
////  VideoP2PController.m
//// //  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
////
//
//#import "VideoP2PController.h"
//#import "CallManager.h"
//#import <sys/utsname.h>
//
//@implementation VideoP2PController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    if( [QMApi instance].avCallManager.localVideoTrack ){
//        self.localVideoTrack = [QMApi instance].avCallManager.localVideoTrack;
//    }
//    if( [QMApi instance].avCallManager.remoteVideoTrack ){
//        self.opponentVideoTrack = [QMApi instance].avCallManager.remoteVideoTrack;
//    }
//    
//    [self.contentView startTimerIfNeeded];
//    [self reloadVideoViews];
//    
//    if([machineName() isEqualToString:@"iPhone3,1"] ||
//       [machineName() isEqualToString:@"iPhone3,2"] ||
//       [machineName() isEqualToString:@"iPhone3,3"] ||
//       [machineName() isEqualToString:@"iPhone4,1"]) {
//        
//        self.opponentsVideoViewBottom.constant = -80.0f;
//    }
//	[[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
//}
//- (void)cameraSwitchTapped:(id)sender{
//	[super cameraSwitchTapped:sender];
//	if( self.session.localMediaStream.videoTrack.enabled ){
//		[self allowSendingLocalVideoTrack];
//		[self.btnSwitchCamera setUserInteractionEnabled:YES];
//	}
//	else{
//		[self denySendingLocalVideoTrack];
//		[self.btnSwitchCamera setUserInteractionEnabled:NO];
//	}
//}
//
//- (void)audioSessionRouteChanged:(NSNotification *)notification{
//	[[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
//}
//
//- (void)stopCallTapped:(id)sender {
//    [self hideViewsBeforeDealloc];
//    [super stopCallTapped:sender];
//}
//
//- (void)reloadVideoViews {
//    [self.opponentsView setVideoTrack:self.opponentVideoTrack];
//    [self.myView setVideoTrack:self.localVideoTrack];
//}
//
//- (void)hideViewsBeforeDealloc{
//    [self.myView setVideoTrack:nil];
//    [self.opponentsView setVideoTrack:nil];
//    [self.myView setHidden:YES];
//    [self.opponentsView setHidden:YES];
//}
//
//// to check for 4/4s screen
//NSString* machineName() {
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    
//    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//}
//
//- (void)videoTapped:(id)sender{
//    [super videoTapped:sender];
//    if( self.session.localMediaStream.videoTrack.enabled ){
//        [self allowSendingLocalVideoTrack];
//        [self.btnSwitchCamera setUserInteractionEnabled:YES];
//    }
//    else{
//        [self denySendingLocalVideoTrack];
//        [self.btnSwitchCamera setUserInteractionEnabled:NO];
//		[super updateButtonsState];
//    }
//}
//
//- (void)allowSendingLocalVideoTrack {
//    // it is a view with cam_off image that we need to display when cam is off
//    [self.camOffView setHidden:YES];
//    [self reloadVideoViews];
//}
//
//- (void)denySendingLocalVideoTrack {
//    self.session.localMediaStream.videoTrack.enabled = NO;
//    [self.myView setVideoTrack:nil];
//    // it is a view with cam_off image that we need to display when cam is off
//    [self.camOffView setHidden:NO];
//}
//
//#pragma mark QBRTCSession delegate -
//
//- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
//    [super session:session disconnectedFromUser:userID];
//    [self startActivityIndicator];
//}
//
//-(void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID{
//    
//    if( self.disableSendingLocalVideoTrack ){
//        [self denySendingLocalVideoTrack];
//        self.disableSendingLocalVideoTrack = NO;
//        [self updateButtonsState];
//    }
//    [self reloadVideoViews];
//}
////- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
////  //  [super session:session didReceiveLocalVideoTrack:videoTrack];
////    if( self.disableSendingLocalVideoTrack ){
////        [self denySendingLocalVideoTrack];
////        self.disableSendingLocalVideoTrack = NO;
////		[self updateButtonsState];
////    }
////    [self reloadVideoViews];
////}
////
////- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
////    
////  //  [super session:session didReceiveRemoteVideoTrack:videoTrack fromUser:userID];
////    self.opponentVideoTrack = videoTrack;
////    
////    [self reloadVideoViews];
////}
//
//- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
//    [super session:session connectedToUser:userID];
//    [self stopActivityIndicator];
//}
//
//- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID  userInfo:(NSDictionary *)userInfo{
//    [self hideViewsBeforeDealloc];
//    [super session:session hungUpByUser:userID userInfo:nil];
//}
//
//@end
