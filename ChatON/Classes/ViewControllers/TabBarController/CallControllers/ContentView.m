//
//  ContentView.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "ContentView.h"
#import "UsersUtils.h"

@interface ContentView()

@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, assign) double_t timeInterval;

@end

@implementation ContentView

/**
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation. 
 */
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.avatarView.imageViewType = QMImageViewTypeCircle;
}


#pragma mark - Show/Hide

- (void)show {
    [self setHidden:NO];
}

- (void)hide {
    [self setHidden:YES];
}


#pragma mark -

- (void)updateViewWithUser:(QBUUser *)user conferenceType:(QBRTCConferenceType)conferenceType isOpponentCaller:(BOOL)isOpponentCaller {
    UIImage *placeholder = [UIImage imageNamed:@"upic_call"];
    NSURL *url = [UsersUtils userAvatarURL:user];
    [self.avatarView setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageLowPriority
                            progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {}
                      completedBlock:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];

    self.fullNameLabel.text = user.fullName;
    
    // we are establishing a connection with opponent
    if( isOpponentCaller ){
        self.statusLabel.text = NSLocalizedString(@"QM_STR_CONNECTING", nil);
    }
    else if( conferenceType == QBRTCConferenceTypeAudio ) {
        self.statusLabel.text = isOpponentCaller ? NSLocalizedString(@"QM_STR_CONNECTING", nil) : NSLocalizedString(@"QM_STR_CALLING", nil);
    }
    else{
        self.statusLabel.text = NSLocalizedString(@"QM_STR_VIDEO_CALLING", nil);
    }
    
    [self layoutSubviews];
}

- (void)updateViewWithStatus:(NSString *)status {
    self.statusLabel.text = status;
}

- (void)startTimerIfNeeded {
    if( [_timer isValid] ){
        return;
    }
    _timeInterval = 0;
    self.statusLabel.text = [NSString stringWithFormat:@"%02u:%02u", (int)(_timeInterval/60), (int)fmod(_timeInterval, 60)];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateStatusLabel) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)startTimer {
    // stop if running
    [self stopTimer];
    [self startTimerIfNeeded];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
    _timeInterval = 0;
}

// selector:
- (void)updateStatusLabel {
    self.statusLabel.text = [NSString stringWithFormat:@"%02u:%02u", (int)(_timeInterval/60), (int)fmod(_timeInterval, 60)];
    _timeInterval++;
}

@end
