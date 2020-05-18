//
//  DialogCell.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "DialogCell.h"
#import "QBApi.h"
#import "QMImageView.h"
#import "NSString+GTMNSStringHTMLAdditions.h"

@interface DialogCell()

@property (strong, nonatomic) IBOutlet UILabel *unreadMsgNumb;
@property (strong, nonatomic) IBOutlet UILabel *groupMembersNumb;

@property (strong, nonatomic) IBOutlet UIImageView *groupNumbBackground;
@property (strong, nonatomic) IBOutlet UIImageView *unreadMsgBackground;

@end

@implementation DialogCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setDialog:(QBChatDialog *)dialog {
    
    if (_dialog != dialog) {
        _dialog = dialog;
        
    }
    [self configureCellWithDialog:dialog];
}

- (void)configureCellWithDialog:(QBChatDialog *)chatDialog {
    
    BOOL isGroup = (chatDialog.type == QBChatDialogTypeGroup);
    self.descriptionLabel.text =  [chatDialog.lastMessageText gtm_stringByUnescapingFromHTML];
    self.groupMembersNumb.hidden = self.groupNumbBackground.hidden = !isGroup;
    self.unreadMsgBackground.hidden = self.unreadMsgNumb.hidden = (chatDialog.unreadMessagesCount == 0);
    self.unreadMsgNumb.text = [NSString stringWithFormat:@"%d", chatDialog.unreadMessagesCount];
    
    if (!isGroup) {
        
        NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        QBUUser *opponent = [[QMApi instance] userWithID:opponentID];
        
        NSURL *url = [NSURL URLWithString:opponent.avatarUrl];
        [self setUserImageWithUrl:url];
        
        self.titleLabel.text = opponent.fullName;
        
    } else {
        
        UIImage *img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        [self.qmImageView setImageWithURL:[NSURL URLWithString:chatDialog.photo] placeholder:img options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {} completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
        self.titleLabel.text = chatDialog.name;
        self.groupMembersNumb.text = [NSString stringWithFormat:@"%d", chatDialog.occupantIDs.count];
    }
}

@end
