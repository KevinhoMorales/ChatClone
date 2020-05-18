
//
//  SettingsViewController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "SettingsViewController.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "SDWebImageManager.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "QMImageView.h"
#import "UsersUtils.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "IAPHelper.h"
#import "RageIAPHelper.h"
#import "InAppViewVC.h"



@interface SettingsViewController ()
{
    NSArray *_products;
}
@property (weak, nonatomic) IBOutlet UITableViewCell *restorecell;
@property (weak, nonatomic) IBOutlet UITableViewCell *Removeadscell;
@property (weak, nonatomic) IBOutlet UITableViewCell *TellFriendcell;
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *changePasswordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *cacheSize;
@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UITextView *currentstatus;
- (IBAction)Removeads:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *buybtn;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
  
    
   // self.pushNotificationSwitch.on = [QMApi instance].settingsManager.pushNotificationsEnabled;
    if ([QMApi instance].settingsManager.accountType == QMAccountTypeFacebook) {
        [self cell:self.changePasswordCell setHidden:YES];
    }
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSettingsCellBundleVersion];
    self.versionLabel.text = appVersion;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        
        return 40;
    }
    if(section == 2){
        return 40;
    }
    return 0;
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

    NSLog(@"current user website %@",self.currentUser.website);
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    NSLog(@"user %@",self.currentUser);
    NSLog(@"user2 %@",[QMApi instance].currentUser);
    self.avatarView.imageViewType = QMImageViewTypeCircle;
    self.username.text = self.currentUser.fullName;
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *url = [UsersUtils userAvatarURL:self.currentUser];
    
    [self.avatarView setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                            } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                                
                            }];
    self.currentstatus.text = self.currentUser.status;
    
    __weak __typeof(self)weakSelf = self;
    [[[SDWebImageManager sharedManager] imageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
      //  weakSelf.cacheSize.text = [NSString stringWithFormat:@"Cache size: %.2f mb", (float)totalSize / 1024.f / 1024.f];
    }];
}

-(void)hideIOS8PopOver
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIModalPresentationStyle) adaptivePresentationStyleForPresentationController: (UIPresentationController * ) controller {
    return UIModalPresentationNone;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell == self.Removeadscell){
        
        InAppViewVC *sm = [self.storyboard instantiateViewControllerWithIdentifier:@"InAppViewVC"];
        UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:sm];
      
        destNav.modalPresentationStyle = UIModalPresentationPopover;
        _colorPickerPopover = destNav.popoverPresentationController;
        _colorPickerPopover.delegate = self;
        _colorPickerPopover.sourceView = self.view;
       // _colorPickerPopover.permittedArrowDirections = UIPopoverArrowDirectionDown;
        
        if(IS_IPHONE_5){
            _colorPickerPopover.sourceRect = CGRectMake(185, 22, 0, 0);
        }
        else{
            _colorPickerPopover.sourceRect = CGRectMake(185, 62, 0, 0);
        }

        destNav.modalPresentationStyle = UIModalPresentationPopover;
        
        destNav.navigationBarHidden = YES;
        destNav.view.layer.cornerRadius = 0;
        
        [self presentViewController:destNav animated:YES completion:nil];
        
    
    }
    if(cell == self.restorecell){
        InAppViewVC *sm = [self.storyboard instantiateViewControllerWithIdentifier:@"InAppViewVC"];
        UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:sm];
        
        destNav.modalPresentationStyle = UIModalPresentationPopover;
        _colorPickerPopover = destNav.popoverPresentationController;
        _colorPickerPopover.delegate = self;
        _colorPickerPopover.sourceView = self.view;
        // _colorPickerPopover.permittedArrowDirections = UIPopoverArrowDirectionDown;
        
        if(IS_IPHONE_5){
            _colorPickerPopover.sourceRect = CGRectMake(185, 22, 0, 0);
        }
        else{
            _colorPickerPopover.sourceRect = CGRectMake(185, 62, 0, 0);
        }
        
        destNav.modalPresentationStyle = UIModalPresentationPopover;
        
        destNav.navigationBarHidden = YES;
        destNav.view.layer.cornerRadius = 0;
        
        [self presentViewController:destNav animated:YES completion:nil];
    }
    if(cell == self.TellFriendcell){
        
        NSString *shareText;
        
       
        shareText = @"Check Let's Chat and Join Me";
        
       
        
        NSURL *shareURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/lets-chat-2017/id1245540517?ls=1&mt=8"];
        
        NSArray *items   = [NSArray arrayWithObjects:
                            shareText,
                            shareURL, nil];
        
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        
        activityViewController.excludedActivityTypes =   @[UIActivityTypeCopyToPasteboard,
                                                           UIActivityTypePostToWeibo,
                                                           UIActivityTypeSaveToCameraRoll,
                                                           UIActivityTypeCopyToPasteboard,
                                                           UIActivityTypeAssignToContact,
                                                           UIActivityTypePrint];
        
        [self presentViewController:activityViewController animated:YES completion:nil];
    
    }
    if (cell == self.logoutCell) {
        
        if (!QMApi.instance.isInternetConnected) {
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
            return;
        }
        
        __weak __typeof(self)weakSelf = self;
        [AlertView presentAlertViewWithConfiguration:^(AlertView *alertView) {
            
            alertView.message = NSLocalizedString(@"QM_STR_ARE_YOU_SURE", nil);
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_LOGOUT", nil) andActionBlock:^{
                
                [weakSelf pressClearCache:nil];
                [SVProgressHUD  showWithMaskType:SVProgressHUDMaskTypeClear];
                [[QMApi instance] logout:^(BOOL success) {
                    [SVProgressHUD dismiss];
                    [weakSelf performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
                }];
            }];
            
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        }];
    }
}

#pragma mark - Actions


- (IBAction)changePushNotificationValue:(UISwitch *)sender {

    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        self.pushNotificationSwitch.on = !self.pushNotificationSwitch.on;
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if ([sender isOn]) {
        [[QMApi instance] subscribeToPushNotificationsForceSettings:YES complete:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
    else {
        [[QMApi instance] unSubscribeToPushNotifications:^(BOOL success) {
            [SVProgressHUD dismiss];
        }];
    }
    
}

- (IBAction)pressClearCache:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
    [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:^{
        
        [[[SDWebImageManager sharedManager] imageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
          //  weakSelf.cacheSize.text = [NSString stringWithFormat:@"Cache size: %.2f mb", (float)totalSize / 1024.f / 1024.f];
        }];
  
    }];
}


- (IBAction)Removeads:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    [[RageIAPHelper sharedInstance] buyProduct:product];
}
@end
