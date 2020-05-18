 //
//  CallManager.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "CallManager.h"
#import "SVProgressHUD.h"
#import "BaseCallsController.h"
#import "QBApi.h"
#import "QMUsersMemoryStorage.h"
#import "REAlertView+QMSuccess.h"
#import "QMSoundManager.h"
#import "IncomingCallViewController.h"
#import "CallViewController.h"

static const NSTimeInterval kQMAnswerTimeInterval = 60.0f;
static const NSTimeInterval kQMDisconnectTimeInterval = 30.0f;
static const NSTimeInterval kQMDialingTimeInterval = 5.0f;

@interface CallManager()

/// active view controller
@property (strong, nonatomic, readonly) QMContactListService* contactListService;
@property (strong, nonatomic) QMUsersMemoryStorage *usersMemoryStorage;
@property (weak, nonatomic) UIViewController *currentlyPresentedViewController;
@property (assign,nonatomic) NSMutableArray *incomingcallslist;
@property (weak,nonatomic) NSDictionary *calldic;
@property (strong, nonatomic) NSTimer *callingSoundTimer;
@property (assign, nonatomic) AVAudioSessionCategoryOptions avCategoryOptions;
@property (strong, nonatomic) UINavigationController *nav;
@end

const NSTimeInterval kQBAnswerTimeInterval = 40.0f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 15.0f;

NSString *const kAudioCallController = @"AudioCallIdentifier";
NSString *const kVideoCallController = @"VideoCallIdentifier";
NSString *const kIncomingCallController = @"IncomingCallIdentifier";

NSString *const kUserIds = @"UserIds";
NSString *const kUserName = @"UserName";

@implementation CallManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [QBRTCConfig setDisconnectTimeInterval:kQBRTCDisconnectTimeInterval];
        self.frontCamera = YES;
    }
    return self;
}

- (void)serviceWillStart {
    [QBRTCClient.instance addDelegate:self];
    [QBRTCConfig setDTLSEnabled:YES];
  
    [QBRTCConfig setAnswerTimeInterval:kQMAnswerTimeInterval];
    [QBRTCConfig setDisconnectTimeInterval:kQMDisconnectTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQMDialingTimeInterval];

}

#pragma mark - RootViewController

- (UIViewController *)rootViewController {
    
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

#pragma mark - Public methods

- (void)acceptCall{
    [self stopAllSounds];
    if( self.session ){
        [self.session acceptCall:nil];
    }
    else{
        NSLog(@"error in -acceptCall: session does not exists");
    }
}
- (NSArray *)quickbloxICE {
    
    NSString *password = @"baccb97ba2d92d71e26eb9886da5f1e0";
    NSString *userName = @"quickblox";
    
    NSArray *urls = @[
                      @"turn.quickblox.com",            //USA
                      @"turnsingapore.quickblox.com",   //Singapore
                      @"turnireland.quickblox.com"      //Ireland
                      ];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:urls.count];
    
    for (NSString *url in urls) {
        
        QBRTCICEServer *stunServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"stun:%@", url]
                                                          username:@""
                                                          password:@""];
        
        
        QBRTCICEServer *turnUDPServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"turn:%@:3478?transport=udp", url]
                                                             username:userName
                                                             password:password];
        
        QBRTCICEServer *turnTCPServer = [QBRTCICEServer serverWithURL:[NSString stringWithFormat:@"turn:%@:3478?transport=tcp", url]
                                                             username:userName
                                                             password:password];
        
        [result addObjectsFromArray:@[stunServer, turnTCPServer, turnUDPServer]];
    }
    
    return result;
}

- (void)rejectCall{
    [self stopAllSounds];
    if( self.session ){
        [self.session rejectCall:@{@"reject" : @"busy"}];
    }
    else{
        NSLog(@"error in -rejectCall: session does not exists");
    }
}

