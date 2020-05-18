//
//  QMCreateNewChatController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCreateNewChatController.h"
#import "ViewControllersFactory.h"
#import "SVProgressHUD.h"
#import "QBApi.h"
#import "UsersUtils.h"

NSString *const QMChatViewControllerID = @"ChatVC";

@implementation QMCreateNewChatController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    NSArray *unsortedContacts = [[QMApi instance] contactsOnly];
    self.contacts = [UsersUtils sortUsersByFullname:unsortedContacts];
    [super viewDidLoad];
}
 
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Overriden Actions

- (IBAction)performAction:(id)sender {
    
	NSMutableArray *selectedUsersMArray = self.selectedFriends;
    __weak __typeof(self)weakSelf = self;

    QBUUser *singleuser = [self chatNameForsingleUser:selectedUsersMArray];
    if(selectedUsersMArray.count == 1){
        
        [[QMApi instance]createPrivateChatDialogIfNeededWithOpponent:singleuser completion:^(QBChatDialog *createdDialog) {
            
            if (createdDialog) {
                UIViewController *chatVC = [QBViewControllersFactory chatControllerWithDialogID:createdDialog.ID];
                
                NSMutableArray *controllers = weakSelf.navigationController.viewControllers.mutableCopy;
                [controllers removeLastObject];
                [controllers addObject:chatVC];
                
                [weakSelf.navigationController setViewControllers:controllers animated:YES];
            }
            [SVProgressHUD dismiss];

        }];
    }
    else {
    NSString *chatName = [self chatNameFromUserNames:selectedUsersMArray];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    [[QMApi instance] createGroupChatDialogWithName:chatName occupants:self.selectedFriends completion:^(QBChatDialog *chatDialog) {
        
        if (chatDialog != nil) {
            
            UIViewController *chatVC = [QBViewControllersFactory chatControllerWithDialogID:chatDialog.ID];
            
            NSMutableArray *controllers = weakSelf.navigationController.viewControllers.mutableCopy;
            [controllers removeLastObject];
            [controllers addObject:chatVC];
            
            [weakSelf.navigationController setViewControllers:controllers animated:YES];
        }
        
        [SVProgressHUD dismiss];
        }];
        
    }
}
-(QBUUser *)chatNameForsingleUser:(NSMutableArray*)users {
    
  //  NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        return user;
    }
    return nil;
    
}
- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [names addObject:user.fullName];
    }
    
    [names addObject:[QMApi instance].currentUser.fullName];
    return [names componentsJoinedByString:@", "];
}

@end
