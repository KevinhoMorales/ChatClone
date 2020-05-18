//
//  QMInviteFriendsStaticCell.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "InviteStaticCell.h"

@interface InviteStaticCell()

@property (weak, nonatomic) IBOutlet UILabel *badgeCounter;
@property (weak, nonatomic) IBOutlet UIImageView *activeCheckBox;

@end

@implementation InviteStaticCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.activeCheckBox.hidden = YES;
}

- (void)setBadgeCount:(NSUInteger)badgeCount {
    _badgeCount = badgeCount;

    self.badgeCounter.text = [NSString stringWithFormat:@"%d", badgeCount];
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        self.activeCheckBox.hidden = !check;
    }
}

- (IBAction)pressCheckBox:(id)sender {

    self.check ^= 1;
    [self.delegate containerView:self didChangeState:sender];
}

@end
