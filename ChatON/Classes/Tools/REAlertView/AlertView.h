//
//  AlertView.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlertView;

typedef void(^REAlertButtonAction)();
typedef void(^REAlertConfiguration)(AlertView *alertView);

@interface AlertView : UIAlertView

- (void)dissmis;
- (void)addButtonWithTitle:(NSString *)title andActionBlock:(REAlertButtonAction)block;
+ (void)presentAlertViewWithConfiguration:(REAlertConfiguration)configuration;

@end
