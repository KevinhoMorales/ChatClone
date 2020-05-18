//
//  VideoCallUsersSelection.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMAddUsersAbstractController.h"

@interface VideoCallUsersSelection : QMAddUsersAbstractController


@property (nonatomic, strong) QBChatDialog *chatDialog;
- (void)callWithConferenceType:(QBRTCConferenceType)conferenceType;
@end
