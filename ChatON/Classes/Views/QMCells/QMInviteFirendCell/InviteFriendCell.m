//
//  QMInviteFriendsCell.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "InviteFriendCell.h"
#import "ABPerson.h"
#import "QBApi.h"

@interface InviteFriendCell()

@property (weak, nonatomic) IBOutlet UIImageView *activeCheckbox;

@end

@implementation InviteFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.activeCheckbox.hidden = YES;
}

- (void)setUserData:(id)userData {
    
    [super setUserData:userData];
    
    if ([userData isKindOfClass:ABPerson.class]) {
        [self configureWithAdressaddressBookUser:userData];
    } else if ([userData isKindOfClass:[QBUUser class]]) {

        QBUUser *user = userData;
        self.titleLabel.text = (user.fullName.length == 0) ? @"" : user.fullName;
        NSURL *avatarUrl = [NSURL URLWithString:user.avatarUrl];
        [self setUserImageWithUrl:avatarUrl];
    } else {
        [self configureWithFBGraphUser:userData];
    }
}

- (void)setContactlistItem:(QBContactListItem *)contactlistItem {
    
    if (contactlistItem) {
        self.descriptionLabel.text = NSLocalizedString(contactlistItem.online ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
    }
}

- (void)configureWithFBGraphUser:(NSDictionary *)user {
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", [user valueForKey:@"first_name"], [user valueForKey:@"last_name"]];
    NSURL *url = [[QMApi instance] fbUserImageURLWithUserID:[user valueForKey:@"id"]];
    [self setUserImageWithUrl:url];
    self.descriptionLabel.text = NSLocalizedString(@"QM_STR_FACEBOOK", nil);
}

- (void)configureWithAdressaddressBookUser:(ABPerson *)addressBookUser {
    
    self.titleLabel.text = addressBookUser.fullName;
     self.descriptionLabel.text = addressBookUser.PhoneNumber;
    
  //  self.descriptionLabel.text = NSLocalizedString(@"QM_STR_CONTACT_LIST", nil);
    
    
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.image = addressBookUser.image;
    
    
    [self setUserImage:imageview.image withKey:addressBookUser.fullName];
}

- (void)setCheck:(BOOL)check {
    
    if (_check != check) {
        _check = check;
        self.activeCheckbox.hidden = !check;
    }
}

#pragma mark - Actions

- (IBAction)pressCheckBox:(id)sender {

    self.check ^= 1;
    [self.delegate containerView:self didChangeState:sender];
}

@end
