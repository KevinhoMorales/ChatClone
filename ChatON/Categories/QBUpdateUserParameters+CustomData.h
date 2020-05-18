//
//  QBUpdateUserParameters+CustomData.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBUpdateUserParameters (CustomData)

@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *status;
@property (assign, nonatomic) BOOL isImport;
@property (strong,nonatomic) NSString *notificationsound;

@end
