//
//  REAlertView+QMSuccess.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "REAlertView+QMSuccess.h"

@implementation AlertView (QMSuccess)

+ (void)showAlertWithMessage:(NSString *)messageString actionSuccess:(BOOL)success {
    
    [AlertView presentAlertViewWithConfiguration:^(AlertView *alertView) {
        alertView.title = success ? NSLocalizedString(@"QM_STR_SUCCESS", nil) : NSLocalizedString(@"QM_STR_ERROR", nil);
        alertView.message = messageString;
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_OK", nil) andActionBlock:^{}];
    }];
}

@end
