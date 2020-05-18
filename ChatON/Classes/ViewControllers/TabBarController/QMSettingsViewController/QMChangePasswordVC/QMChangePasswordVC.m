//
//  QMChangePasswordVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChangePasswordVC.h"
#import "SettingsManager.h"
#import "QMAuthService.h"
#import "REAlertView+QMSuccess.h"
#import "UIImage+TintColor.h"
#import "SVProgressHUD.h"
#import "QBApi.h"

const NSUInteger kQMMinPasswordLenght = 7;
const NSUInteger kQMMaxPasswordLenght = 40;

@interface QMChangePasswordVC ()

<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (strong, nonatomic) SettingsManager *settingsManager;

@end

@implementation QMChangePasswordVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //.. Wazowski Edition
    //..
    //self.changeButton.layer.cornerRadius = 5.0f;
    self.changeButton.layer.cornerRadius = 0.0f;
    //..

     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.settingsManager = [[SettingsManager alloc] init];
    
    [self configureChangePasswordVC];
}

- (void)configureChangePasswordVC {
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImage *buttonBG = [UIImage imageNamed:@"blue_conter"];
    UIColor *normalColor = [UIColor colorWithRed:0.091 green:0.674 blue:0.174 alpha:1.000];
    UIEdgeInsets imgInsets = UIEdgeInsetsMake(9, 9, 9, 9);
    [self.changeButton setBackgroundImage:[buttonBG tintImageWithColor:normalColor resizableImageWithCapInsets:imgInsets]
                                 forState:UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.oldPasswordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - actions

- (IBAction)pressChangeButton:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    NSString *oldPassword = self.settingsManager.password;
    NSString *confirmOldPassword = self.oldPasswordTextField.text;
    NSString *newPassword = self.passwordTextField.text;
    
    if (newPassword.length == 0 || confirmOldPassword.length == 0){
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
		[SVProgressHUD dismiss];
    }
    else if (newPassword.length <= kQMMinPasswordLenght) {
        [AlertView showAlertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_PASSWORD_IS_TOO_SHORT", nil), (long)kQMMinPasswordLenght] actionSuccess:NO];
        [SVProgressHUD dismiss];
    }
    else if (newPassword.length > kQMMaxPasswordLenght) {
        [AlertView showAlertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_PASSWORD_IS_TOO_LONG", nil), (long)kQMMaxPasswordLenght] actionSuccess:NO];
        [SVProgressHUD dismiss];
    }
    else if (![oldPassword isEqualToString:confirmOldPassword]) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_WRONG_OLD_PASSWORD", nil) actionSuccess:NO];
		[SVProgressHUD dismiss];
    }
    else {
        
        [self updatePassword:oldPassword newPassword:newPassword];
    }
}

- (void)updatePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword {

    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    
    params.password = newPassword;
    params.oldPassword = oldPassword;
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] changePasswordForCurrentUser:params completion:^(BOOL success) {
        //
        if (success) {
            //
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_PASSWORD_CHANGED", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else{
            [SVProgressHUD dismiss];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.oldPasswordTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self pressChangeButton:nil];
    }
    
    return YES;
}

@end
