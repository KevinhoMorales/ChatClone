//
//  GroupDetailsDataSource.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "GroupDetailsDataSource.h"
#import "FriendListCell.h"
#import "QBApi.h"
#import "UsersUtils.h"
#import <SVProgressHUD.h>

NSString *const kFriendsListCellIdentifier = @"FriendListCell";
NSString *const kLeaveChatCellIdentifier = @"QMLeaveChatCell";

@interface GroupDetailsDataSource ()

<QMUsersListDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *participants;

@property (nonatomic, strong) QBChatDialog *chatDialog;

@end

@implementation GroupDetailsDataSource

- (id)initWithTableView:(UITableView *)tableView {

    if (self = [super init]) {
        
        _tableView = tableView;
        self.tableView.dataSource = nil;
        self.tableView.dataSource = self;
    }
    
    return self;
}

- (void)reloadDataWithChatDialog:(QBChatDialog *)chatDialog  {
    
    self.chatDialog = chatDialog;
    [self reloadUserData];
}

- (void)reloadUserData {
    
    //change
    
   BFTask *task = [[QMApi instance].usersService getUsersWithIDs:self.chatDialog.occupantIDs];
    NSArray *users_ = task.result;
   
    if(users_.count > 0){
        
        NSArray *unsortedParticipants = [[QMApi instance] usersWithIDs:self.chatDialog.occupantIDs];
        self.participants = [UsersUtils sortUsersByFullname:unsortedParticipants];
        [self.tableView reloadData];
    }
    
   
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? self.participants.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [tableView dequeueReusableCellWithIdentifier:kLeaveChatCellIdentifier];
    }
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsListCellIdentifier];

    QBUUser *user = self.participants[indexPath.row];
    
    cell.userData = user;
    cell.contactlistItem = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.delegate = self;
    
    return cell;
}


#pragma mark - QMFriendListCellDelegate

- (void)usersListCell:(FriendListCell *)cell pressAddBtn:(UIButton *)sender {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    QBUUser *user = self.participants[indexPath.row];
    [[QMApi instance] addUserToContactList:user completion:^(BOOL success, QBChatMessage *notification) {
        [SVProgressHUD dismiss];
    }];
}

@end
