//
//  SplashVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "SplashVC.h"
#import "WelcomeScreenVC.h"
#import "SettingsManager.h"
#import "REAlertView+QMSuccess.h"
#import "QBApi.h"

@interface SplashVC ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogoView;
@property (weak, nonatomic) IBOutlet UIButton *reconnectBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SplashVC

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.splashLogoView setImage:[UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"bg" : @"splash-960"]];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator startAnimating];
    [self createSession];
}

- (void)createSession {
    
    self.reconnectBtn.alpha = 0;
    
    if (!QMApi.instance.isInternetConnected) {
        [AlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        self.reconnectBtn.alpha = 1;
        return;
    }

    SettingsManager *settingsManager = [[SettingsManager alloc] init];
    BOOL rememberMe = settingsManager.rememberMe;
    
//    if([QMApi instance].settingsManager.accountType == QMAccountTypeDigits){
//        
//        [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
//    }
//    else{
    
        if (rememberMe) {
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        } else {
            [self performSegueWithIdentifier:kWelcomeScreenSegueIdentifier sender:nil];
        }
  //  }
    

}

- (void)reconnect {
    
    self.reconnectBtn.alpha = 1;
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)pressReconnectBtn:(id)sender {
    [self createSession];
}

@end
