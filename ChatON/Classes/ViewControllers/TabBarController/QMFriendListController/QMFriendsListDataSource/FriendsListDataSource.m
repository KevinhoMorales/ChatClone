
//
//  FriendsListDataSource.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "FriendsListDataSource.h"
#import "FriendListViewController.h"
#import "FriendListCell.h"
#import "QBApi.h"
#import "UsersUtils.h"
#import "SVProgressHud.h"
#import "AlertView.h"


@interface FriendsListDataSource()
<
QMContactListServiceDelegate,
QMUsersServiceDelegate
>


@property (strong, nonatomic) NSMutableArray *searchResult;
@property (strong, nonatomic) NSArray *friendList;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) QBRequest *searchRequest;

@property (assign, nonatomic) NSUInteger contactRequestsCount;

@end

@implementation FriendsListDataSource

@synthesize friendList = _friendList;

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController
{
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        [[QMApi instance].usersService addDelegate:self];
        [[QMApi instance].contactListService addDelegate:self];
        self.searchResult = [NSMutableArray array];
        
        self.searchDisplayController = searchDisplayController;

        [self updateView];
        UINib *friendsCellNib = [UINib nibWithNibName:@"FriendListCell" bundle:nil];
        UINib *noResultsCellNib = [UINib nibWithNibName:@"QMNoResultsCell" bundle:nil];
        
        [searchDisplayController.searchResultsTableView registerNib:friendsCellNib forCellReuseIdentifier:kQMFriendsListCellIdentifier];
        [searchDisplayController.searchResultsTableView registerNib:noResultsCellNib forCellReuseIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
    }
    
    return self;
}

- (void)dealloc {
    [[QMApi instance].contactListService removeDelegate:self];
}

- (void)setFriendList:(NSArray *)friendList {
    _friendList = [UsersUtils sortUsersByFullname:friendList];
}

- (NSArray *)friendList {
    
    if (self.searchDisplayController.isActive && self.searchDisplayController.searchBar.text.length > 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS[cd] %@", self.searchDisplayController.searchBar.text];
        NSArray *filtered = [_friendList filteredArrayUsingPredicate:predicate];
        
        return filtered;
    }
    return _friendList;
}

- (void)reloadDataSource {
    
    self.friendList = [QMApi instance].friends;
    if (self.viewIsShowed) {
        [self.tableView reloadData];
    }
    if (self.searchDisplayController.isActive) {
        [self globalSearch:self.searchDisplayController.searchBar.text];
    }
} 

- (void)globalSearch:(NSString *)searchText {
    
    self.globalSearchCancellationTokenSource = [BFCancellationTokenSource cancellationTokenSource];

    
    if (searchText.length == 0) {
        [self.searchResult removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    QBUUserPagedResponseBlock userResponseBlock = ^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        
           };
    
 
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self.searchDisplayController.searchBar.text isEqualToString:searchText]) {
            
            if (self.searchRequest) {
                [self.searchRequest cancel];
                self.searchRequest = nil;
            }
            
            NSUInteger currentPage = 1;
            NSUInteger perPage = 100;
            
            //change
             [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
           [ [[QMApi instance].usersService searchUsersWithFullName:searchText page:[QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage]] continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull task) {
                
                
              
                if (task.isCompleted) {
                    
                    [SVProgressHUD dismiss];
                    self.globalSearchCancellationTokenSource = nil;
                    NSArray *sortedUsers = [UsersUtils sortUsersByFullname:task.result];
                    
                    NSMutableArray *filteredUsers = [UsersUtils filteredUsers:sortedUsers withFlterArray:[weakSelf.friendList arrayByAddingObject:[QMApi instance].currentUser]];
                    
                    weakSelf.searchResult = filteredUsers;
                    
                    [weakSelf.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                    weakSelf.searchRequest = nil;
                    [SVProgressHUD dismiss];

                    
                   
                }
                
                return nil;
                
            } cancellationToken:self.globalSearchCancellationTokenSource.token];
            
              [self.searchDisplayController.searchResultsTableView reloadData];
           //[[QMApi instance].usersService searchUsersWithFullName:searchText page:[QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage]];
           
            
        }
    });
}

- (void)setContactRequestsCount:(NSUInteger)contactRequestsCount
{
    if (_contactRequestsCount != contactRequestsCount) {
        _contactRequestsCount = contactRequestsCount;
        if ([self.delegate respondsToSelector:@selector(didChangeContactRequestsCount:)]) {
            [self.delegate didChangeContactRequestsCount:_contactRequestsCount];
        }
    }
}

- (void)updateView {
    if (self.searchRequest) {
        return;
    }
    
    if (self.searchDisplayController.isActive) {
        
        self.friendList = [QMApi instance].friends;
        
        [self.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]   withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self reloadDataSource];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *users = [self usersAtSections:section];
    
    if (self.searchDisplayController.isActive && section == 1) {
        return (users.count > 0) ? NSLocalizedString(@"QM_STR_ALL_USERS", nil) : nil;
    }
    return (users.count > 0) ? NSLocalizedString(@"QM_STR_CONTACTS", nil) : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return (self.searchDisplayController.isActive) ? 2 : 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *users = [self usersAtSections:section];
    if (self.searchDisplayController.isActive) {
        return (users.count > 0) ? users.count : 0;
    }
    return (users.count > 0) ? users.count : 1;
}

- (NSArray *)usersAtSections:(NSInteger)section
{
    return (section == 0) ? self.friendList : self.searchResult;
}

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    QBUUser *user = users[indexPath.row];
    
    return user;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *users = [self usersAtSections:indexPath.section];
    
    if (!self.searchDisplayController.isActive) {
        if (users.count == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMDontHaveAnyFriendsCellIdentifier];
            return cell;
        }
    }
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMFriendsListCellIdentifier];
    cell.delegate = self;

    QBUUser *user = users[indexPath.row];
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.contactlistItem = item;
    cell.userData = user;
    
    if(self.searchDisplayController.isActive) {
        cell.searchText = self.searchDisplayController.searchBar.text;
    }
    
    return cell;
}


#pragma mark - QMUsersListCellDelegate

- (void)usersListCell:(FriendListCell *)cell pressAddBtn:(UIButton *)sender {
    
    NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
    NSArray *datasource = [self usersAtSections:indexPath.section];
    QBUUser *user = datasource[indexPath.row];
    
    NSInteger idx = [self.searchResult indexOfObject:user];
    if (idx != NSNotFound) {
        
        [self.searchResult removeObject:user];
        [self.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                                                           withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    BOOL isContactRequest = [[QMApi instance] isContactRequestUserWithID:user.ID];
    if (isContactRequest) {
        [[QMApi instance] confirmAddContactRequest:user completion:^(BOOL success) {
            [self reloadDataSource];
        }];
    } else {
        [[QMApi instance] addUserToContactList:user completion:^(BOOL success, QBChatMessage *notification) {
            [self reloadDataSource];
        }];
    }
}


#pragma mark - UISearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self globalSearch:searchString];
    return NO;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.tableView setDataSource:nil];
    [self.tableView reloadData];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView setDataSource:self];
    [self reloadDataSource];
    [self.tableView reloadData];
}

#pragma mark Contact List Serice Delegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateView];
    //[self.tableView reloadData];
}
- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateView];
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    [self updateView];
    [self.tableView reloadData];
}
- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
   
    [[QMApi instance].usersService getUsersWithIDs:[[QMApi instance].contactListService.contactListMemoryStorage userIDsFromContactList]];
    [self updateView];
}

- (void)contactListService:(QMContactListService *)contactListService didUpdateUser:(QBUUser *)user {
    [self updateView];
}

@end
