//
//  LicenseAgreementVC.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "LicenseAgreementVC.h"
#import <SVProgressHUD.h>
#import "AlertView.h"
#import "QBApi.h"
#import "SettingsManager.h"

NSString *const kQMAgreementUrl = @"http://saremcotech.com/terms-privacy.html";

@interface LicenseAgreementVC ()

<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;

@end

@implementation LicenseAgreementVC

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:17.0/255.0 green:110.0/255.0 blue:242.0/255.0 alpha:1.0];
  
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    BOOL licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    if (licenceAccepted) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
  //  [SVProgressHUD show];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kQMAgreementUrl]];
    [self.webView loadRequest:request];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerSuccess:NO];
}

- (void)dismissViewControllerSuccess:(BOOL)success {
    __weak __typeof(self)weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        
        if(weakSelf.licenceCompletionBlock) {
            
            weakSelf.licenceCompletionBlock(success);
            weakSelf.licenceCompletionBlock = nil;
        }
    }];
}

- (IBAction)acceptLicense:(id)sender {
    
    [[QMApi instance].settingsManager setUserAgreementAccepted:YES];
    [self dismissViewControllerSuccess:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end
