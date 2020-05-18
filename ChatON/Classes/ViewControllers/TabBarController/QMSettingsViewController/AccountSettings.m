//
//  AccountSettings.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AccountSettings.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "QMContactListCache.h"
#import "AlertView.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import <DigitsKit/DigitsKit.h>
#import "DigitsConfigurationFactory.h"

@implementation AccountSettings



- (void)viewDidLoad {
    [super viewDidLoad];
    
     [Digits sharedInstance].sessionUpdateDelegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.tableView.tableHeaderView.tintColor = [UIColor darkGrayColor];
    if ([QMApi instance].settingsManager.accountType == QMAccountTypeEmail) {

       self.ChangeNumberLabel.text = @"Change Password";
    }
    if([QMApi instance].settingsManager.accountType == QMAccountTypeDigits){
     
        self.ChangeNumberLabel.text = @"Change Number";
    }
    
    
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    return 40;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
 
    QBUUser *user = self.currentUser;
    
    if(cell == self.ChangePassandNumCell){
        
        if([QMApi instance].settingsManager.accountType == QMAccountTypeEmail){
            [self performSegueWithIdentifier:@"changepassword" sender:nil];
        }
        if([QMApi instance].settingsManager.accountType == QMAccountTypeDigits){
            
            [[Digits sharedInstance] logOut];
           [Digits sharedInstance].sessionUpdateDelegate = self;
           // [self performSegueWithIdentifier:@"changenumber" sender:nil];
            
            [self performDigitsLogin];
        }
    }
    if(cell == self.DeleteAccountcell){
        
        if (!QMApi.instance.isInternetConnected) {
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
            return;
        }
        
        __weak __typeof(self)weakSelf = self;
        [AlertView presentAlertViewWithConfiguration:^(AlertView *alertView) {
            
            alertView.message = NSLocalizedString(@"QM_STR_ARE_YOU_SURE", nil);
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil) andActionBlock:^{
                
               
                [SVProgressHUD  showWithMaskType:SVProgressHUDMaskTypeClear];
                
                //change
                
                        [QBRequest deleteCurrentUserWithSuccessBlock:^(QBResponse * _Nonnull response) {
                            
                            BFTask *completion = [QMUsersCache.instance deleteUser:user];
                            if(completion){
                                [QMContactListCache.instance deleteContactList:^{
                                    
                                    
                                    [[QMApi instance].contactListService.contactListMemoryStorage free];
                                    [[Digits sharedInstance] logOut];
                                    [QMApi instance].settingsManager.rememberMe = NO;
                                    [weakSelf performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
                                }];
                            }
                        } errorBlock:^(QBResponse * _Nonnull response) {
                            
                            NSLog(@"error in deleting user...");
                            
                        }];
                
                        
                

                
            }];
            
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        }];

        
        
    }
}
-(void)digitsSessionHasChanged:(DGTSession *)newSession{
    
    [QMApi instance].settingsManager.rememberMe = YES;
    DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc] initWithAuthConfig:[Digits sharedInstance].authConfig
                                                                    authSession:newSession];
    
    NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
    if (!authHeaders) {
        // user seems skipped auth process
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [[[QMApi instance] loginWithTwitterDigitsAuthHeaders:authHeaders] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        [SVProgressHUD dismiss];
        
        if (!task.isFaulted) {
            
            //  [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
            
            
            
            [QMApi instance].settingsManager.accountType = QMAccountTypeDigits;
            
            QBUUser *user = task.result;
            if (user.fullName.length != 0) {
                
                // setting phone as user full name
                NSString *str = [newSession.phoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
                user.fullName = str;
                user.login = newSession.phoneNumber;
                user.phone = str;
                
                QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
                updateUserParams.fullName = user.fullName;
                updateUserParams.phone = user.phone;
                updateUserParams.login = user.login;
                
                
                [[QMApi instance] updateCurrentUser:updateUserParams image:nil progress:nil completion:^(BOOL success) {
                    
                    if(success){
                        [[[UIAlertView alloc] initWithTitle:@"Number Changed" message:NSLocalizedString(@"QM_NUMBER_CHANGED", nil) delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }
                }];
                ;
            }
            //   [[QMProfile currentProfile] synchronizeWithUserData:user];
            
            //  return [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
        }
        
        return nil;
    }];

}
- (void)performDigitsLogin {
    
    //@weakify(self);
    [[NSUserDefaults standardUserDefaults] setValue:@"sessionchange" forKey:@"titlestring"];
    [[Digits sharedInstance] authenticateWithViewController:nil configuration:[DigitsConfigurationFactory qmunicateThemeConfiguration] completion:^(DGTSession *session, NSError *error) {
        // @strongify(self);
        // twitter digits auth
        if (error.userInfo.count > 0) {
            
            
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil) actionSuccess:NO ];
        }
        else {
            
            [self digitsSessionHasChanged:session];
            
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
   
}


@end
