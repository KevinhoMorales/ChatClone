//
//  FriendsListDataSource.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

static NSString *const kQMFriendsListCellIdentifier = @"FriendListCell";
static NSString *const kQMDontHaveAnyFriendsCellIdentifier = @"QMDontHaveAnyFriendsCell";

@protocol QMFriendsListDataSourceDelegate <NSObject>

- (void)didChangeContactRequestsCount:(NSUInteger)contactRequestsCount;

@end

@interface FriendsListDataSource : NSObject <UITableViewDataSource, UISearchDisplayDelegate, QMUsersListDelegate,QMUsersServiceDelegate,QMUsersMemoryStorageDelegate>

@property (nonatomic, assign) BOOL viewIsShowed;
@property (weak, nonatomic) id <QMFriendsListDataSourceDelegate> delegate;
@property (strong, nonatomic) BFCancellationTokenSource *globalSearchCancellationTokenSource;

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController;
- (NSArray *)usersAtSections:(NSInteger)section;
- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath;

- (void)reloadDataSource;

@end
