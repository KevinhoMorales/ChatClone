//
//  LogInVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "LogInVC.h"
#import "WelcomeScreenVC.h"
#import "LicenseAgreement.h"
#import "REAlertView+QMSuccess.h"
#import "QBApi.h"
#import "SVProgressHUD.h"
#import "SettingsManager.h"

@interface LogInVC ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;

@end

@implementation LogInVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //.. Wazowski Edition
    //..
    /*
     self.logInButton.layer.cornerRadius = 10.0f;
     self.logInButton.layer.masksToBounds = YES;
     
     self.facebookLoginButton.layer.cornerRadius = 10.0f;
     self.facebookLoginButton.layer.masksToBounds = YES;
     */
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    self.logInButton.layer.cornerRadius = 0.0f;
    self.logInButton.layer.masksToBounds = YES;
    
    self.facebookLoginButton.layer.cornerRadius = 0.0f;
    self.facebookLoginButton.layer.masksToBounds = YES;
    //..
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.rememberMeSwitch.on = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)logIn:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (email.length == 0 || password.length == 0) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        [[QMApi instance] loginWithEmail:email
                                password:password
                              rememberMe:weakSelf.rememberMeSwitch.on
                              completion:^(BOOL success)
         {
             [SVProgressHUD dismiss];
             
             if (success) {
                 [[QMApi instance] setAutoLogin:weakSelf.rememberMeSwitch.on
                                withAccountType:QMAccountTypeEmail];
                 [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier
                                               sender:nil];
             }
         }];
    }
}

- (IBAction)connectWithFacebook:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [LicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL success) {
        if (success) {
            [weakSelf fireConnectWithFacebook];
        }
    }];
}

- (void)fireConnectWithFacebook
{
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] singUpAndLoginWithFacebook:^(BOOL success) {

        if (success) {
            [weakSelf performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        } else {
            [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FACEBOOK_LOGIN_FALED_ALERT_TEXT", nil) actionSuccess:NO];
        }
    }];
}

@end
