//
//  FriendListCell.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "TableViewCell.h"


@interface FriendListCell : TableViewCell

@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) id <QMUsersListDelegate>delegate;

-(void)setUserData:(id)userData;
@end
