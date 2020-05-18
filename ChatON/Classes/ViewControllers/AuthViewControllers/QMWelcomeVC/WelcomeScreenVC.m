//
//  SplashControllerViewController.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "WelcomeScreenVC.h"
#import "LicenseAgreement.h"
#import "SplashVC.h"
#import "QBApi.h"
#import <QMAuthService.h>
#import "SettingsManager.h"
#import "SVProgressHUD.h"
#import "AlertView.h"
#import "REAlertView+QMSuccess.h"
#import <DigitsKit/DigitsKit.h>
#import "NameRegistrationVC.h"
#import "DigitsConfigurationFactory.h"

@interface WelcomeScreenVC ()

@property (weak, nonatomic) IBOutlet UIImageView *bubleImage;

- (IBAction)connectWithFacebook:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *PhoneLogin;
- (IBAction)PhoneLoginAction:(id)sender;

@end

@implementation WelcomeScreenVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.bubleImage.image = [UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"logo_big" : @"logo_big_960"];
    [[QMApi instance].settingsManager defaultSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

#pragma mark - Actions

- (IBAction)connectWithFacebook:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [LicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        if (success) {
            [weakSelf signInWithFacebook];
        }
    }];
}

- (IBAction)signUpWithEmail:(id)sender
{
    [self performSegueWithIdentifier:kSignUpSegueIdentifier sender:nil];
}

- (IBAction)pressAlreadyBtn:(id)sender
{
    [self performSegueWithIdentifier:kLogInSegueSegueIdentifier sender:nil];
}

- (void)signInWithFacebook {

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {

        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        } else {
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        }
    }];
}

- (IBAction)PhoneLoginAction:(id)sender {
    
     __strong __typeof(self)weakSelf = self;
    [LicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        if (success) {
            
           // [self performSegueWithIdentifier:@"nameregistration" sender:nil];
           [weakSelf performDigitsLogin];
        }
        
    }];

}
- (void)performDigitsLogin {
    
    //@weakify(self);
    [[NSUserDefaults standardUserDefaults] setValue:@"sessionnew" forKey:@"titlestring"];
    [[Digits sharedInstance] authenticateWithViewController:nil configuration:[DigitsConfigurationFactory qmunicateThemeConfiguration] completion:^(DGTSession *session, NSError *error) {
        // @strongify(self);
        // twitter digits auth
        if (error.userInfo.count > 0) {
            
           
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil) actionSuccess:NO ];
        }
        else {
            
            [QMApi instance].settingsManager.rememberMe = YES;
            DGTOAuthSigning *oauthSigning = [[DGTOAuthSigning alloc] initWithAuthConfig:[Digits sharedInstance].authConfig
                                                                            authSession:session];
            
            NSDictionary *authHeaders = [oauthSigning OAuthEchoHeadersToVerifyCredentials];
            if (!authHeaders) {
                // user seems skipped auth process
                return;
            }
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            [[[QMApi instance] loginWithTwitterDigitsAuthHeaders:authHeaders] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
                
                [SVProgressHUD dismiss];
                
                if (!task.isFaulted) {
                    
                    [self performSegueWithIdentifier:@"nameregistration" sender:nil];
                    
                    [QMApi instance].settingsManager.accountType = QMAccountTypeDigits;
                    
                    QBUUser *user = task.result;
                    if (user.fullName.length == 0) {
                        // setting phone as user full name
                      //  user.phone = user.phone;
                        NameRegistrationVC *nv = [[NameRegistrationVC alloc] init];
                        nv.currentUser = user;
                        QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
                        updateUserParams.phone = user.phone;
                        updateUserParams.fullName = user.phone;
                        
                        
                        [[QMApi instance] updateCurrentUser:updateUserParams image:nil progress:nil completion:^(BOOL success) {}];
                        ;
                    }
                    //   [[QMProfile currentProfile] synchronizeWithUserData:user];
                    
                    //  return [[QMCore instance].pushNotificationManager subscribeForPushNotifications];
                }
                
                return nil;
            }];
        }
    }];
}

@end
