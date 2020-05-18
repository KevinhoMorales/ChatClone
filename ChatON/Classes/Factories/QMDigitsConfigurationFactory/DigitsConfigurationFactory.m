//
//  DigitsConfigurationFactory.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "DigitsConfigurationFactory.h"
#import <DigitsKit/DGTAuthenticationConfiguration.h>
#import <DigitsKit/DGTAppearance.h>


@implementation DigitsConfigurationFactory

+ (DGTAuthenticationConfiguration *)qmunicateThemeConfiguration {
    
    DGTAuthenticationConfiguration *configuration = [[DGTAuthenticationConfiguration alloc] initWithAccountFields:DGTAccountFieldsDefaultOptionMask];
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"titlestring"];
    
    DGTAppearance *appearance = [[DGTAppearance alloc] init];
    appearance.logoImage = [UIImage imageNamed:@"logo-splash.png"];
    appearance.headerFont = [UIFont systemFontOfSize:17.0f];
    appearance.accentColor = [UIColor colorWithRed:(17.0f/255.0f) green:(110.0f/255.0f) blue:(242.0f/255.0f) alpha:1];
    
    configuration.appearance = appearance;
    
    if([str isEqualToString:@"sessionnew"]){
    configuration.title = NSLocalizedString(@"QM_STR_PHONE_VERIFICATION", nil);
    }
    else if([str isEqualToString:@"sessionchange"]){
        configuration.title = NSLocalizedString(@"QM_STR_PHONE_CHNAGE", nil);

    }
    
    return configuration;
}

@end
