//
//  QMInviteViewController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "InviteViewController.h"
#import "QMInviteFriendsDataSource.h"
#import "QBApi.h"
#import "MessageUI.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface InviteViewController ()

<MFMailComposeViewControllerDelegate, QMCheckBoxStateDelegate,MFMessageComposeViewControllerDelegate,GADBannerViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UISearchControllerDelegate,UISearchResultsUpdating>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) QMInviteFriendsDataSource *dataSource;
@property (strong,nonatomic) GADBannerView *bannerview;
@end

@implementation InviteViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = nil;
    
       
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    self.dataSource = [[QMInviteFriendsDataSource alloc] initWithTableView:self.tableView searchDisplayController:self.searchDisplayController];
    self.dataSource.checkBoxDelegate = self;
    
    [self changeSendButtonEnableForCheckedUsersCount:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    NSArray *abEmails = [weakSelf.dataSource emailsToInvite];
    if (abEmails.count > 0) {
        
        if (abEmails.count > 0) {
            
            // INVITE THROUGH PHONE
            
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;
            }
            
            NSArray *recipents  = abEmails;
            NSString *message = kMailBodyString;
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            UIViewController *currentTopVC = [self currentTopViewController];
            
            [currentTopVC presentViewController:messageController animated:YES completion:nil];
            

        }
    }
    
            
    
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    
    return [self.dataSource searchDisplayController:controller shouldReloadTableForSearchString:searchString];
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self.dataSource searchDisplayControllerWillEndSearch:controller];
}
- (void)changeSendButtonEnableForCheckedUsersCount:(NSInteger)checkedUsersCount
{
    self.sendButton.enabled = checkedUsersCount > 0;
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self loadbanner];
   
}

-(void)loadbanner {
    // [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"removeadskey"];
    
    
    BOOL removeads = [[NSUserDefaults standardUserDefaults] boolForKey:@"removeadskey"];
    if(removeads == YES){
        
        
        [self.bannerview removeFromSuperview];
        [_bannerview setHidden:YES];
        _bannerview.frame = CGRectMake(0, 0, 0, 0);
        _bannerview = nil;
        _bannerview.delegate = nil;
        _bannerview.rootViewController = nil;
        
        
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
#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataSource didSelectRowAtIndexPath:indexPath];
}


#pragma mark - QMCheckBoxStatusDelegate

- (void)checkListDidChangeCount:(NSInteger)checkedCount {
      [self changeSendButtonEnableForCheckedUsersCount:checkedCount];
}

@end
