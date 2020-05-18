//
//  IncomingCallController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "IncomingCallController.h"
#import "QBApi.h"
#import "QMImageView.h"
#import "QMSoundManager.h"
#import "VideoP2PController.h"
#import "CallManager.h"

@interface IncomingCallController ()<QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomingCallLabel;
@property (weak, nonatomic) IBOutlet QMImageView *userAvatarView;
/// buttons for audio
@property (weak, nonatomic) IBOutlet UIView *incomingCallView;
/// buttons for video
@property (weak, nonatomic) IBOutlet UIView *incomingVideoCallView;

@end

@implementation IncomingCallController

@synthesize opponent;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userAvatarView.imageViewType = QMImageViewTypeCircle;
    
    [QBRTCClient.instance addDelegate:self];
    
    opponent = [[QMApi instance] userWithID:self.opponentID];
    
    if( opponent ){
        self.userNameLabel.text = opponent.fullName;
    }
    else{
        self.userNameLabel.text = @"Unknown caller";
    }
 
    if (self.callType == QBRTCConferenceTypeVideo) {
        [self.incomingCallView setHidden:YES];
        self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_INCOMING_VIDEO_CALL", nil);
    } else if (self.callType == QBRTCConferenceTypeAudio) {
        [self.incomingVideoCallView setHidden:YES];
        self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_INCOMING_CALL", nil);
    }

    NSURL *url = [NSURL URLWithString:opponent.website];
    UIImage *placeholder = [UIImage imageNamed:@"upic_call"];
    
    [self.userAvatarView setImageWithURL:url
                             placeholder:placeholder
                                 options:SDWebImageLowPriority
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                          completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
     }];

}

#pragma mark - Actions

- (IBAction)acceptCall:(id)sender {
    __weak __typeof(self) weakSelf = self;
    [[[QMApi instance] avCallManager] checkPermissionsWithConferenceType:self.callType completion:^(BOOL canContinue) {
        if( canContinue ) {
			[[QMApi instance].avCallManager stopAllSounds];
            if (weakSelf.callType == QBRTCConferenceTypeVideo) {
                [weakSelf performSegueWithIdentifier:kGoToDuringVideoCallSegueIdentifier sender:weakSelf];
            } else {
                [weakSelf performSegueWithIdentifier:kGoToDuringAudioCallSegueIdentifier sender:nil];
            }
        }
    }];
}

- (IBAction)acceptCallWithVideo:(id)sender {
    __weak __typeof(self) weakSelf = self;
    [[QMApi instance].avCallManager stopAllSounds];
    [[[QMApi instance] avCallManager] checkPermissionsWithConferenceType:self.callType completion:^(BOOL canContinue) {
        if( canContinue ) {
            [[QMApi instance].avCallManager stopAllSounds];
            [weakSelf performSegueWithIdentifier:kGoToDuringVideoCallSegueIdentifier sender:nil];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // sender is not nil when accepting video call with denying my(local) video track
    if( [segue.identifier isEqualToString:kGoToDuringVideoCallSegueIdentifier] && sender != nil ){
     //   VideoP2PController *vc = segue.destinationViewController;
       // vc.disableSendingLocalVideoTrack = YES;
    }
}

- (IBAction)declineCall:(id)sender {
    
    [[QMApi instance].avCallManager stopAllSounds];
    [[QMApi instance] rejectCall];
    [QMSoundManager playEndOfCallSound];
    self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_CALL_WAS_CANCELLED", nil);
}

- (void)cleanUp {
    [[QMApi instance].avCallManager stopAllSounds];
    [QBRTCClient.instance removeDelegate:self];
}

- (void)sessionWillClose:(QBRTCSession *)session {
    if( self.session == session ) {
        [self cleanUp];
    }
}

- (void)dealloc {
    [self cleanUp];
}
@end
