//
//  QMAddMembersToGroupController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddMembersToGroupController.h"
#import "QBApi.h"
#import "SVProgressHUD.h"
#import "UsersUtils.h"

@implementation QMAddMembersToGroupController


- (void)viewDidLoad {
    
    NSArray *friends = [[QMApi instance] contactsOnly];
    NSArray *usersIDs = [[QMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    NSArray *toAdd = [[QMApi instance] usersWithIDs:friendsIDsToAdd];
    self.contacts = [UsersUtils sortUsersByFullname:toAdd];
    
    [super viewDidLoad];
}

#pragma mark - Overriden methods

- (IBAction)performAction:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] joinOccupants:self.selectedFriends toChatDialog:self.chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
        
        [SVProgressHUD dismiss];
    }];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}

@end
