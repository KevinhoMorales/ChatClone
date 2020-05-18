//
//  OpponentCollectionViewCell.m
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 11.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import "OpponentCollectionViewCell.h"
#import "CornerView.h"

static UIImage *unmutedImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"ic-qm-videocall-dynamic-off"];
    });
    return image;
}

static UIImage *mutedImage() {
    
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"ic-qm-videocall-dynamic-on"];
    });
    return image;
}

@interface OpponentCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@end

@implementation OpponentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.backgroundColor = [UIColor blackColor];
    self.statusLabel.backgroundColor =
    [UIColor colorWithRed:0.9441 green:0.9441 blue:0.9441 alpha:0.350031672297297];
    self.statusLabel.text = @"";
    
    [self.muteButton setImage:unmutedImage() forState:UIControlStateNormal];
    [self.muteButton setImage:mutedImage() forState:UIControlStateSelected];
    self.muteButton.hidden = YES;
}

- (void)setVideoView:(UIView *)videoView {
    
    if (_videoView != videoView) {

        [_videoView removeFromSuperview];
        _videoView = videoView;
        _videoView.frame = self.bounds;
        [self.containerView insertSubview:_videoView aboveSubview:self.statusLabel];
    }
}

- (void)setConnectionState:(QBRTCConnectionState)connectionState {
    
    if (_connectionState != connectionState) {
        _connectionState = connectionState;
        
        switch (connectionState) {
                
            case QBRTCConnectionNew:
                
                self.statusLabel.text = @"New";
                
                break;
                
            case QBRTCConnectionPending:
                
                self.statusLabel.text = @"Pending";
                
                break;
                
            case QBRTCConnectionChecking:
                
                self.statusLabel.text = @"Checking";
    
                break;
                
            case QBRTCConnectionConnecting:
                
                self.statusLabel.text = @"Connecting";
                
                break;
                
            case QBRTCConnectionConnected:
                
                self.statusLabel.text = @"Connected";
                
                break;
                
            case QBRTCConnectionClosed:
                
                self.statusLabel.text = @"Closed";
                
                break;
                
            case QBRTCConnectionHangUp:
                
                self.statusLabel.text = @"Hung Up";
                
                break;
                
            case QBRTCConnectionRejected:
                
                self.statusLabel.text = @"Rejected";
                
                break;
                
            case QBRTCConnectionNoAnswer:
                
                self.statusLabel.text = @"No Answer";
                
                break;
                
            case QBRTCConnectionDisconnectTimeout:
                
                self.statusLabel.text = @"Time out";
                
                break;
                
            case QBRTCConnectionDisconnected:
                
                self.statusLabel.text = @"Disconnected";
                
                break;
            default:
                break;
        }
        
        self.muteButton.hidden = !(connectionState == QBRTCConnectionConnected);
    }
}

// MARK: Mute button

- (IBAction)didPressMuteButton:(UIButton *)sender {
    
    sender.selected ^= 1;
    if (self.didPressMuteButton != nil) {
        self.didPressMuteButton(sender.isSelected);
    }
}

@end