- (void)hangUpCall{
    if( self.session ){
        [self.session hangUp:@{@"session" : @"hang up"}];
    }
    else{
        NSLog(@"error in -rejectCall: session does not exists");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if( alertView.cancelButtonIndex != buttonIndex ){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(void(^)(BOOL canContinue))completion {
    __weak __typeof(self) weakSelf = self;
    [[QMApi instance] requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        if( granted ) {
            if( conferenceType == QBRTCConferenceTypeAudio ) {
                if( completion ) {
                    completion(granted);
                }
            }
            else if( conferenceType == QBRTCConferenceTypeVideo ) {
                
                [[QMApi instance] requestPermissionToCameraWithCompletion:^(BOOL authorized) {
                    if( authorized && completion ) {
                        completion(authorized);
                    }
                    else if( !authorized){
                        if (&UIApplicationOpenSettingsURLString != NULL) {
                            [[[UIAlertView alloc] initWithTitle:@"Camera error" message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil) delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:@"Settings", nil] show];
                        }
                        else{
                            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil) actionSuccess:NO];
                        }
                    }
                }];
            }
        }
        else {
            if (&UIApplicationOpenSettingsURLString != NULL) {
                [[[UIAlertView alloc] initWithTitle:@"Microphone error" message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil)  delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:@"Settings", nil] show];
            }
            else{
                [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil) actionSuccess:NO];
            }
        }
    }];
}

- (void)sendPushToUserWithUserID:(NSUInteger)opponentID{
    QBMEvent *event = [QBMEvent event];
    event.usersIDs = [@(opponentID) stringValue];
    event.notificationType = QBMNotificationTypePush;
    event.type = QBMEventTypeOneShot;
    event.message = [NSString stringWithFormat:@"%@ is calling you", [QMApi instance].currentUser.fullName];
    [QBRequest createEvent:event successBlock:nil errorBlock:nil];
}

