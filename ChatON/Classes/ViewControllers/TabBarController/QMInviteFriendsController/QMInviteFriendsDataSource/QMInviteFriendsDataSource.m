//
//  QMInviteFriendsDataSource.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteFriendsDataSource.h"
#import "InviteFriendCell.h"
#import "InviteStaticCell.h"
#import "ABPerson.h"
#import "QBApi.h"
#import "FacebookService.h"
#import "AddressBook.h"
#import "SVProgressHUD.h"
#import <MessageUI/MessageUI.h>


#import <FBSDKShareKit/FBSDKShareKit.h>

typedef NS_ENUM(NSUInteger, QMCollectionGroup) {
    
    QMStaticCellsSection = 0,
    QMFriendsListSection = 1,
    QMABFriendsToInviteSection = 3
};

NSString *const kQMInviteFriendCellID = @"InviteFriendCell";
NSString *const kQMStaticFBCellID = @"QMStaticFBCell";
NSString *const kQMStaticABCellID = @"QMStaticABCell";

const CGFloat kQMInviteFriendCellHeight = 60;
const CGFloat kQMStaticCellHeihgt = 44;
const NSUInteger kQMNumberOfSection = 2;

@interface QMInviteFriendsDataSource()

<UITableViewDataSource, CheckBoxProtocol, QMCheckBoxStateDelegate, FBSDKAppInviteDialogDelegate,MFMessageComposeViewControllerDelegate>
{
    NSArray *searchResults;
}
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UISearchDisplayController *searchDisplayController;
@property (strong, nonatomic) NSMutableDictionary *collections;
@property (strong, nonatomic) InviteStaticCell *abStaticCell;
@property (strong, nonatomic) InviteStaticCell *fbStaticCell;

@property (strong, nonatomic) NSArray *abUsers;

@end

@implementation QMInviteFriendsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView searchDisplayController:(UISearchDisplayController *)searchDisplayController {
    
    self = [super init];
    if (self) {
        
        _collections = [NSMutableDictionary dictionary];
        _abUsers = @[];
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.checkBoxDelegate = self;
        
        self.searchDisplayController = searchDisplayController;
        
        self.searchDisplayController.searchResultsDataSource = self;
        self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;

        self.abStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kQMStaticABCellID];
        self.abStaticCell.delegate = self;
        
        self.fbStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kQMStaticFBCellID];
        
        NSArray *staticCells = @[self.fbStaticCell, self.abStaticCell];

        [self setCollection:staticCells toSection:QMStaticCellsSection];
        [self setCollection:@[].mutableCopy toSection:QMABFriendsToInviteSection];
    }
    [self fetchAdressbookFriends:nil];
    return self;
}
-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    
    return YES;
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self.fullName contains[c] %@", searchText];
    searchResults = [_abUsers filteredArrayUsingPredicate:resultPredicate]
    ;
    
    NSLog(@"search results %@",searchResults);
    //    if(searchResults.count > 0){
    //
    //       //  __weak __typeof(self)weakSelf = self;
    //        _abUsers = searchResults ;
    //        NSLog(@"new abusers %@",self.abUsers);
    //       // [self.searchDisplayController.searchResultsTableView reloadData];
    //
    //
    //        NSArray *array = [self collectionAtSection:QMFriendsListSection];
    //        NSLog(@"array count %lu",(unsigned long)
    //              array.count);
    //        [self updateDatasource];
    //    }
    //
    
}
#pragma mark - fetch user 

- (void)fetchFacebookFriends:(void(^)(void))completion {
    
    [[QMApi instance] fbInviteDialogWithDelegate:self];
}

- (void)fetchAdressbookFriends:(void(^)(void))completion {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    __weak __typeof(self)weakSelf = self;
    [AddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contacts, BOOL success, NSError *error) {
        
        weakSelf.abUsers = contacts;
        [SVProgressHUD dismiss];
        
        if (completion) completion();
        
    }];
}

