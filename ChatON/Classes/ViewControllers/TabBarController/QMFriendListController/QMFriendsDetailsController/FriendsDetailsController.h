//
//  FriendsDetailsController.h
//  ChatON ( Q-municate version )
//
//  Edited by Saremcotech on 26/08/2017. Created by Andrey Ivanov on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticDataTableViewController.h"

@interface FriendsDetailsController : StaticDataTableViewController

@property (strong, nonatomic) QBUUser *selectedUser;

@end
