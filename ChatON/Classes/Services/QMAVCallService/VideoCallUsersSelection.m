//
//  VideoCallUsersSelection.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "VideoCallUsersSelection.h"
#import "QBApi.h"
#import "UsersUtils.h"
#import "AlertView.h"
#import "CallViewController.h"
#import "SVProgressHUD.h"
#import "IncomingCallViewController.h"
#import "QMSoundManager.h"
#import "SettingsManager.h"

@interface VideoCallUsersSelection ()<QBRTCClientDelegate,IncomingCallViewControllerDelegate>

@property (weak, nonatomic)  QBRTCSession *session;
@property (strong, nonatomic) UINavigationController *nav;
@property (weak, nonatomic) IBOutlet UIButton *videocall;



@end

@implementation VideoCallUsersSelection


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QBRTCClient.instance addDelegate:self];
    NSArray *unsortedContacts = [[QMApi instance] contactsOnly];
    self.contacts = [UsersUtils sortUsersByFullname:unsortedContacts];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)PerformAction:(id)sender {
    
   [self callWithConferenceType:QBRTCConferenceTypeVideo];
    
}

- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType {
    
    if (self.session) {
        return;
    }
    QBUUser *currentuser = [QMApi instance].currentUser;
    //if ([self hasConnectivity]) {
    
  
        [self checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
            
            if (granted) {
                
                NSArray *opponentsIDs = [[QMApi instance] idsWithUsers:self.selectedFriends];
                NSString *IDs = [self chatNameFromUserNames:self.selectedFriends];
                NSLog(@"user ids %@",IDs);
                // NSUInteger opponentID = [((NSNumber *)opponentsIDs[0]) unsignedIntegerValue];
                //Create new session
                QBRTCSession *session =
                [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                                 withConferenceType:conferenceType];
                
                if (session) {
                    
                    self.session = session;
                    CallViewController *callViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
                    callViewController.session = self.session;
                  //  callViewController.usersDatasource = self.dataSource;
                    
                    NSDate *currentdate = [NSDate date];
                    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
                    [timeFormatter setDateFormat:@"hh:mm a"];
                    NSString *formattedtimeString = [timeFormatter stringFromDate:currentdate];
                    
                    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
                    [dateformater setDateFormat:@"dd/MM/yy"];
                    NSString *formaterdateString = [dateformater stringFromDate:currentdate];
                    
                    
                    NSString *DateandTime = [NSString stringWithFormat:@"%@ %@",formaterdateString,formattedtimeString];
                    
                    if([QMApi instance].settingsManager.pushNotificationsEnabled){
                        
                        QBMEvent *event = [QBMEvent event];
                        event.usersIDs = IDs;
                        event.notificationType = QBMNotificationTypePush;
                        event.type = QBMEventTypeOneShot;
                        event.message = [NSString stringWithFormat:@"%@ is calling you", [QMApi instance].currentUser.fullName];
                        [QBRequest createEvent:event successBlock:nil errorBlock:nil];
                    }
                
                        [[QMApi instance] addoutgoingvideocall:self.selectedFriends type:@"OUTGOING CALL" date:DateandTime user:currentuser calltype:@"Video"];
                  
                    
                    self.nav = [[UINavigationController alloc] initWithRootViewController:callViewController];
                    self.nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    
                    [self presentViewController:self.nav animated:NO completion:nil];
                }
                else {
                    
                    [SVProgressHUD showErrorWithStatus:@"You should login to use chat API. Session hasn’t been created. Please try to relogin the chat."];
                }
            }
        }];
   // }
}
- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        NSString *ID = [NSString stringWithFormat:@"%lu",(unsigned long)user.ID];
        [names addObject:ID];
    }
    
   
    return [names componentsJoinedByString:@", "];
}
- (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
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
                            [self showAlertViewWithMessage:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil)];
                             
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
                [self showAlertViewWithMessage:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil)];
            }
        }
    }];
}


- (BOOL)hasConnectivity {
    
    BOOL hasConnectivity = [QMApi instance].networkStatus != QBNetworkStatusNotReachable;
    
    if (!hasConnectivity) {
        [self showAlertViewWithMessage:NSLocalizedString(@"Please check your Internet connection", nil)];
    }
    
    return hasConnectivity;
}
const NSUInteger kMaxUsersToCall = 5;



- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    
    if (self.session ) {
        
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.session = session;
    
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
    
    IncomingCallViewController *incomingViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"IncomingCallViewController"];
    incomingViewController.delegate = self;
    incomingViewController.session = session;
  //  incomingViewController.usersDatasource = self.dataSource;
    
    self.nav = [[UINavigationController alloc] initWithRootViewController:incomingViewController];
    [self presentViewController:self.nav animated:NO completion:nil];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (session == self.session ) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[QMSoundManager instance] stopAllSounds];
            self.nav.view.userInteractionEnabled = NO;
            [self.nav dismissViewControllerAnimated:NO completion:nil];
            self.session = nil;
            self.nav = nil;
        });
    }
}
@end