#pragma mark FBSDKAppInviteDialogDelegate

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results {
    [SVProgressHUD showSuccessWithStatus:@"Success"];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error {
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
}

#pragma mark - setters

- (void)setAbUsers:(NSArray *)abUsers {
    
    abUsers = [self sortUsersByKey:@"fullName" users:abUsers];
    if (![_abUsers isEqualToArray:abUsers]) {
        _abUsers = abUsers;
        [self updateDatasource];
    }
}

- (NSArray *)sortUsersByKey:(NSString *)key users:(NSArray *)users {
    
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    
    return sortedUsers;
}

- (void)reloadFriendSectionWithRowAnimation:(UITableViewRowAnimation)animation {
    
    [self.tableView beginUpdates];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:QMFriendsListSection];
    [self.tableView reloadSections:indexSet withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)reloadRowPathAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
   
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)updateDatasource {
    
    NSArray * friendsCollection = self.abUsers;
    [self setCollection:friendsCollection toSection:QMFriendsListSection];
    [self reloadFriendSectionWithRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView != self.searchDisplayController.searchResultsTableView)
    {
        return kQMNumberOfSection;
    }
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        
        return [searchResults count];
        
        
    }
    else
    {
        NSArray *collection = [self collectionAtSection:section];
        
        return collection.count;
    }
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"cancel");
    [self.tableView setDataSource:self];
    //[self reloadDataSource];
    [self.tableView reloadData];
    //  [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"table"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id userData= nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        
        InviteFriendCell *cell = (InviteFriendCell *)[self.tableView dequeueReusableCellWithIdentifier:kQMInviteFriendCellID];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[InviteFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kQMInviteFriendCellID];
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"table"];

        UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if(IS_IPHONE_6){
            inviteButton.frame = CGRectMake(280.0f, 6.0f, 80.0f, 34.0f);
        }
        else if(IS_IPHONE_6P){
            inviteButton.frame = CGRectMake(310.0f, 6.0f, 80.0f, 34.0f);
        }
        else{
            inviteButton.frame = CGRectMake(230.0f, 6.0f, 80.0f, 34.0f);
        }
        [inviteButton setTitle:@"INVITE" forState:UIControlStateNormal];
        inviteButton.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
        [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [inviteButton addTarget:self action:@selector(DeleteRow:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:inviteButton];
        
        userData = [searchResults objectAtIndex:indexPath.row];
        _search = searchResults;
        
        if ([userData isKindOfClass:[QBUUser class]]) {
            QBUUser *user = userData;
            cell.contactlistItem = [[QMApi instance] contactItemWithUserID:user.ID];
        }
        
        cell.userData = userData;
     //   cell.check = [self checkedAtIndexPath:indexPath];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    else {
        
        
        
        if (indexPath.section == QMStaticCellsSection) {
            
            InviteStaticCell *staticCell = [self itemAtIndexPath:indexPath];
            NSArray *array = [self collectionAtSection:QMABFriendsToInviteSection];
            //staticCell.badgeCount = array.count;
            
            return staticCell;
        }
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"table"];
        
        
        
        InviteFriendCell *cell = (InviteFriendCell *)[tableView dequeueReusableCellWithIdentifier:kQMInviteFriendCellID];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[InviteFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kQMInviteFriendCellID];
        }
        //  QMInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMInviteFriendCellID];
        
        UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        if(IS_IPHONE_6){
            inviteButton.frame = CGRectMake(280.0f, 6.0f, 80.0f, 34.0f);
        }
        else if(IS_IPHONE_6P){
            inviteButton.frame = CGRectMake(310.0f, 6.0f, 80.0f, 34.0f);
        }
        else{
            inviteButton.frame = CGRectMake(230.0f, 6.0f, 80.0f, 34.0f);
        }
        [cell addSubview:inviteButton];
        [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [inviteButton setTitle:@"INVITE" forState:UIControlStateNormal];
        inviteButton.backgroundColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
        
        [inviteButton addTarget:self action:@selector(DeleteRow:) forControlEvents:UIControlEventTouchUpInside];
        userData = [_abUsers objectAtIndex:indexPath.row];
        
        _allusers = _abUsers;
        
        if ([userData isKindOfClass:[QBUUser class]]) {
            QBUUser *user = userData;
            cell.contactlistItem = [[QMApi instance] contactItemWithUserID:user.ID];
        }
        
        cell.userData = userData;
        cell.check = [self checkedAtIndexPath:indexPath];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return cell;
    }
    
  
}
-(void) DeleteRow:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    NSLog(@"%ld",(long)indexPath.row);
    
    UIButton *senderButton = (UIButton*)sender;
    
    
    BOOL tablenum = [[NSUserDefaults standardUserDefaults] objectForKey:@"table"];
    NSLog(@"tablenum %d",tablenum);
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"table"]){
        
        
        CGPoint pointInSuperview = [senderButton.superview convertPoint:senderButton.center toView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInSuperview];
        id userData = [ _allusers objectAtIndex:indexPath.row];
        ABPerson *person = userData;
        
        NSLog(@"user data %@",person.phonenumbers);
        
        if (person.phonenumbers.count > 0) {
            
            // INVITE THROUGH PHONE
            
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;
            }
            
            NSArray *recipents  = person.phonenumbers;
            NSString *message = kMailBodyString;
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            // Present message view controller on screen
            UIViewController *currentTopVC = [self currentTopViewController];
            
            [currentTopVC presentViewController:messageController animated:YES completion:nil];
            
        }
        
        
    }
    else {
        
        CGPoint pointInSuperview = [senderButton.superview convertPoint:senderButton.center toView:self.searchDisplayController.searchResultsTableView];
        
        NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForRowAtPoint:pointInSuperview];
        id userData = [_search objectAtIndex:indexPath.row];
        ABPerson *person = userData;
        
        NSLog(@"user search data %@",person.phonenumbers);
        if (person.phonenumbers.count > 0) {
            
            //INVITE THROUGH PHONE
            
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;
            }
            
            NSArray *recipents  = person.phonenumbers;
            NSString *message = kMailBodyString;
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            // Present message view controller on screen
            UIViewController *currentTopVC = [self currentTopViewController];
            
            [currentTopVC presentViewController:messageController animated:YES completion:nil];

        }
        
        
        
    }
    
    //  QMInviteViewController *view = [[QMInviteViewController alloc] init];
    //  [view btninviteaction:sender];
    
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
            
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Send" message:@"Succesfully send invitation SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
            
        default:
            break;
    }
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC dismissViewControllerAnimated:YES completion:nil];
    
    
    //  [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
