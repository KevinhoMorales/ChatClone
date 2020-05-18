 //
//  QMFriendListController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "FriendListViewController.h"
#import "FriendsDetailsController.h"
#import "MainTabBarController.h"
#import "FriendListCell.h"
#import "FriendsListDataSource.h"
#import "QBApi.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
@interface FriendListViewController ()

<UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, QMFriendsListDataSourceDelegate, QMFriendsTabDelegate,GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FriendsListDataSource *dataSource;
@property (strong,nonatomic) GADBannerView *bannerview;
@end



@implementation FriendListViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#define kQMSHOW_SEARCH 0

- (void)viewDidLoad {
    [super viewDidLoad];
    ((MainTabBarController *)self.tabBarController).tabDelegate = self;
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    
        
#if kQMSHOW_SEARCH
    [self.tableView setContentOffset:CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height) animated:NO];
#endif
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[FriendsListDataSource alloc] initWithTableView:self.tableView searchDisplayController:self.searchDisplayController];
    self.dataSource.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.dataSource.viewIsShowed = YES;
    [super viewWillAppear:animated];
    [self loadbanner];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.dataSource reloadDataSource];
}
-(void)loadbanner {
   //  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"removeadskey"];
    
    
    BOOL removeads = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeadskey"];
    if(removeads == YES){
        
        
        [self.bannerview removeFromSuperview];
        [_bannerview setHidden:YES];
        _bannerview.frame = CGRectMake(0, 0, 0, 0);
        _bannerview = nil;
        _bannerview.delegate = nil;
        _bannerview.rootViewController = nil;
       // [self.view setNeedsDisplay];
        
    }
    else{
        
        _bannerview = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _bannerview.adUnitID = @"ca-app-pub-4057351632708751/7502560433";
        [_bannerview loadRequest:[GADRequest request]];
        _bannerview.delegate = self;
        _bannerview.rootViewController = self;
        if(IS_IPHONE_5){
            
            _bannerview.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2+120, 420, 50);
        }
        else if(IS_IPHONE_6){
            _bannerview.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2+165, 420, 50);
        }
        else if(IS_IPHONE_6P){
            _bannerview.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2+200, 420, 50);
        }
        
        [self.view addSubview:_bannerview];
        
    }
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.dataSource.viewIsShowed = NO;
    [super viewWillDisappear:animated];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kQMDontHaveAnyFriendsCellIdentifier) {
        return;
    }
    
    QBUUser *selectedUser = [self.dataSource userAtIndexPath:indexPath];
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:selectedUser.ID];

    if (item) {
        [self performSegueWithIdentifier:kDetailsSegueIdentifier sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataSource numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}


#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return [self.dataSource searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}

-(void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillBeginSearch:controller];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillEndSearch:controller];
}


#pragma mark - prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kDetailsSegueIdentifier]) {
        
        NSIndexPath *indexPath = nil;
        if (self.searchDisplayController.isActive) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        FriendsDetailsController *vc = segue.destinationViewController;
        vc.selectedUser = [self.dataSource userAtIndexPath:indexPath];
    }
}


#pragma mark - QMFriendsListDataSourceDelegate

- (void)didChangeContactRequestsCount:(NSUInteger)contactRequestsCount
{
    NSUInteger idx = [self.tabBarController.viewControllers indexOfObject:self.navigationController];
    if (idx != NSNotFound) {
        UITabBarItem *item = self.tabBarController.tabBar.items[idx];
        item.badgeValue = contactRequestsCount > 0 ? [NSString stringWithFormat:@"%d", contactRequestsCount] : nil;
    }
}


#pragma mark - QMFriendsTabDelegate

- (void)friendsListTabWasTapped:(UITabBarItem *)tab
{
    [self.tableView reloadData];
}


@end
