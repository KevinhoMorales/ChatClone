//
//  AlertView.m
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "AlertView.h"

@interface AlertView ()

@property (assign, nonatomic) BOOL isDissmis;
@property (strong, nonatomic) NSMutableArray* buttonActions;

@end

@implementation AlertView

- (id)init {
    
    self = [super init];
    if (self) {
		self.buttonActions = @[].mutableCopy;
		self.delegate = self;
    }
    return self;
}

- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REAlertButtonAction)block {
    if (!block) {
         block = ^() {};
    }
	[self.buttonActions insertObject:[block copy] atIndex:[self addButtonWithTitle:title]];
}


- (void)dissmis {
    self.isDissmis = YES;
}

+ (void)presentAlertViewWithConfiguration:(REAlertConfiguration)configuration{
	AlertView* alertView = [AlertView new];
	configuration(alertView);

    if (alertView.isDissmis) {
        alertView.buttonActions = nil;
        return;
    }
	[alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	AlertView *AlertView_ = (AlertView *)alertView;
	REAlertButtonAction action = [AlertView_.buttonActions objectAtIndex:buttonIndex];
    if (action) { action();}
    self.buttonActions = nil;
}

@end