#pragma mark - keys
/**
 Access key for collection At section
 */
- (NSString *)keyAtSection:(NSUInteger)section {
    
    NSString *sectionKey = [NSString stringWithFormat:@"section - %d", section];
    return sectionKey;
}

#pragma mark - collections

- (NSMutableArray *)collectionAtSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    NSMutableArray *collection = self.collections[key];
    
    return collection;
}

- (void)setCollection:(NSArray *)collection toSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    self.collections[key] = collection;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *collection = [self collectionAtSection:indexPath.section];
    id item = collection[indexPath.row];
    
    return item;
}

- (NSInteger)sectionToInviteWihtUserData:(id)data {
    
    if ([data isKindOfClass:ABPerson.class]) {
        return QMABFriendsToInviteSection;
    }
	return -1;
    NSAssert(nil, @"Need update this case");
    return 0;
}

- (BOOL)checkedAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    NSInteger sectionToInvite = [self sectionToInviteWihtUserData:item];
    NSArray *toInvite = [self collectionAtSection:sectionToInvite];
    BOOL checked = [toInvite containsObject:item];
    
    return checked;
}

#pragma mark - CheckBoxProtocol

- (void)containerView:(UIView *)containerView didChangeState:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(id)containerView];
   __weak __typeof(self)weakSelf = self;
    void (^update)(NSUInteger, NSArray*) = ^(NSUInteger collectionSection, NSArray *collection){
        
        InviteStaticCell *cell = (InviteStaticCell *)containerView;
        
        [weakSelf setCollection:cell.isChecked ? collection.mutableCopy : @[].mutableCopy toSection:collectionSection];
        [weakSelf reloadRowPathAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf reloadFriendSectionWithRowAnimation:UITableViewRowAnimationNone];
    };
    
    if (containerView == self.abStaticCell) {
        
        if (self.abUsers.count == 0) {
            [self fetchAdressbookFriends:^{
                update(QMABFriendsToInviteSection, weakSelf.abUsers);
            }];
        }
        else {
            update(QMABFriendsToInviteSection, self.abUsers);
        }
        
    }
    else  {
        
        InviteFriendCell *cell = (InviteFriendCell *)containerView;
        
        id item = [self itemAtIndexPath:indexPath];
        
        NSInteger section = [self sectionToInviteWihtUserData:item];
		if (section == -1) {
			return;
		}
        NSMutableArray *toInvite = [self collectionAtSection:section];
        cell.isChecked ? [toInvite addObject:item] : [toInvite removeObject:item];
    
        NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:1 inSection:QMStaticCellsSection];
        
        [self reloadRowPathAtIndexPath:indexPathToReload withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self checkListDidChange];
}

- (void)clearABFriendsToInvite  {
    
    [self setCollection:@[].mutableCopy toSection:QMABFriendsToInviteSection];
    [self.tableView reloadData];
    [self checkListDidChange];
}


- (void)checkListDidChange {
    
    NSArray *addressBookFriendsToInvite = self.collections [[self keyAtSection:QMABFriendsToInviteSection]];
    [self.checkBoxDelegate checkListDidChangeCount:(addressBookFriendsToInvite.count)];
}

#pragma mark - Public methods
#pragma mark Invite Data

- (NSArray *)emailsToInvite {
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *addressBookUsersToInvite = [self collectionAtSection:QMABFriendsToInviteSection];
    for (ABPerson *user in addressBookUsersToInvite) {
        [result addObject:user.phonenumbers.firstObject];
    }
    
    return result;
}

#pragma mark -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return kQMInviteFriendCellHeight;
        
    }
    else
    {
        if (indexPath.section == QMStaticCellsSection ) {
            return kQMStaticCellHeihgt;
        } else if (indexPath.section == QMFriendsListSection) {
            return kQMInviteFriendCellHeight;
        }
    }
    
    
    NSAssert(nil, @"Need Update this case");
    return 0;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection) {
        
        switch (indexPath.row) {
            case 0: [self fetchFacebookFriends:nil]; break;
            case 1:[self fetchAdressbookFriends:nil]; break;
            default:NSAssert(nil, @"Need Update this case"); break;
        }
    }
}

@end
