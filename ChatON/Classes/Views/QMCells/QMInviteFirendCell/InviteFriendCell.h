//
//  QMInviteFriendsCell.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.

#import "CheckBoxProtocol.h"
#import "TableViewCell.h"

@class InviteFriendCell;

@interface InviteFriendCell : TableViewCell

@property (assign, nonatomic, getter = isChecked) BOOL check;
@property (weak, nonatomic) id <CheckBoxProtocol> delegate;

@end
