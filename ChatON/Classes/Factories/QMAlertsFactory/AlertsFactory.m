//
//  AlertsFactory.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AlertsFactory.h"
#import "AlertView.h"

@implementation AlertsFactory

+ (void)comingSoonAlert {
    
    [AlertView presentAlertViewWithConfiguration:^(AlertView *alertView) {
        alertView.title = NSLocalizedString(@"QM_STR_COMING_SOON", nil);
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_OK", nil) andActionBlock:nil];
    }];
}

@end
