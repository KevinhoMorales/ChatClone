//
//  LicenseAgreement.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "LicenseAgreement.h"
#import "QBApi.h"
#import "SettingsManager.h"
#import "LicenseAgreementVC.h"

@implementation LicenseAgreement

+ (void)checkAcceptedUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion {
    
    BOOL licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    
    if (licenceAccepted) {
        
        if (completion) completion(YES);
    }
    else {
        
        LicenseAgreementVC *licenceController =
        [vc.storyboard instantiateViewControllerWithIdentifier:@"QMLicenceAgreementControllerID"];
        
        licenceController.licenceCompletionBlock = completion;
        
        UINavigationController *navViewController =
        [[UINavigationController alloc] initWithRootViewController:licenceController];
        
        [vc presentViewController:navViewController
                         animated:YES
                       completion:nil];
    }
}

@end