- (void)callToUsers:(NSArray *)users withConferenceType:(QBRTCConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled {
    __weak __typeof(self) weakSelf = self;
    [[QBRTCSoundRouter instance] initialize];
    [[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker]; // to make our ringtone go through the speaker
    
    
    [self checkPermissionsWithConferenceType:conferenceType completion:^(BOOL canContinue) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if( !canContinue ){
            return;
        }
        
        assert(users && users.count);
        
        if (strongSelf.session) {
            return;
        }
    
        QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:users
                                                                 withConferenceType:conferenceType];
        
        if (session) {
            [strongSelf startPlayingCallingSound];
            strongSelf.session = session;
            
            UIApplicationState state = [[UIApplication sharedApplication] applicationState];
            if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
            {
                NSLog(@"background state");
                //Do checking here.
            }
            
            BaseCallsController *vc = (BaseCallsController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:(conferenceType == QBRTCConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
            
            QBUUser *currentuser = self.currentUser;
            NSUInteger opponentID = [((NSNumber *)users[0]) unsignedIntegerValue];
            vc.session = strongSelf.session;
            vc.opponent = [[QMApi instance].usersService.usersMemoryStorage userWithID:opponentID];
            
            NSString *calltype;
            if(conferenceType == QBRTCConferenceTypeAudio){
                
                calltype = @"Audio";
                
            }
            else if(conferenceType == QBRTCConferenceTypeVideo){
                
                calltype = @"Video";
            }
            NSDate *currentdate = [NSDate date];
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            [timeFormatter setDateFormat:@"hh:mm a"];
            NSString *formattedtimeString = [timeFormatter stringFromDate:currentdate];
            
            NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
            [dateformater setDateFormat:@"dd/MM/yy"];
            NSString *formaterdateString = [dateformater stringFromDate:currentdate];
            
            
            NSString *DateandTime = [NSString stringWithFormat:@"%@ %@",formaterdateString,formattedtimeString];
            
            
       
            NSArray *friends = [[QMApi instance] contactsOnly];
            if([friends containsObject:vc.opponent]){
                
                [[QMApi instance] addoutgoingaudiocall:vc.opponent type:@"OUTGOING CALL" date:DateandTime user:currentuser calltype:calltype];
               

            }
            
            
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            [navVC setNavigationBarHidden:YES];
            
            if( pushEnabled ){
                [strongSelf sendPushToUserWithUserID:opponentID];
            }
            
            [strongSelf.rootViewController presentViewController:navVC
                                                      animated:YES
                                                    completion:nil];
            [strongSelf.session startCall:@{kUserIds: users}];
            strongSelf.currentlyPresentedViewController = navVC;
        }
        else {
            
            [SVProgressHUD showErrorWithStatus:@"Error creating new session"];
        }
    }];
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo{
    
    if (self.session) {
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    [[QBRTCSoundRouter instance] initialize];
    
    self.session = session;
    [[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
    [self startPlayingRingtoneSound];
   
    [[QBRTCAudioSession instance] initializeWithConfigurationBlock:^(QBRTCAudioSessionConfiguration *configuration) {
        
        // adding bluetooth and airplay support
        configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
        configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
        configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
        
        if (session.conferenceType == QBRTCConferenceTypeVideo) {
            // setting mode to video chat to enable airplay audio and speaker only
            configuration.mode = AVAudioSessionModeVideoChat;
        }
    }];
    
    NSParameterAssert(!self.nav);
   
    NSDate *currentdate = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *formattedtimeString = [timeFormatter stringFromDate:currentdate];
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"dd/MM/yy"];
    NSString *formaterdateString = [dateformater stringFromDate:currentdate];
    
    
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
    {
        NSLog(@"background state");
        //Do checking here.
    }
    
    NSString *DateandTime = [NSString stringWithFormat:@"%@ %@",formaterdateString,formattedtimeString];
    
    if(session.conferenceType == QBRTCConferenceTypeAudio){
        
        IncomingCallController *incomingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallController];
        
        incomingVC.session = session;
        incomingVC.opponentID = [session.initiatorID unsignedIntegerValue];
        incomingVC.callType = session.conferenceType;
        incomingVC.opponent = [[QMApi instance] userWithID:incomingVC.opponentID];
        
        QBUUser *currentuser = self.currentUser;
        
        NSString *callform;
        if(session.conferenceType == QBRTCConferenceTypeAudio){
            
            callform = @"Audio";
        }
        else if(session.conferenceType == QBRTCConferenceTypeVideo){
            
            callform = @"Video";
        }
        
        NSArray *friends = [[QMApi instance] contactsOnly];
        if([friends containsObject:incomingVC.opponent]){
            
            
            [[QMApi instance] addincomingcall:currentuser type:@"INCOMING CALL" date:DateandTime user:incomingVC.opponent calltype:callform];
            
        }
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:incomingVC];
        [navVC setNavigationBarHidden:YES];
        [self.rootViewController presentViewController:navVC
                                              animated:YES
                                            completion:nil];
        
        self.currentlyPresentedViewController = navVC;

    }
    if(session.conferenceType == QBRTCConferenceTypeVideo){
        
        
        IncomingCallViewController *incomingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
        incomingVC.delegate = self;
        incomingVC.session = session;
        self.nav = [[UINavigationController alloc] initWithRootViewController:incomingVC];
        [self.nav setNavigationBarHidden:YES];
        [self.rootViewController presentViewController:self.nav
                                              animated:YES
                                            completion:nil];
        
        self.currentlyPresentedViewController = self.nav;
        
        QBUUser *currentuser = self.currentUser;
        
        NSString *callform;
        if(session.conferenceType == QBRTCConferenceTypeAudio){
            
            callform = @"Audio";
        }
        else if(session.conferenceType == QBRTCConferenceTypeVideo){
            
            callform = @"Video";
        }
        NSUInteger opponentID = [session.initiatorID unsignedIntegerValue];
        QBUUser *opponent = [[QMApi instance].usersService.usersMemoryStorage userWithID:opponentID];
        NSArray *friends = [[QMApi instance] contactsOnly];
        if([friends containsObject:opponent]){
            
            
            [[QMApi instance] addincomingcall:currentuser type:@"INCOMING CALL" date:DateandTime user:opponent calltype:callform];
            
        }


    }
 
}
//- (void)sessionDidClose:(QBRTCSession *)session {
//    
//    if (session == self.session ) {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            self.currentlyPresentedViewController.view.userInteractionEnabled = NO;
//            [self.currentlyPresentedViewController dismissViewControllerAnimated:NO completion:nil];
//            self.session = nil;
//            self.currentlyPresentedViewController = nil;
//        });
//    }
//}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didAcceptSession:(QBRTCSession *)session {
    
    [self stopAllSounds];
    CallViewController *callViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewController"];
   // [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    
    callViewController.session = session;
    //callViewController.usersDatasource = self.dataSource;
    self.nav.viewControllers = @[callViewController];
}

- (void)incomingCallViewController:(IncomingCallViewController *)vc didRejectSession:(QBRTCSession *)session {
    
    [self stopAllSounds];
    [session rejectCall:nil];
    [self.nav dismissViewControllerAnimated:NO completion:nil];
    self.nav = nil;
}

- (void)sessionWillClose:(QBRTCSession *)session {
    if( self.session != session ){
        // may be we rejected someone else call while we are talking with another person
        return;
    }
    
    [self stopAllSounds];
    ILog(@"session will close");
    [SVProgressHUD dismiss];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if( self.session != session ){
        // may be we rejected someone else call while we are talking with another person
        return;
    }
    [self stopAllSounds];
    [[QBRTCSoundRouter instance] deinitialize];
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if(session.conferenceType == QBRTCConferenceTypeAudio){
            
            weakSelf.session = nil;
            if( [weakSelf currentlyPresentedViewController] ){
                [[weakSelf currentlyPresentedViewController] dismissViewControllerAnimated:YES completion:nil];
            }
            if( !IS_IPAD ){
                weakSelf.frontCamera = YES;
            }
        }
        if(session.conferenceType == QBRTCConferenceTypeVideo){
            
            self.nav.view.userInteractionEnabled = NO;
            [self.nav dismissViewControllerAnimated:NO completion:nil];
            [[weakSelf currentlyPresentedViewController] dismissViewControllerAnimated:YES completion:nil];
            self.session = nil;
            self.nav = nil;
        
        }
        });
    
       
    
}
-(void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID{
    self.remoteVideoTrack = videoTrack;
}
//- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack{
//    self.localVideoTrack = videoTrack;
//}
//
//- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID{
//    self.remoteVideoTrack = videoTrack;
//}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID{
    [self stopAllSounds];
}

- (void)startPlayingCallingSound {
    [self stopAllSounds];
    self.callingSoundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                              target:self
                                                            selector:@selector(playCallingSound:)
                                                            userInfo:nil
                                                             repeats:YES];
    [self playCallingSound:nil];
}

- (void)startPlayingRingtoneSound {
    
    [self stopAllSounds];
    self.callingSoundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                              target:self
                                                            selector:@selector(playRingtoneSound:)
                                                            userInfo:nil
                                                             repeats:YES];
    [self playRingtoneSound:nil];
}

# pragma mark Sounds Private methods -

- (void)playCallingSound:(id)sender {
    [QMSoundManager playCallingSound];
}

- (void)playRingtoneSound:(id)sender {
    [QMSoundManager playRingtoneSound];
}

- (void)stopAllSounds {
    
    if( self.callingSoundTimer != nil ){
        [self.callingSoundTimer invalidate];
        self.callingSoundTimer = nil;
    }
    
    [[QMSoundManager instance] stopAllSounds];
}
@end
