//
//  TermsAndPrivacy.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "TermsAndPrivacy.h"

NSString *const privacyandTermUrl = @"http://saremcotech.com/terms-privacy.html";

@implementation TermsAndPrivacy

-(void)viewDidLoad {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:privacyandTermUrl]];
    [self.webview loadRequest:request];
}
-(void)viewWillAppear:(BOOL)animated{
    
}

@end
