//
//  DialogsViewController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "DialogsViewController.h"
#import "ChatVC.h"
#import "QMCreateNewChatController.h"
#import "DialogsDataSource.h"
#import "REAlertView+QMSuccess.h"
#import "QBApi.h"
#import <UIKit/UIKit.h>

//.. Wazowski Edition
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBAnalytics.h>
#import <Chartboost/CBInPlay.h>

#import <StoreKit/StoreKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
//..

static NSString *const ChatListCellIdentifier = @"ChatListCell";
static NSString *kDeleteAllTitle = @"Delete All";
static NSString *kDeletePartialTitle = @"Delete (%d)";


@interface DialogsViewController ()

<UITableViewDelegate, QMDialogsDataSourceDelegate,GADBannerViewDelegate>
{
    UIBarButtonItem *editButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *addButton;
    UIBarButtonItem *deleteButton;
    NSMutableArray *deletionIndexPath;
    NSMutableArray *chatdialogs;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DialogsDataSource *dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *additem;
@property (strong,nonatomic) GADBannerView *bannerview;


@end

@implementation DialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    deletionIndexPath = [NSMutableArray array];
    chatdialogs = [NSMutableArray array];
    
    
    UIImage *image = [UIImage imageNamed:@"bar-logo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    
    cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton:)];
    
    deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteButton:)];
    
    addButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"new_chat"]
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(createNewDialog:)];
    deleteButton.tintColor = [UIColor redColor];

      self.tableView.allowsMultipleSelectionDuringEditing = YES;

    [self.navigationItem setLeftBarButtonItem:editButton];
    [self.navigationItem setRightBarButtonItem:addButton];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[DialogsDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.dataSource fetchUnreadDialogsCount];
    [self.tableView reloadData];
    
  //  [self loadbanner];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.editing){
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        QBChatDialog *chatdialog = [self.dataSource dialogAtIndexPath:indexPath];
        [chatdialogs addObject:chatdialog];
        [deletionIndexPath addObject:indexPath];
        deleteButton.title = (selectedRows.count == 0) ?
        kDeleteAllTitle : [NSString stringWithFormat:kDeletePartialTitle, selectedRows.count];
    
      
    }
    if(!tableView.editing){
    QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
    if (dialog) {
        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:nil];
    }
        
    }
    
    
}
-(void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [[QMApi instance] fetchAllDialogs:^{
       [[QMApi instance] joinGroupDialogs];
    }];
   // [self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_CHAT_CONNECTED", nil) duration:kQMDefaultNotificationDismissTime];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [[QMApi instance] fetchAllDialogs:^{
         [[QMApi instance] joinGroupDialogs];
    }];   // [self.navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:NSLocalizedString(@"QM_STR_CHAT_RECONNECTED", nil) duration:kQMDefaultNotificationDismissTime];
}

- (void)chatService:(QMChatService *)__unused chatService chatDidNotConnectWithError:(NSError *)error {
    
   // [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription]];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[DialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    if ([self.tableView.dataSource isKindOfClass:[DialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[DialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing)
    {
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
        [chatdialogs removeObject:dialog];
        [deletionIndexPath removeObject:indexPath];
        deleteButton.title = (selectedRows.count == 0) ?
        kDeleteAllTitle : [NSString stringWithFormat:kDeletePartialTitle, selectedRows.count];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        ChatVC *chatController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
        chatController.dialog = dialog;
        
    } else if ([segue.destinationViewController isKindOfClass:[QMCreateNewChatController class]]) {
        
    }
}
-(void)editButton:(id)sender {
    
    if([self.dataSource dialogs].count == 0){
        
        [self.tableView setEditing:NO animated:NO];
        [self.navigationItem setRightBarButtonItem:addButton];
        
    }
    else{
       
        self.navigationItem.rightBarButtonItem = cancelButton;
        deleteButton.title = kDeleteAllTitle;
        self.navigationItem.leftBarButtonItem = deleteButton;
        [self.tableView setEditing:YES animated:YES];
    }
    
    
}
-(void)cancelButton:(id)sender {
    
    [deletionIndexPath removeAllObjects];
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = addButton;
    [self.tableView setEditing:NO animated:NO];
}
-(void)deleteButton:(id)sender {
    
    self.navigationItem.leftBarButtonItem = editButton;
    self.navigationItem.rightBarButtonItem = addButton;
    [self.tableView setEditing:NO animated:NO];
    NSMutableArray *dialogs = [self.dataSource dialogs];
    
     NSLog(@"dialog count before %lu",(unsigned long)dialogs.count);
    
    for(NSUInteger i =0; i< chatdialogs.count; i++){
        
       
        QBChatDialog *dialog = chatdialogs[i];
    

        [[QMApi instance].chatService.dialogsMemoryStorage  deleteChatDialogWithID:dialog.ID];
        [[QMApi instance].chatService deleteDialogWithID:dialog.ID];
        
        
        [[QMChatCache instance] deleteDialogWithID:dialog.ID completion:^{
            
            [self.tableView reloadData];
            
            // [self.dialogs removeObjectAtIndex:indexPath.row];
            NSLog(@"dialog count after %lu",(unsigned long)[self.dataSource dialogs].count);
            
            
        }];
    }
        if([self.dataSource dialogs].count == 0){
            
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView setEditing:NO animated:NO];
            
            
        }
        else{
            
            [self.tableView  deleteRowsAtIndexPaths:deletionIndexPath withRowAnimation:UITableViewRowAnimationFade];
            
        }

    
   
  //  [deletionIndexPath removeAllObjects];

}
#pragma mark - Actions

- (IBAction)createNewDialog:(id)sender
{
    //.. Wazowski Edition
    BOOL removeads = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeadskey"];
    if(removeads == YES){
        NSLog(@"remove ads purchased...");
    }
    else {
        [Chartboost showInterstitial:CBLocationDefault];
    }

    //..
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    if ([[QMApi instance].contactsOnly count] == 0) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_ERROR_WHILE_CREATING_NEW_CHAT", nil) actionSuccess:NO];
        return;
    }
    [self performSegueWithIdentifier:kCreateNewChatSegueIdentifier sender:nil];
}

#pragma mark - QMDialogsDataSourceDelegate

- (void)didChangeUnreadDialogCount:(NSUInteger)unreadDialogsCount {
    
    NSUInteger idx = [self.tabBarController.viewControllers indexOfObject:self.navigationController];
    if (idx != NSNotFound) {
        UITabBarItem *item = self.tabBarController.tabBar.items[idx];
        item.badgeValue = unreadDialogsCount > 0 ? [NSString stringWithFormat:@"%zd", unreadDialogsCount] : nil;
        
    }
}



@end
