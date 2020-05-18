//
//  BaseCallsController.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentView.h"
#import "QBApi.h"
#import "QMSoundManager.h"
#import "IAButton.h"

@interface BaseCallsController : UIViewController<QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet IAButton *btnSpeaker;
@property (weak, nonatomic) IBOutlet IAButton *btnSwitchCamera;
@property (weak, nonatomic) IBOutlet IAButton *btnMic;
@property (weak, nonatomic) IBOutlet IAButton *btnVideo;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
/// nil for audio
@property(nonatomic, strong) QBRTCVideoTrack *localVideoTrack;
/// nil for audio
@property(nonatomic, strong) QBRTCVideoTrack *opponentVideoTrack;

@property (nonatomic, assign) BOOL isOpponentCaller;

/** Content View */
@property (weak, nonatomic) IBOutlet ContentView *contentView;
@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;

@property (nonatomic, weak)  QBRTCRemoteVideoView *opponentsView;
@property (nonatomic, weak)  IBOutlet UIImageView *camOffView;

@property (nonatomic, strong) QBUUser *opponent;

@property (weak, nonatomic) QBRTCSession *session;
/** Controls selectors */
- (IBAction)cameraSwitchTapped:(id)sender;
- (IBAction)muteTapped:(id)sender;
- (IBAction)videoTapped:(id)sender;
- (IBAction)speakerTapped:(id)sender;
- (IBAction)stopCallTapped:(id)sender;

/** Override actions in child */
- (void)startCall;
- (void)confirmCall;

- (void)callStartedWithUser;

- (void)callStoppedByOpponentForReason:(NSString *)reason;

- (void)startActivityIndicator;
- (void)stopActivityIndicator;

- (void)audioSessionRouteChanged:(NSNotification *)notification;

- (void)updateButtonsState;

@end
